#!/bin/bash
# Test part 1 (Quarto) in a container, the way participants run it on posit.cloud:
#   - render report.qmd to HTML, Word, and PDF (Typst)
#   - render the three "Your turn" variants
#   - compile paper.tex (part 2) against a stand-in for the Stata-generated
#     macro file, to check the LaTeX (tests/test-stata.sh uses the real one)
#
# Run from the main directory. Builds the image from the Dockerfile if needed.

set -e
[[ $(basename "$PWD") == "tests" ]] && cd ..

. ./.myconfig.sh
IMAGE=$space/$repo:$tag
docker image inspect $IMAGE > /dev/null 2>&1 || ./build.sh $tag

TMP=$(mktemp -d -p "$PWD" _test.XXXX)
trap 'rm -rf "$TMP"' EXIT

check() { # description test-arguments...
  local what=$1; shift
  if "$@"; then echo "ok:   $what"; else echo "FAIL: $what"; exit 1; fi
}

run() { # dir command...
  local dir=$1; shift
  docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp \
    -v "$PWD":/project -w "/project/$dir" $IMAGE "$@"
}

echo "=== Part 1: render report.qmd (HTML, Word, PDF)"
run examples/01-quarto-posit-cloud quarto render report.qmd
for f in report.html report.docx report.pdf; do
  check "$f" test -s examples/01-quarto-posit-cloud/$f
done

echo "=== Part 1: like a fresh posit.cloud project"
# a copy of what is in the repository, an empty R library, then exactly the
# participants' steps: source("libraries.R"), render
SIM="$TMP/posit-cloud"
mkdir -p "$SIM/project" "$SIM/lib"
git ls-files -co --exclude-standard -z | xargs -0 cp --parents -t "$SIM/project"
rm -rf "$SIM/project/examples/01-quarto-posit-cloud/report."{html,docx,pdf}
docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp \
  -e R_LIBS=/sim/lib -e R_LIBS_SITE=/nonexistent -e R_LIBS_USER=/nonexistent \
  -v "$SIM":/sim -w /sim/project rocker/verse:4.6.1 bash -c '
    Rscript -e "source(\"libraries.R\")" > /sim/install.log 2>&1 || { tail -30 /sim/install.log; exit 1; }
    cd examples/01-quarto-posit-cloud && quarto render report.qmd > /sim/render.log 2>&1 || { tail -30 /sim/render.log; exit 1; }
  '
for f in report.html report.docx report.pdf; do
  check "fresh project: $f" test -s "$SIM/project/examples/01-quarto-posit-cloud/$f"
done
# the installed versions are the ones in renv.lock
same_as_lockfile() { # package
  local want got
  want=$(python3 -I -c 'import json,sys; print(json.load(open("renv.lock"))["Packages"][sys.argv[1]]["Version"])' "$1")
  got=$(sed -n 's/^Version: //p' "$SIM/lib/$1/DESCRIPTION")
  [[ "$want" == "$got" ]]
}
for pkg in knitr rmarkdown haven; do
  check "fresh project: $pkg as in renv.lock" same_as_lockfile $pkg
done

echo "=== Part 1: the 'Your turn' exercises"
EX="$TMP/ex01"
mkdir -p "$EX"
# 1. only foreign cars
sed '/^auto <- read_dta/a auto <- subset(auto, foreign == 1)' \
  examples/01-quarto-posit-cloud/report.qmd > "$EX/turn1.qmd"
# 2. hide the code
sed '0,/^format:/s//execute:\n  echo: false\nformat:/' \
  examples/01-quarto-posit-cloud/report.qmd > "$EX/turn2.qmd"
# 3. fewer decimals
sed 's/digits = 1/digits = 0/' \
  examples/01-quarto-posit-cloud/report.qmd > "$EX/turn3.qmd"
for t in turn1 turn2 turn3; do
  run "$(basename "$TMP")/ex01" quarto render $t.qmd --to html > /dev/null 2>&1
  check "$t renders" test -s "$EX/$t.html"
done
check "turn1 has 22 foreign cars" grep -q "22 cars" "$EX/turn1.html"
check "report shows the code" grep -q 'Stata: summarize' examples/01-quarto-posit-cloud/report.html
check "turn2 hides the code" bash -c "! grep -q 'Stata: summarize' '$EX/turn2.html'"
check "turn3 has no decimals in the table" bash -c "grep -q '>6165<' '$EX/turn3.html'"

echo "=== Part 2: compile paper.tex (LaTeX check only, stand-in macros)"
EX="$TMP/ex02"
mkdir -p "$EX"
cp examples/02-stata-latex-macros/paper.tex "$EX/"
cat > "$EX/results_macros.tex" << 'EOF'
% Stand-in for the file written by policy_macros.do (LaTeX syntax check only)
\newcommand{\WelfareA}{2.3\%}
\newcommand{\WelfareB}{1.1\%}
\newcommand{\NReassA}{64}
\newcommand{\NReassB}{12}
\newcommand{\PreferredPolicy}{A}
\newcommand{\CoefMpg}{-49.5}
\newcommand{\SeMpg}{86.2}
\newcommand{\NObs}{74}
EOF
run "$(basename "$TMP")/ex02" pdflatex -interaction=nonstopmode -halt-on-error paper.tex > /dev/null
check "paper.pdf" test -s "$EX/paper.pdf"

echo "=== Part 4 bonus: Quarto renders a notebook without running it"
python3 - "$EX" << 'EOF'
import json, sys
nb = {"nbformat": 4, "nbformat_minor": 5,
      "metadata": {"kernelspec": {"name": "python3", "display_name": "Python 3", "language": "python"}},
      "cells": [
        {"cell_type": "markdown", "metadata": {}, "source": ["# A notebook"]},
        {"cell_type": "code", "metadata": {}, "execution_count": 1,
         "source": ["%%stata\n", "summarize price"],
         "outputs": [{"output_type": "stream", "name": "stdout", "text": ["(stored output)\n"]}]}]}
json.dump(nb, open(sys.argv[1] + "/notebook.ipynb", "w"))
EOF
run "$(basename "$TMP")/ex02" quarto render notebook.ipynb --to docx > /dev/null 2>&1
check "notebook.docx" test -s "$EX/notebook.docx"

echo "=== All Quarto/LaTeX tests passed"
