# 3. Stata → Word

## Stata speaks Markdown

- `dyndoc`: Stata's own reproducible documents (since Stata 15)
- You write **Markdown**, with Stata code inside special **tags**
- Stata runs the code, and writes HTML, or **Word** (since Stata 16)
- No R, no Python, no LaTeX

## The source: `report.md` (1)

```{r, echo=FALSE, results='asis'}
show_file("examples/03-stata-dyndoc-word/report.md", from = 1, to = "<</dd_do>>", lang = "markdown")
```

## The source: `report.md` (2)

```{r, echo=FALSE, results='asis'}
show_file("examples/03-stata-dyndoc-word/report.md", from = "## The data", to = "## A figure", lang = "markdown")
```

## The source: `report.md` (3)

```{r, echo=FALSE, results='asis'}
show_file("examples/03-stata-dyndoc-word/report.md", from = "## A figure", lang = "markdown")
```

## The tags

| Tag | What it does |
|:----|:-------------|
| `<<dd_version: 2>>` | First line of every file |
| `<style>...</style>` | Smaller font for Stata output, so it fits on a Word page |
| `<<dd_do>>` ... `<</dd_do>>` | Run Stata code, show code and output (put `~~~~` around it) |
| `<<dd_do: quietly>>` | Run Stata code, show nothing |
| `<<dd_display: %5.1f _b[mpg]>>` | Put a number into the text |
| `<<dd_graph: saving(fig.png)>>` | Put the current graph into the document |

## Step 1: Go to the folder

[File]{.menu} ▸ [Change Working Directory...]{.menu} ▸ `examples/03-stata-dyndoc-word`

Or:

```stata
cd "C:/Users/you/Downloads/reproducible-documents-main/examples/03-stata-dyndoc-word"
```

## Step 2: Create the Word document

In the Command window:

```stata
dyndoc report.md, docx replace
```

- Stata runs all the code in `report.md`
- It creates `report.docx` (and `price_mpg.png`) in the same folder
- Click the link in the Results window to open it

## The result

```{r, echo=FALSE, results='asis'}
image_or("images/ex03-docx.png",
  "- A Word document with a title, text with numbers filled in, the regression output, and the figure\n- Same text, same numbers, every time you run it",
  '{.screenshot height="560"}')
```

## Your turn

1. Add the R-squared to the text. After the regression sentence, add:

   ```markdown
   The R-squared is <<dd_display: %4.2f e(r2)>>.
   ```

2. Run `dyndoc report.md, docx replace` again
3. Try HTML instead of Word: `dyndoc report.md, replace`

**Close** `report.docx` in Word before you re-run: Word locks the file.
