# Why reproducible documents?

## A sentence from a paper

> In our experiment, welfare increases by **2.3%** under policy A, while it increases by **1.1%** under policy B.

- Where do **2.3** and **1.1** come from?
- Were they updated after the referee asked for a new specification?
- Do they match the table?

## What Data Editors see

- Numbers in the text **cannot be traced** to the code (computed "by hand")
- Numbers in the text are **outdated** (the code changed, the text did not)

> This all too common pattern occurs frequently in our reproducibility checks.

[Florian Oswald, JPE Data Editor (2026)](https://jpedataeditor.github.io/posts/20260910-latex-macros/)

## The rule

:::{.bigrule}
**Never type a numeric result.**

**Read it from disk.**
:::

[Oswald (2026)](https://jpedataeditor.github.io/posts/20260910-latex-macros/)

## Copy and paste vs. reproducible documents

::::{.columns}
:::{.column width="50%"}

**Copy and paste**

[Stata]{.box} → [log]{.box} → *you* → [Word]{.box}

- Every revision: redo it by hand
- Mistakes are invisible

:::
:::{.column width="50%"}

**Reproducible document**

[Stata]{.box} → [file]{.box} → [document]{.box}

- Every revision: re-run
- The code *is* the documentation

:::
::::

## Not new

Literate programming: text and code in one place.

- Knuth's WEB (1984)
- Sweave, knitr, R Markdown, **Quarto**
- **Jupyter** notebooks
- Stata's own **dyndoc**

Today: you will try all of these.
