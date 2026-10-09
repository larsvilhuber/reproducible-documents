#!/bin/bash
# Create the screenshots of the example outputs that the slides show.
#
# Run from the main directory, after the examples have been run:
#   tests/test-quarto.sh   creates examples/01-quarto-posit-cloud/report.*
#   tests/test-stata.sh    creates examples/0[34]-*/expected/*
#
# Needs: docker (astefanutti/decktape, for Chromium), and on the host:
#   soffice (LibreOffice, to turn Word documents into PDF), pdftoppm (poppler)
# Screenshots of Stata outputs are skipped if those outputs do not exist yet.

set -e
[[ $(basename "$PWD") == "tests" ]] && cd ..

IMG=presentation/images
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# first page of a PDF, as PNG
pdf2png() { # in.pdf out.png
  pdftoppm -f 1 -l 1 -r 110 -png -singlefile "$1" "${2%.png}"
  echo "Created $2"
}

# Word document -> PDF -> PNG, optionally only part of the first page
docx2png() { # in.docx out.png [x y width height], in pixels at 110 dpi
  soffice --headless --convert-to pdf --outdir "$TMP" "$1" > /dev/null
  if [[ -n "$3" ]]; then
    pdftoppm -f 1 -l 1 -r 110 -png -singlefile -x "$3" -y "$4" -W "$5" -H "$6" \
      "$TMP/$(basename "${1%.docx}").pdf" "${2%.png}"
    echo "Created $2"
  else
    pdf2png "$TMP/$(basename "${1%.docx}").pdf" "$2"
  fi
}

# HTML page -> PNG (top of the page)
html2png() { # in.html out.png
  local dir file
  dir=$(cd "$(dirname "$1")" && pwd)
  file=$(basename "$1")
  docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp \
    -v "$dir":/in:ro -v "$PWD/$IMG":/out \
    --entrypoint chromium-browser astefanutti/decktape \
    --headless --no-sandbox --disable-gpu --hide-scrollbars \
    --window-size=1000,1100 --screenshot="/out/$(basename "$2")" "file:///in/$file" 2> /dev/null
  echo "Created $2"
}

# Part 1: Quarto
EX01=examples/01-quarto-posit-cloud
if [[ -f $EX01/report.html ]]; then
  html2png "$EX01/report.html" "$IMG/ex01-html.png"
  docx2png "$EX01/report.docx" "$IMG/ex01-docx.png"
  pdf2png  "$EX01/report.pdf"  "$IMG/ex01-pdf.png"
else
  echo "Skipping part 1: run tests/test-quarto.sh first"
fi

# Part 2: the compiled paper (top of the first page)
EX02=examples/02-stata-latex-macros/expected
if [[ -f $EX02/paper.pdf ]]; then
  pdftoppm -f 1 -l 1 -r 110 -png -singlefile -x 160 -y 230 -W 610 -H 400 "$EX02/paper.pdf" "$IMG/ex02-paper"
  echo "Created $IMG/ex02-paper.png"
else
  echo "Skipping part 2: run tests/test-stata.sh first"
fi

# Part 3: Stata dyndoc
EX03=examples/03-stata-dyndoc-word/expected
if [[ -f $EX03/report.docx ]]; then
  docx2png "$EX03/report.docx" "$IMG/ex03-docx.png" 90 90 760 660
  [[ -f $EX03/putdocx_report.docx ]] && docx2png "$EX03/putdocx_report.docx" "$IMG/ex03-putdocx.png" 90 90 760 900
else
  echo "Skipping part 3: run tests/test-stata.sh first"
fi

# Part 4: Colab (the figure of cell 1, the Python figure of cell 3,
# the Word document of cell 5)
EX04=examples/04-jupyter-colab/expected
if [[ -f $EX04/results.docx ]]; then
  cp "$EX04/price_mpg.png" "$IMG/ex04-figure.png"
  echo "Created $IMG/ex04-figure.png"
  docx2png "$EX04/results.docx" "$IMG/ex04-docx.png" 90 90 760 900
else
  echo "Skipping part 4: run tests/test-stata.sh first"
fi
if [[ -f $EX04/price_mpg_hist.png ]]; then
  cp "$EX04/price_mpg_hist.png" "$IMG/ex04-python-figure.png"
  echo "Created $IMG/ex04-python-figure.png"
else
  echo "Skipping the Python figure: run tests/test-colab-notebook.sh first"
fi
