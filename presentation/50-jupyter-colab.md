# 4. Jupyter + Stata on Colab or Binder

## What is a Jupyter notebook?

- A document made of **cells**: text cells and code cells
- Run a code cell: its output (tables, figures) appears right below it
- Code, results, and explanations, all in one file: `.ipynb`

## What is Google Colab?

- Jupyter notebooks in your web browser, on Google's computers
- Free, nothing to install, needs a Google account
- Colab has no Stata, so our notebook **installs Stata** for you
- Stata code goes into cells that start with `%%stata`

## No Google account? Binder

- [Binder](https://mybinder.org): Jupyter in your browser, **no account needed**
- The same notebook, the same cells
- Slower to start (a few minutes), and the session ends after about 10 minutes without activity
- Open it with the [launch binder]{.menu} badge, [or this link](`r BINDER_URL`)

Where Colab and Binder differ, the next slides say so.

## Before you start: your license, as text

The notebook needs your Stata license (`stata.lic`) as one line of text (base64).

Windows (PowerShell):

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\Program Files\Stata19\stata.lic"))
```

macOS (Terminal):

```bash
base64 -i /Applications/Stata/stata.lic
```

Copy the result. **Treat it like a password:** never put it into the notebook itself.

## Step 1: Open the notebook

- Go to <`r COLAB_REPOSITORY_URL`>
- Click the [Open in Colab]{.menu} badge, and log in with your Google account
- Binder: click the [launch binder]{.menu} badge, and wait

## Step 2: Run all cells

- [Runtime]{.menu} ▸ [Run all]{.menu}
  - Binder: [Run]{.menu} ▸ [Run All Cells]{.menu}
- Colab warns that the notebook is not from Google: [Run anyway]{.menu}
- When asked, paste your license line, press Enter
- Wait about a minute: Stata is downloaded and started

## What the notebook does

1. **Settings**: which Stata version
2. **Install Stata**: copied from the AEA Data Editor's Docker images
3. **License**: your license is written to the temporary computer
4. **Start Stata**: now `%%stata` cells work
5. **Use Stata**: `summarize`, `regress`, a graph

## Step 3: Add a new cell

- Scroll to the bottom
- Click [+ Code]{.menu} (Binder: the [+]{.menu} button in the toolbar)
- Type the code on the next slide (or copy it from `examples/04-jupyter-colab/`)
- Run it: click ▶ next to the cell, or press [Shift+Enter]{.menu}

Stuck? The [solutions notebook](`r COLAB_SOLUTIONS_URL`) has all the new cells.

## Cell 1: a table and a figure

```{r, echo=FALSE, results='asis'}
show_file("examples/04-jupyter-colab/cell-1-table-and-figure.txt", from = 1, to = "estimates store m3", lang = "stata")
```

*Continued on the next slide, in the same cell.*

## Cell 1 (continued)

```{r, echo=FALSE, results='asis'}
show_file("examples/04-jupyter-colab/cell-1-table-and-figure.txt", from = "* A clean", lang = "stata")
```

`///` continues a command on the next line.

## What you should see: the table

:::{.stataout}
```{r, echo=FALSE, results='asis'}
show_file_or("examples/04-jupyter-colab/expected/table1.txt",
  fallback = "- **Table 1**: three regressions side by side, with stars, N, and R-squared",
  lang = "")
```
:::

## What you should see: the figure

```{r, echo=FALSE, results='asis'}
image_or("images/ex04-figure.png",
  "- Price against mileage, for domestic and foreign cars\n- Also saved as `price_mpg.png`, in the notebook's folder",
  '{height="520"}')
```

## Cell 2: a number from Stata, in a sentence

```{r, echo=FALSE, results='asis'}
show_file("examples/04-jupyter-colab/cell-2-number-in-sentence.txt", lang = "python")
```

- Python (no `%%stata`) asks Stata for `_b[mpg]`, and writes a sentence
- `{b_mpg:.1f}` is like Stata's `%5.1f`

## What you should see: the sentence

Below the cell, as formatted text:

> Holding weight constant, one more mile per gallon changes the price by **`r AUTO_COEF_MPG`** dollars.

- The number comes from Stata: **never typed**
- When Quarto renders the notebook (see the bonus slide), the sentence is part of the document

## Cell 3: a figure made with Python

```{r, echo=FALSE, results='asis'}
show_file("examples/04-jupyter-colab/cell-3-python-figure.txt", from = 1, to = "set_ylabel", lang = "python")
```

*Continued on the next slide, in the same cell.*

## Cell 3 (continued)

```{r, echo=FALSE, results='asis'}
show_file("examples/04-jupyter-colab/cell-3-python-figure.txt", from = "top = ax.inset_axes", lang = "python")
```

- A histogram of each variable, along its axis: hard to do in Stata
- `stata.pdataframe_from_data()`: the Stata data, for Python

## What you should see: the Python figure

```{r, echo=FALSE, results='asis'}
image_or("images/ex04-python-figure.png",
  "- The scatter plot of price against mileage\n- Above it, the distribution of mileage; on the right, the distribution of price\n- Also saved as `price_mpg_hist.png`",
  '{height="540"}')
```

## Cell 4: export to Word

```{r, echo=FALSE, results='asis'}
show_file("examples/04-jupyter-colab/cell-4-export-word.txt", lang = "stata")
```

## Cell 5: export to PDF

```{r, echo=FALSE, results='asis'}
show_file("examples/04-jupyter-colab/cell-5-export-pdf.txt", lang = "stata")
```

## Cell 6: download the files

```{r, echo=FALSE, results='asis'}
show_file("examples/04-jupyter-colab/cell-6-download.txt", lang = "python")
```

No `%%stata` here: this is Python, and only works on Colab.

Or, on Colab and Binder: in the file list on the left, right-click the file ▸ [Download]{.menu}.

## The result

```{r, echo=FALSE, results='asis'}
image_or("images/ex04-docx.png",
  "- `results.docx` and `results.pdf`: a title, a sentence with the coefficient filled in by Stata, Table 1, and the figure\n- Re-run the cells: both documents are re-created",
  '{.screenshot height="560"}')
```

## The whole notebook

- As PDF: [File]{.menu} ▸ [Print]{.menu} ▸ *Save as PDF*
- As a notebook: [File]{.menu} ▸ [Download]{.menu} ▸ [Download .ipynb]{.menu}
- Keep your changes: [File]{.menu} ▸ [Save a copy in Drive]{.menu}

## Bonus: back to Quarto

Quarto can turn the downloaded notebook into Word or PDF.

On posit.cloud: [Upload]{.menu} the `.ipynb` in the Files pane, then in the Terminal:

```bash
quarto render stata_colab_example.ipynb --to docx
quarto render stata_colab_example.ipynb --to typst
```

Quarto uses the outputs saved in the notebook: no Stata needed.

## Good to know

- Colab and Binder computers are **temporary**: files are deleted when the session ends. Download what you need!
- New session: run all cells again, paste the license again
- **Never share** a running session, or a notebook that contains your license
- The same notebook also runs on any Linux computer with Python
