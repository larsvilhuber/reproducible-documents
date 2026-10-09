#!/bin/bash
# End-to-end test of part 4: run the Colab notebook from
# larsvilhuber/jupyter-stata-colab, with the cells participants type
# (examples/04-jupyter-colab/cell-*.txt, except download) appended by tests/build-notebook.py
# (as in the solutions notebook), through PyStata, in a plain Python container
# (Colab-like: Stata is installed by the notebook).
#
# Needs your Stata license (SE or MP; the notebook uses SE by default):
#   STATALIC=/path/to/stata.lic tests/test-colab-notebook.sh
#
# Options (environment variables):
#   COLAB_REPO   where to get the notebook: a URL (default: GitHub, main branch),
#                or a local checkout, e.g. ../jupyter-stata-colab
#
# With --build-only, only assembles the notebook (no license needed).

set -e
[[ $(basename "$PWD") == "tests" ]] && cd ..

COLAB_REPO=${COLAB_REPO:-https://raw.githubusercontent.com/larsvilhuber/jupyter-stata-colab/main}
PYTHON_IMAGE=python:3.12-bookworm

if [[ "$1" != "--build-only" && ( -z "$STATALIC" || ! -f "$STATALIC" ) ]]; then
  echo "Set STATALIC to the path of your stata.lic, e.g.:"
  echo "  STATALIC=/path/to/stata.lic $0"
  exit 2
fi

TMP=$(mktemp -d -p "$PWD" _test.XXXX)
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/nb"
for f in stata_colab_example.ipynb setup_stata.py; do
  if [[ -d "$COLAB_REPO" ]]; then
    cp "$COLAB_REPO/$f" "$TMP/nb/"
  else
    curl -sfL "$COLAB_REPO/$f" -o "$TMP/nb/$f"
  fi
done

# Append the cells, exactly as typed
docker run --rm --user "$(id -u):$(id -g)" -v "$PWD":/repo:ro -v "$TMP/nb":/nb -w /nb $PYTHON_IMAGE \
  python3 -I /repo/tests/build-notebook.py stata_colab_example.ipynb notebook.ipynb

if [[ "$1" == "--build-only" ]]; then
  tail -c 600 "$TMP/nb/notebook.ipynb"
  exit 0
fi

# Run it. The license is read from the mounted file inside the container,
# and passed to the notebook in STATA_LIC_BASE64 (the notebook's non-interactive mode).
docker run --rm -v "$TMP/nb":/nb -w /nb \
  -v "$STATALIC":/run/stata.lic:ro \
  $PYTHON_IMAGE bash -c '
    set -e
    apt-get update -qq && apt-get install -y -qq libncurses6 libcurl4 fontconfig fonts-dejavu-core fonts-liberation > /dev/null
    pip install -q nbconvert ipykernel pandas matplotlib
    export STATA_LIC_BASE64=$(base64 -w0 /run/stata.lic)
    jupyter nbconvert --to notebook --execute --ExecutePreprocessor.timeout=900 \
      --output executed.ipynb notebook.ipynb
    # print the notebook, as on the Binder slide (Quarto from pip, saved results)
    pip install -q quarto-cli
    quarto render executed.ipynb --to docx
    quarto render executed.ipynb --to typst
    quarto render executed.ipynb --to docx -M echo:false -o executed-noecho.docx
    chown -R '"$(id -u):$(id -g)"' /nb
  '

check() { # description test-arguments...
  local what=$1; shift
  if "$@"; then echo "ok:   $what"; else echo "FAIL: $what"; exit 1; fi
}
NB="$TMP/nb/executed.ipynb"
check "Table 1 in the notebook" grep -q "Table 1: Car prices and fuel efficiency" "$NB"
# the new cell 1 must show the figure (PyStata shows graphs as SVG or PNG)
cell1_has_figure() {
  python3 -I - "$NB" << 'EOF'
import json, sys
cells = json.load(open(sys.argv[1]))["cells"]
cell = next(c for c in cells if "graph export price_mpg.png" in "".join(c["source"]))
kinds = {k for o in cell["outputs"] for k in o.get("data", {})}
sys.exit(0 if kinds & {"image/svg+xml", "image/png"} else 1)
EOF
}
check "cell 1 shows the figure" cell1_has_figure
# the Python cells: a sentence with the number from Stata, and a figure
cell_output_has() { # text-in-the-cell output-type text-in-the-output
  python3 -I - "$NB" "$1" "$2" "$3" << 'EOF'
import json, sys
nb, code, kind, text = sys.argv[1:]
cell = next(c for c in json.load(open(nb))["cells"] if code in "".join(c["source"]))
data = [o.get("data", {}).get(kind) for o in cell["outputs"]]
data = ["".join(d) if isinstance(d, list) else d for d in data if d]
sys.exit(0 if data and text in "".join(data) else 1)
EOF
}
check "cell 2 writes the sentence with -49.5" cell_output_has "Scalar.getValue" "text/markdown" "**-49.5** dollars"
check "cell 3 shows the Python figure" cell_output_has "inset_axes" "image/png" ""
check "price_mpg_hist.png created" test -s "$TMP/nb/price_mpg_hist.png"
# the printed notebook
DOCX="$TMP/nb/executed.docx"
docx_text() { unzip -p "$1" word/document.xml | tr -d '\n' | sed -e 's/<[^>]*>//g'; }
check "Word: created" test -s "$DOCX"
check "PDF: created" test -s "$TMP/nb/executed.pdf"
check "Word: Table 1" bash -c "$(declare -f docx_text); docx_text '$DOCX' | grep -qF 'Table 1: Car prices and fuel efficiency'"
check "Word: the sentence with -49.5" bash -c "$(declare -f docx_text); docx_text '$DOCX' | grep -qF -- '-49.5 dollars'"
check "Word: the figures" bash -c "[[ \$(unzip -l '$DOCX' | grep -c 'media/') -ge 2 ]]"
check "Word, -M echo:false: no code" bash -c "$(declare -f docx_text); ! docx_text '$TMP/nb/executed-noecho.docx' | grep -qF 'inset_axes'"
check "no license in the notebook" bash -c "! grep -qF \"\$(base64 -w0 '$STATALIC')\" '$NB'"
# reference outputs for the slides (the Stata outputs come from tests/test-stata.sh)
mkdir -p examples/04-jupyter-colab/expected
cp "$TMP/nb/price_mpg_hist.png" examples/04-jupyter-colab/expected/
cp "$TMP/nb/executed.docx" examples/04-jupyter-colab/expected/notebook.docx
cp "$TMP/nb/executed.pdf" examples/04-jupyter-colab/expected/notebook.pdf
echo "=== Colab notebook test passed"
