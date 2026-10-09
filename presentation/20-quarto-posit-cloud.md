# 1. Quarto on posit.cloud

## What is Quarto?

- Text (in **Markdown**) and code (R, Python, Julia, ...) in one file: `report.qmd`
- **Render**: run the code, insert the results, produce the document
- One source, many outputs: HTML, Word, PDF, ... (these slides are Quarto, too)

## What is posit.cloud?

- RStudio in your web browser
- Nothing to install, Quarto is included
- The free plan is enough for today

## Step 1: Log in

- Go to <https://posit.cloud>
- [Sign Up]{.menu} (free plan) or [Log In]{.menu}
- You can use your Google or GitHub account

## Step 2: Copy the materials into a new project

- In *Your Workspace*: [New Project]{.menu} ▸ [New Project from Git Repository]{.menu}
- Paste the URL: <`r REPOSITORY_URL`>
- Click [OK]{.menu}, and wait a minute

This is *your* copy. You cannot save it back to *my* copy.

## Step 3: Install the R packages (once)

In the **Console** (bottom left), type, then press Enter:

```r
source("libraries.R")
```

- Like `ssc install` in Stata
- Takes a minute or two, only needed once per project

## Step 4: Open the example

In the **Files** pane (bottom right):

[examples]{.menu} ▸ [01-quarto-posit-cloud]{.menu} ▸ [report.qmd]{.menu}

The file opens in the editor (top left).

## Anatomy of a `.qmd` file: the header

```{r, echo=FALSE, results='asis'}
show_file("examples/01-quarto-posit-cloud/report.qmd", from = 1, to = "---", lang = "yaml")
```

- Between the `---` lines: settings for the document (**YAML**)
- `format:` lists the documents you want

## Anatomy: text in Markdown

```{r, echo=FALSE, results='asis'}
show_file("examples/01-quarto-posit-cloud/report.qmd", from = "## About", to = "No copy and paste!", lang = "markdown")
```

| You type | `## About` | `**bold**` | `*italic*` | `- item` |
|:---------|:-----------|:-----------|:-----------|:---------|
| You get | a heading | **bold** | *italic* | a list |

## Anatomy: code chunks

```{r, echo=FALSE, results='asis'}
show_file("examples/01-quarto-posit-cloud/report.qmd", from = "#| label: load-data", to = "auto <- read_dta", lang = "r")
```

- A chunk starts with ```` ```{r} ```` and ends with ```` ``` ````
- `#|` lines are options (here: a label)
- The `# Stata:` comment shows the Stata equivalent

## Anatomy: numbers in the text

```{r, echo=FALSE, results='asis'}
show_file("examples/01-quarto-posit-cloud/report.qmd", from = "We use the 1978", to = "dollars.", lang = "markdown")
```

- `r inline_r("nrow(auto)")` is **inline code**: R computes it when you render
- The document says "The data contain `r AUTO_N` cars"
- **Never type a number!**

## Step 5: Render

- Click [Render]{.menu} (at the top of the editor)
- Quarto runs the code and creates `report.html`
- A preview opens: allow pop-ups if your browser asks

## Your first reproducible document

```{r, echo=FALSE, results='asis'}
image_or("images/ex01-html.png", "*(Rendered HTML document)*", '{.screenshot height="560"}')
```

## Step 6: Word and PDF

Open the [Terminal]{.menu} tab (next to *Console*) and type:

```bash
cd examples/01-quarto-posit-cloud
quarto render report.qmd
```

- Creates every format listed under `format:`: `report.html`, `report.docx`, `report.pdf`
- Only one format: `quarto render report.qmd --to docx`
- The PDF is made with **Typst**: no LaTeX needed

## Same source, three documents

::::{.columns}
:::{.column width="33%"}
**HTML**

```{r, echo=FALSE, results='asis'}
image_or("images/ex01-html.png", "*(HTML)*", '{.screenshot height="430"}')
```
:::
:::{.column width="33%"}
**Word**

```{r, echo=FALSE, results='asis'}
image_or("images/ex01-docx.png", "*(Word)*", '{.screenshot height="430"}')
```
:::
:::{.column width="33%"}
**PDF**

```{r, echo=FALSE, results='asis'}
image_or("images/ex01-pdf.png", "*(PDF)*", '{.screenshot height="430"}')
```
:::
::::

## Step 7: Download

In the **Files** pane:

- Tick the box next to `report.docx`
- [More]{.menu} ▸ [Export...]{.menu} ▸ [Download]{.menu}

## Your turn

Change something, click [Render]{.menu}, and watch the numbers change.

1. Only foreign cars: below the `read_dta()` line, add

   ```r
   auto <- subset(auto, foreign == 1)
   ```

2. Hide the code: in the header (between the `---` lines), add

   ```yaml
   execute:
     echo: false
   ```

3. Fewer decimals: change `digits = 1` to `digits = 0`

## Stata ↔ R

| Stata | R |
|:------|:--|
| `sysuse auto, clear` | `auto <- read_dta("https://www.stata-press.com/data/r19/auto.dta")` |
| `count` | `nrow(auto)` |
| `summarize price` | `summary(auto$price)` |
| `keep if foreign == 1` | `auto <- subset(auto, foreign == 1)` |
| `regress price mpg weight` | `lm(price ~ mpg + weight, data = auto)` |
| `twoway (scatter price mpg)` | `plot(auto$mpg, auto$price)` |
