# Today

## Four ways to make a reproducible document

|       | You write | It runs on | You get |
|:------|:----------|:-----------|:--------|
| **1** | Quarto (Markdown + R) | posit.cloud (browser) | HTML, Word, PDF |
| **2** | Stata do-file + LaTeX | your laptop | PDF |
| **3** | Stata `dyndoc` (Markdown) | your laptop | Word |
| **4** | Jupyter notebook + Stata | Colab or Binder (browser) | Word, PDF |

From simple to more complex. Same data everywhere: Stata's `auto` dataset.

## Do not type numbers

```stata
sysuse auto, clear
regress price mpg weight
```

One more mile per gallon changes the price by **`r AUTO_COEF_MPG`** dollars.

- This number appears in all four documents
- You will **never type it**

## What you need

- A web browser
- A free [posit.cloud](https://posit.cloud) account (log in with Google or GitHub)
- **Stata 16 or later** on your laptop
- (optional) **Google account** for Google Colab
- Your **Stata license file** `stata.lic`
- Optional: a free [Overleaf](https://www.overleaf.com) account (to compile LaTeX)

## The materials

All examples are in one repository: <`r REPOSITORY_URL`>

| Folder | Part |
|:-------|:-----|
| `examples/01-quarto-posit-cloud/` | 1. Quarto on posit.cloud |
| `examples/02-stata-latex-macros/` | 2. Stata → LaTeX |
| `examples/03-stata-dyndoc-word/` | 3. Stata → Word |
| `examples/04-jupyter-colab/` | 4. Jupyter + Stata on Colab or Binder |

To get them on your laptop: [Code]{.menu} ▸ [Download ZIP]{.menu}, then unzip.
