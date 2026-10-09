# Part 2: Stata → LaTeX macros

Never type a number into your paper: the do-file writes each number into `results_macros.tex` as a LaTeX macro, and `paper.tex` uses the macros.

Adapted from Florian Oswald (2026), ["Are Your in-text Numbers Correct? Do They Match Your Table?"](https://jpedataeditor.github.io/posts/20260910-latex-macros/), JPE Data Editor Blog.

| File | What it is |
|:-----|:-----------|
| `policy_macros.do` | The analysis. Writes `results_macros.tex`. |
| `paper.tex` | The paper. Reads `results_macros.tex`. |
| `expected/` | What you should get. |

## Steps

1. In Stata, go to this folder: **File** ▸ **Change Working Directory...**, or `cd "path/to/examples/02-stata-latex-macros"`.
2. Run the do-file: `do policy_macros.do`. It writes `results_macros.tex`, and shows it at the end. Do not edit that file by hand.
3. Compile `paper.tex`:
   - No LaTeX on your laptop? On [Overleaf](https://www.overleaf.com): **New Project** ▸ **Upload Project**, upload a ZIP file with `paper.tex` and `results_macros.tex`, click **Recompile**.
   - With LaTeX: open `paper.tex` in TeXworks or TeXShop, and click **Typeset**.
4. Change something: in `policy_macros.do`, change `102.3` to `100.5`, re-run the do-file, replace `results_macros.tex` on Overleaf, recompile. The paper now says that policy B is preferred, and you did not touch `paper.tex`.
