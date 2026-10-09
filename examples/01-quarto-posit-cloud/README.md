# Part 1: Quarto on posit.cloud

`report.qmd` is a Quarto document: text in Markdown, plus R code that loads Stata's `auto` data, makes a table, runs a regression, and draws a figure. Each code chunk shows the equivalent Stata command.

## Steps

1. Log in at <https://posit.cloud> (the free plan is enough).
2. **New Project** ▸ **New Project from Git Repository**, paste `https://github.com/larsvilhuber/reproducible-documents`, click **OK**.
3. In the **Console**, install the R packages (once):

   ```r
   source("libraries.R")
   ```

4. In the **Files** pane, open `examples/01-quarto-posit-cloud/report.qmd`.
5. Click **Render**. You get `report.html`.
6. For Word and PDF, in the **Terminal** tab:

   ```bash
   cd examples/01-quarto-posit-cloud
   quarto render report.qmd
   ```

   This creates `report.html`, `report.docx`, and `report.pdf` (the PDF is made with Typst, so no LaTeX is needed). For only one format: `quarto render report.qmd --to docx`.
7. To download a file: in the **Files** pane, tick the box next to it, then **More** ▸ **Export...** ▸ **Download**.

## Your turn

Change something, render again, and watch the numbers change:

1. Only foreign cars: below the `read_dta()` line, add `auto <- subset(auto, foreign == 1)`.
2. Hide the code: in the header (between the `---` lines), add

   ```yaml
   execute:
     echo: false
   ```

3. Fewer decimals: change `digits = 1` to `digits = 0`.
