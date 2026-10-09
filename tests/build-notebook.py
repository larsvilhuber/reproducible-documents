#!/usr/bin/env python3
"""Build the solutions notebook for part 4.

Takes the Colab notebook from larsvilhuber/jupyter-stata-colab and appends the
cells that participants type (examples/04-jupyter-colab/cell-*.txt), each
with a short explanation. The cell files are the single source: the slides,
this notebook, and tests/test-colab-notebook.sh all use them.

    python3 tests/build-notebook.py ORIGINAL.ipynb OUTPUT.ipynb [--skip-download]

--skip-download leaves out the download cell, which only works on Colab (used
by tests/test-colab-notebook.sh).
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

The cells below are the solutions to part 4 of the [Reproducible Documents tutorial]({TUTORIAL}): a clean regression table and a figure, a number from Stata in a sentence, a figure made with Python, and a Word and a PDF document made with Python. Run the cells above first, and these in order."""

# keyed by the name of the cell file, without "cell-N-" and ".txt"
EXPLANATIONS = {
    "table-and-figure": "A clean, printable regression table (`etable`), and a figure that is shown below the cell and saved to disk.",
    "number-in-sentence": "A number from Stata, in a sentence: Python asks Stata for the coefficient, and writes the sentence (as Markdown) below the cell. No `%%stata` here: this is Python.",
    "python-figure": "A figure that is hard to make in Stata, made with Python (matplotlib) from the Stata data: the scatter plot, with a histogram of each variable along its axis.",
    "table-in-python": "The regression table, as a pandas DataFrame: the notebook shows it as a formatted table below the cell.",
    "export-word": "A Word document with the sentence, the table, and the Python figure, written by Python (`python-docx`, installed with the notebook's `%pip` command). The number comes from Stata, not from you.",
    "export-pdf": "The same, as a PDF (`fpdf2`).",
    "download": "Download both files to your computer (Colab only). Or click the folder icon on the left, right-click a file, and choose *Download*.",
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
        key = os.path.basename(path)[len("cell-N-"):-len(".txt")]
        if args.skip_download and key == "download":
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
