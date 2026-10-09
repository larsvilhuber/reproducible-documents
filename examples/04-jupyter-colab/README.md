# Part 4: Jupyter + Stata on Google Colab or Binder

The notebook in [larsvilhuber/jupyter-stata-colab](https://github.com/larsvilhuber/jupyter-stata-colab) installs Stata on Google Colab (or on [Binder](https://mybinder.org), which needs no account), and runs Stata code in cells that start with `%%stata`. You add new cells that create a printable table and a figure, put a number from Stata into a sentence, and make a figure with Python that is hard to make in Stata. Then you print the whole notebook, as PDF or Word.

| File | Type it into |
|:-----|:-------------|
| `cell-1-table-and-figure.txt` | A new code cell: three regressions in one table (`etable`), and a figure |
| `cell-2-number-in-sentence.txt` | A new code cell: the coefficient from Stata, in a sentence (Python) |
| `cell-3-python-figure.txt` | A new code cell: scatter plot with a histogram along each axis (Python, matplotlib) |
| `expected/` | What you should get |

Copy each file's content into its own cell, including the first line `%%stata` where there is one (only cell 1 is Stata; the others are Python).  Stuck? The [solutions notebook](https://colab.research.google.com/github/larsvilhuber/jupyter-stata-colab/blob/main/stata_colab_solutions.ipynb) has all the new cells.

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
4. Add and run cell 2: a sentence with the coefficient appears below the cell. Add and run cell 3: a figure made with Python.

## Print the notebook

Quarto turns the notebook, with its saved results, into Word or PDF. No Stata needed.

- **Colab**: PDF with **File** ▸ **Print** ▸ *Save as PDF*. For Word, **File** ▸ **Download** ▸ **Download .ipynb**, and convert it as below (on posit.cloud, or your laptop). Keep your work with **File** ▸ **Save a copy in Drive**.
- **Binder**: save the notebook (**File** ▸ **Save Notebook**), then **File** ▸ **New** ▸ **Terminal**:

  ```bash
  pip install quarto-cli
  quarto render stata_colab_example.ipynb --to docx    # Word
  quarto render stata_colab_example.ipynb --to typst   # PDF
  ```

  Right-click the new files in the file list ▸ **Download**. PDF also works with **File** ▸ **Print**.
- **Anywhere else** (posit.cloud: upload the `.ipynb`, use the Terminal; your laptop: Quarto from <https://quarto.org>, or `pip install quarto-cli`): the same `quarto render` commands. Add `-M echo:false` to hide the code and keep the results.

The Colab or Binder computer is temporary: download what you need before the session ends.
