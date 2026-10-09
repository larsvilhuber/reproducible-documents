#!/usr/bin/env python3
"""Build the solutions notebook for part 4.

Takes the Colab notebook from larsvilhuber/jupyter-stata-colab and appends the
cells that participants type (examples/04-jupyter-colab/cell-*.txt), each
with a short explanation. The cell files are the single source: the slides,
this notebook, and tests/test-colab-notebook.sh all use them.

    python3 tests/build-notebook.py ORIGINAL.ipynb OUTPUT.ipynb [--skip-download]

--skip-download leaves out the last cell, which only works on Colab (used by
tests/test-colab-notebook.sh).
"""

import argparse
import glob
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
CELLS = os.path.join(HERE, "..", "examples", "04-jupyter-colab")
TUTORIAL = "https://larsvilhuber.github.io/reproducible-documents/"

EXAMPLE = "stata_colab_example.ipynb"
SOLUTIONS = "stata_colab_solutions.ipynb"

INTRO = f"""## 6. Your turn: a printable table and a figure

The cells below are the solutions to part 4 of the [Reproducible Documents tutorial]({TUTORIAL}): a clean regression table and a figure, exported to Word and PDF. Run the cells above first."""

EXPLANATIONS = {
    "cell-1": "A clean, printable regression table (`etable`), and a figure that is shown below the cell and saved to disk.",
    "cell-2": "Put the table and the figure into a Word document (`putdocx`). The number in the sentence comes from Stata, not from you.",
    "cell-3": "The same, as a PDF (`putpdf`).",
    "cell-4": "Download both files to your computer (Colab only). Or click the folder icon on the left, right-click a file, and choose *Download*.",
}


def lines(text):
    """Split text into the list-of-lines form used in .ipynb files."""
    text = text.rstrip("\n").split("\n")
    return [line + "\n" for line in text[:-1]] + [text[-1]]


def markdown(text):
    return {"cell_type": "markdown", "metadata": {}, "source": lines(text)}


def code(text):
    return {"cell_type": "code", "execution_count": None, "metadata": {},
            "outputs": [], "source": lines(text)}


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("original")
    parser.add_argument("output")
    parser.add_argument("--skip-download", action="store_true")
    args = parser.parse_args()

    with open(args.original) as fh:
        nb = json.load(fh)

    # the "Open in Colab" badge should open this notebook, not the original
    first = nb["cells"][0]
    first["source"] = [s.replace(EXAMPLE, SOLUTIONS) for s in first["source"]]

    nb["cells"].append(markdown(INTRO))
    for path in sorted(glob.glob(os.path.join(CELLS, "cell-*.txt"))):
        key = os.path.basename(path)[:6]
        if args.skip_download and key == "cell-4":
            continue
        nb["cells"].append(markdown(EXPLANATIONS[key]))
        with open(path) as fh:
            nb["cells"].append(code(fh.read()))

    with open(args.output, "w") as fh:
        json.dump(nb, fh, indent=1, ensure_ascii=False)
        fh.write("\n")
    print(f"{args.output}: {len(nb['cells'])} cells")


if __name__ == "__main__":
    main()
