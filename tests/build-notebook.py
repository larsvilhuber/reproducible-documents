#!/usr/bin/env python3
"""Build the solutions notebook for part 4.

Takes the Colab notebook from larsvilhuber/jupyter-stata-colab and appends the
cells that participants type (examples/04-jupyter-colab/cell-*.txt), each
with a short explanation. The cell files are the single source: the slides,
this notebook, and tests/test-colab-notebook.sh all use them.

    python3 tests/build-notebook.py ORIGINAL.ipynb OUTPUT.ipynb
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

The cells below are the solutions to part 4 of the [Reproducible Documents tutorial]({TUTORIAL}): a clean regression table and a figure, a number from Stata in a sentence, and a figure made with Python. Run the cells above first."""

OUTRO = """## 7. Print this notebook

- **PDF**: *File* ▸ *Print* ▸ *Save as PDF*.
- **Word** (or PDF) on **Binder**: save the notebook, then *File* ▸ *New* ▸ *Terminal*, and type
  `pip install quarto-cli`, then `quarto render stata_colab_solutions.ipynb --to docx` (or `--to typst` for PDF). Add `-M echo:false` to hide the code.
- **Word** on **Colab**: *File* ▸ *Download* ▸ *Download .ipynb*, then run the same `quarto render` command wherever Quarto is (posit.cloud, or your laptop)."""

# keyed by the name of the cell file, without "cell-N-" and ".txt"
EXPLANATIONS = {
    "table-and-figure": "A clean, printable regression table (`etable`), and a figure that is shown below the cell and saved to disk.",
    "number-in-sentence": "A number from Stata, in a sentence: Python asks Stata for the coefficient, and writes the sentence (as Markdown) below the cell. No `%%stata` here: this is Python.",
    "python-figure": "A figure that is hard to make in Stata, made with Python (matplotlib) from the Stata data: the scatter plot, with a histogram of each variable along its axis.",
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
    args = parser.parse_args()

    with open(args.original) as fh:
        nb = json.load(fh)

    # the "Open in Colab" badge should open this notebook, not the original
    first = nb["cells"][0]
    first["source"] = [s.replace(EXAMPLE, SOLUTIONS) for s in first["source"]]

    nb["cells"].append(markdown(INTRO))
    for path in sorted(glob.glob(os.path.join(CELLS, "cell-*.txt"))):
        key = os.path.basename(path)[len("cell-N-"):-len(".txt")]
        nb["cells"].append(markdown(EXPLANATIONS[key]))
        with open(path) as fh:
            nb["cells"].append(code(fh.read()))
    nb["cells"].append(markdown(OUTRO))

    with open(args.output, "w") as fh:
        json.dump(nb, fh, indent=1, ensure_ascii=False)
        fh.write("\n")
    print(f"{args.output}: {len(nb['cells'])} cells")


if __name__ == "__main__":
    main()
