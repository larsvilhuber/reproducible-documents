# Reproducible Documents

A hands-on tutorial for researchers who use Stata: four ways to put your results directly into your paper, without copying and pasting a single number.

- **Slides:** <https://larsvilhuber.github.io/reproducible-documents/> ([PDF](https://larsvilhuber.github.io/reproducible-documents/presentation.pdf))
- **Examples:** the [`examples/`](examples/) folder

## Follow along

| Part | Folder | You need |
|:-----|:-------|:---------|
| 1. Quarto (Markdown + R) on posit.cloud | [`examples/01-quarto-posit-cloud/`](examples/01-quarto-posit-cloud/) | A free [posit.cloud](https://posit.cloud) account |
| 2. Stata → LaTeX macros | [`examples/02-stata-latex-macros/`](examples/02-stata-latex-macros/) | Stata on your laptop; LaTeX or a free [Overleaf](https://www.overleaf.com) account |
| 3. Stata `dyndoc` → Word | [`examples/03-stata-dyndoc-word/`](examples/03-stata-dyndoc-word/) | Stata 16 or later on your laptop |
| 4. Jupyter + Stata on [Google Colab](https://colab.research.google.com/github/larsvilhuber/jupyter-stata-colab/blob/main/stata_colab_example.ipynb) or [Binder](https://mybinder.org/v2/gh/larsvilhuber/jupyter-stata-colab/HEAD?urlpath=%2Fdoc%2Ftree%2Fstata_colab_example.ipynb) | [`examples/04-jupyter-colab/`](examples/04-jupyter-colab/) | Your Stata license; a Google account for Colab (Binder needs none) |

To get the files on your laptop: click the green **Code** button above, then **Download ZIP**, and unzip.

For part 1, you do not need to download anything: on posit.cloud, choose **New Project** ▸ **New Project from Git Repository**, and paste `https://github.com/larsvilhuber/reproducible-documents`.

Part 4 uses the notebook in [larsvilhuber/jupyter-stata-colab](https://github.com/larsvilhuber/jupyter-stata-colab).

## For maintainers

### Structure

- `presentation/`: the slides (Quarto, reveal.js). `index.qmd` includes the numbered `*.md` files in order. Code shown on the slides is read from `examples/` by `presentation/helpers.R`, so the slides always show what is in the repository.
- `index.qmd`: the companion article (handout). It includes the `README.md` of each example, so the step-by-step instructions exist only once.
- `examples/`: what participants use. Files in `examples/*/expected/` are reference outputs created by `tests/test-stata.sh`.
- `renv.lock`: the R package versions. `libraries.R` installs them (on posit.cloud, in the Docker image, and in CI). As in the pillars template, `.Rprofile` is not committed, so renv is not activated automatically (no renv messages for participants on posit.cloud); run `renv::activate()` to use renv locally.
- `tests/`: tests, in containers (see below). `tests/build-notebook.py` also creates the solutions notebook in [larsvilhuber/jupyter-stata-colab](https://github.com/larsvilhuber/jupyter-stata-colab).

### Render

The Docker image is `rocker/verse` plus the packages in `renv.lock`; its name and tag are in `.myconfig.sh`.

```bash
./build.sh                       # build the image (tag from .myconfig.sh)
./render_test.sh presentation/render_presentation.sh   # slides, in presentation/_html/
./render_test.sh run.sh          # companion article, in _html/
./run-interactive.sh             # RStudio, like posit.cloud: http://localhost:8787
./ls-tags.sh                     # list local tags of the image
```

### Test

| Script | What it tests | Needs |
|:-------|:--------------|:------|
| `tests/test-quarto.sh` | Part 1 (HTML, Word, PDF; a fresh posit.cloud project; the "Your turn" exercises), LaTeX of part 2, Quarto rendering a notebook | Docker |
| `tests/test-stata.sh [version...]` | Parts 2, 3, and 4 (as a do-file), on every Stata version in `tests/stata-versions.txt` (16 to 19.5; part 4 needs 17+); saves reference outputs to `examples/*/expected/` | Docker, `STATALIC=/path/to/stata.lic` |
| `tests/test-colab-notebook.sh` | Part 4 end to end: the Colab notebook plus the new cells, through PyStata, then printed to Word and PDF with Quarto (as on Binder) | Docker, `STATALIC=/path/to/stata.lic` |
| `tests/make-screenshots.sh` | Creates the screenshots of the outputs shown on the slides | Docker, LibreOffice, poppler |
| `tests/check-overflow.mjs` | Every slide fits on the page: nothing cut off, no scrolling code | Docker (`astefanutti/decktape`) |

Check the slides after rendering them:

```bash
docker run --rm -v "$PWD/presentation/_html":/slides -v "$PWD/tests":/tests \
  --entrypoint node astefanutti/decktape /tests/check-overflow.mjs /slides/index.html
```

After changing the cells in `examples/04-jupyter-colab/`, rebuild the solutions notebook:

```bash
python3 tests/build-notebook.py ../jupyter-stata-colab/stata_colab_example.ipynb \
  ../jupyter-stata-colab/stata_colab_solutions.ipynb
```

Two GitHub Actions workflows: `compile-presentation.yml` renders the slides and the article, creates the PDF, and publishes everything to GitHub Pages. `tests.yml` runs separately, and does not hold up publication: it tests part 1, checks that every slide fits, runs the Stata tests on each version in parallel, and runs the Colab notebook (Stata tests use the `STATA_LIC_BASE64` repository secret, and are skipped if it is not set).

## License

Licensed under [CC BY-NC 4.0](LICENSE). Part 2 is adapted from Florian Oswald (2026), ["Are Your in-text Numbers Correct? Do They Match Your Table?"](https://jpedataeditor.github.io/posts/20260910-latex-macros/), JPE Data Editor Blog.
