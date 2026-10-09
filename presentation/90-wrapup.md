# Wrapping up

## Which one should I use?

| If you... | Use |
|:----------|:----|
| write your paper in **LaTeX** | Stata → LaTeX macros (2) |
| write your paper in **Word** | Stata `dyndoc` (3), or `putdocx` (4) |
| want to explore, and show your work step by step | Jupyter + Stata (4) |
| want one source for HTML, Word, PDF, and slides | Quarto (1) |

They can be combined: e.g., Stata writes the numbers, Quarto writes the paper.

## The common ideas

- **One source of truth**: the number lives in exactly one place
- **Never type a number**: the code puts it into the document
- **Re-run everything**: from data to document, in one go
- **Keep it all**: code, generated files, and documents go into your replication package

## Learn more

- Quarto: <https://quarto.org/docs/get-started/>
- Stata `dyndoc`: `help dyndoc`, and the [Reporting manual](https://www.stata.com/manuals/rpt.pdf)
- Stata `putdocx`, `putpdf`, `etable`: `help putdocx`, `help putpdf`, `help etable`
- PyStata (Stata in Jupyter): <https://www.stata.com/python/pystata19/>
- Oswald (2026): <https://jpedataeditor.github.io/posts/20260910-latex-macros/>
- The Colab notebook: <`r COLAB_REPOSITORY_URL`>
