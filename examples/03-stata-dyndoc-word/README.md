# Part 3: Stata `dyndoc` → Word

`report.md` is a Markdown file with Stata code inside `<<dd_...>>` tags. Stata's `dyndoc` command runs the code and creates a Word document (Stata 16 or later).

## Steps

1. In Stata, go to this folder: **File** ▸ **Change Working Directory...**, or `cd "path/to/examples/03-stata-dyndoc-word"`.
2. Create the Word document:

   ```stata
   dyndoc report.md, docx replace
   ```

3. Open `report.docx` (click the link in the Results window). Compare it to `expected/report.docx`.

## Your turn

1. Add the R-squared: after the sentence about the regression, add `The R-squared is <<dd_display: %4.2f e(r2)>>.`
2. Run `dyndoc report.md, docx replace` again. Close `report.docx` in Word first: Word locks the file.
3. HTML instead of Word: `dyndoc report.md, replace`

## Without Markdown: `putdocx` and `putpdf`

The same report, written with Stata commands instead of Markdown (Stata 15 or later):

```stata
do putdocx_report.do    // creates putdocx_report.docx
do putpdf_report.do     // creates putpdf_report.pdf
```

## The tags

| Tag | What it does |
|:----|:-------------|
| `<<dd_version: 2>>` | First line of every file |
| `<style>...</style>` | Smaller font for Stata output, so it fits on a Word page |
| `<<dd_do>>` ... `<</dd_do>>` | Run Stata code, show code and output (put `~~~~` around it, so the output keeps its layout) |
| `<<dd_do: quietly>>` | Run Stata code, show nothing |
| `<<dd_display: %5.1f _b[mpg]>>` | Put a number into the text |
| `<<dd_graph: saving(fig.png)>>` | Put the current graph into the document |

See `help dyndoc` in Stata.
