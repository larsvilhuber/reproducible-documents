# Part 4: Jupyter + Stata on Google Colab or Binder

The notebook in [larsvilhuber/jupyter-stata-colab](https://github.com/larsvilhuber/jupyter-stata-colab) installs Stata on Google Colab (or on [Binder](https://mybinder.org), which needs no account), and runs Stata code in cells that start with `%%stata`. You add new cells that create a printable table and a figure, and export both to Word and PDF.

| File | Type it into |
|:-----|:-------------|
| `cell-1-table-and-figure.txt` | A new code cell: three regressions in one table (`etable`), and a figure |
| `cell-2-export-word.txt` | A new code cell: Word document with the table and the figure (`putdocx`) |
| `cell-3-export-pdf.txt` | A new code cell: the same, as PDF (`putpdf`) |
| `cell-4-download.txt` | A new code cell: download both files to your computer (Python, Colab only; on Binder, right-click the files ▸ **Download**) |
| `expected/` | What you should get |

Copy each file's content into its own cell, including the first line `%%stata`. Stuck? The [solutions notebook](https://colab.research.google.com/github/larsvilhuber/jupyter-stata-colab/blob/main/stata_colab_solutions.ipynb) has all the new cells.

## Before you start

The notebook needs your Stata license `stata.lic` as one line of text (base64). On your own computer:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\Program Files\Stata19\stata.lic"))   # Windows (PowerShell)
```

```bash
base64 -i /Applications/Stata/stata.lic    # macOS
```

Copy the result. Treat it like a password: never paste it into the notebook itself, only into the hidden prompt.

## Steps

1. Open the notebook: go to <https://github.com/larsvilhuber/jupyter-stata-colab>, click **Open in Colab** (or **launch binder**: no account needed, but it takes a few minutes to start, and stops after about 10 minutes without activity).
2. **Runtime** ▸ **Run all** (Binder: **Run** ▸ **Run All Cells**). Colab warns that the notebook is not from Google: **Run anyway**. Paste your license line when asked.
3. At the bottom, click **+ Code**, type cell 1, and run it (**Shift+Enter**): you see Table 1 and the figure.
4. Add and run cells 2 and 3: they create `results.docx` and `results.pdf`.
5. Add and run cell 4 to download them. Or: click the folder icon on the left, right-click the file ▸ **Download**.

## The whole notebook

- As PDF: **File** ▸ **Print** ▸ *Save as PDF*
- As a notebook: **File** ▸ **Download** ▸ **Download .ipynb**. Quarto can turn it into Word or PDF (e.g., on posit.cloud): `quarto render stata_colab_example.ipynb --to docx`
- Keep your changes: **File** ▸ **Save a copy in Drive**

The Colab or Binder computer is temporary: download what you need before the session ends.
