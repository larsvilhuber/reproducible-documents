#!/bin/bash
# Test the Stata parts (2, 3, 4) in the AEA Data Editor's Stata containers.
#
# Needs your Stata license:
#   STATALIC=/path/to/stata.lic tests/test-stata.sh
#
# Options (environment variables):
#   STATA_IMAGE         image for all parts (default below; must match your license)
#   STATA_IMAGES_OLDER  space-separated list of older images on which parts 2 and 3
#                       are also run, e.g. "dataeditors/stata17:2024-02-13"
#                       (participants run these on their own laptops)
#
# Part 4 is tested as a do-file made from the notebook cells; the cells
# themselves run in Colab through PyStata (see tests/test-colab-notebook.sh).
#
# Writes reference outputs to examples/0[234]-*/expected/, which the slides
# show, and which participants can compare their results to.

set -e
[[ $(basename "$PWD") == "tests" ]] && cd ..

if [[ -z "$STATALIC" || ! -f "$STATALIC" ]]; then
  echo "Set STATALIC to the path of your stata.lic, e.g.:"
  echo "  STATALIC=/path/to/stata.lic $0"
  exit 2
fi

STATA_IMAGE=${STATA_IMAGE:-dataeditors/stata19_5-mp-i:2026-06-03}
. ./.myconfig.sh
IMAGE=$space/$repo:$tag
docker image inspect $IMAGE > /dev/null 2>&1 || ./build.sh $tag

TMP=$(mktemp -d -p "$PWD" _test.XXXX)
trap 'rm -rf "$TMP"' EXIT

check() { # description test-arguments...
  local what=$1; shift
  if "$@"; then echo "ok:   $what"; else echo "FAIL: $what"; exit 1; fi
}

# run a do-file in batch mode, in a directory below $TMP
stata() { # image dir dofile
  docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp \
    -v "$STATALIC":/usr/local/stata/stata.lic:ro \
    -v "$TMP/$2":/project -w /project \
    "$1" -b do "$3"
  # batch mode returns 0 even on error: check the log for an error code
  if grep -E '^r\([0-9]+\);' "$TMP/$2/${3%.do}.log"; then
    echo "FAIL: Stata error in $2/$3, see the log:"
    tail -20 "$TMP/$2/${3%.do}.log"
    exit 1
  fi
}

# does the text of a Word document contain this?
docx_has() { # file.docx text
  # ignore line breaks and indentation between XML tags (Stata pretty-prints)
  unzip -p "$1" word/document.xml | tr -d '\n' \
    | sed -e 's/>[[:space:]]*</></g' -e 's/<[^>]*>//g' | grep -qF -- "$2"
}
# does a Word document contain an image / a table?
docx_has_image() { unzip -l "$1" | grep -q 'media/'; }
docx_has_table() { unzip -p "$1" word/document.xml | grep -q '<w:tbl>'; }

# Part 2 and 3, on one Stata image
test_parts_2_3() { # image label
  local img=$1 tag=$2

  echo "=== Part 2 ($tag): policy_macros.do writes results_macros.tex"
  mkdir -p "$TMP/ex02-$tag"
  cp examples/02-stata-latex-macros/policy_macros.do examples/02-stata-latex-macros/paper.tex "$TMP/ex02-$tag/"
  stata "$img" "ex02-$tag" policy_macros.do
  local m="$TMP/ex02-$tag/results_macros.tex"
  check "WelfareA is 2.3%"   grep -qF '\newcommand{\WelfareA}{2.3\%}' "$m"
  check "WelfareB is 1.1%"   grep -qF '\newcommand{\WelfareB}{1.1\%}' "$m"
  check "NReassA is 64"      grep -qF '\newcommand{\NReassA}{64}' "$m"
  check "PreferredPolicy A"  grep -qF '\newcommand{\PreferredPolicy}{A}' "$m"
  check "CoefMpg is -49.5"   grep -qF '\newcommand{\CoefMpg}{-49.5}' "$m"
  check "NObs is 74"         grep -qF '\newcommand{\NObs}{74}' "$m"
  docker run --rm --user "$(id -u):$(id -g)" -e HOME=/tmp -v "$TMP/ex02-$tag":/project -w /project \
    $IMAGE pdflatex -interaction=nonstopmode -halt-on-error paper.tex > /dev/null
  check "paper.pdf compiles with the real macros" test -s "$TMP/ex02-$tag/paper.pdf"

  echo "=== Part 2 ($tag): 'Step 5: change something' flips the winner"
  sed -i 's/= 102.3 /= 100.5 /' "$TMP/ex02-$tag/policy_macros.do"
  stata "$img" "ex02-$tag" policy_macros.do
  check "PreferredPolicy is now B" grep -qF '\newcommand{\PreferredPolicy}{B}' "$m"
  # restore the original output for the reference copy
  cp examples/02-stata-latex-macros/policy_macros.do "$TMP/ex02-$tag/"
  stata "$img" "ex02-$tag" policy_macros.do

  echo "=== Part 3 ($tag): dyndoc report.md, docx"
  mkdir -p "$TMP/ex03-$tag"
  cp examples/03-stata-dyndoc-word/report.md "$TMP/ex03-$tag/"
  # exactly the commands participants type, plus the HTML variant
  printf 'dyndoc report.md, docx replace\ndyndoc report.md, replace\n' > "$TMP/ex03-$tag/run.do"
  stata "$img" "ex03-$tag" run.do
  check "report.docx created" test -s "$TMP/ex03-$tag/report.docx"
  check "report.html created" test -s "$TMP/ex03-$tag/report.html"
  check "price_mpg.png created" test -s "$TMP/ex03-$tag/price_mpg.png"
  check "Word text has 74 cars" docx_has "$TMP/ex03-$tag/report.docx" "74 cars"
  check "Word text has -49.5" docx_has "$TMP/ex03-$tag/report.docx" "-49.5 dollars"
  check "Word document has the figure" docx_has_image "$TMP/ex03-$tag/report.docx"
  # Stata output must stay a code block: otherwise its ---- lines become headings
  check "only the 3 section headings" test "$(grep -c '<h2' "$TMP/ex03-$tag/report.html")" -eq 3
  check "regression output is one code block" bash -c "tr '\n' ' ' < '$TMP/ex03-$tag/report.html' | grep -q '<pre><code>[^<]*Number of obs[^<]*_cons'"

  echo "=== Part 3 ($tag): 'Your turn' adds the R-squared"
  sed '/^<<dd_display: %5.1f _b\[mpg\]>> dollars./a The R-squared is <<dd_display: %4.2f e(r2)>>.' \
    examples/03-stata-dyndoc-word/report.md > "$TMP/ex03-$tag/report.md"
  stata "$img" "ex03-$tag" run.do
  check "R-squared is 0.29" docx_has "$TMP/ex03-$tag/report.docx" "R-squared is 0.29"
}

test_parts_2_3 "$STATA_IMAGE" main
for img in $STATA_IMAGES_OLDER; do
  test_parts_2_3 "$img" "$(echo "$img" | tr '/:' '__')"
done

echo "=== Part 4: the Colab cells, as a do-file"
mkdir -p "$TMP/ex04"
{
  for c in examples/04-jupyter-colab/cell-[123]-*.txt; do
    grep -v '^%%stata' "$c"
    # for the slides: the table as text, as shown below cell 1
    [[ $c == *cell-1-* ]] && echo 'collect export table1.txt, replace'
  done
} > "$TMP/ex04/cells.do"
stata "$STATA_IMAGE" ex04 cells.do
check "Table 1 in the output" grep -q "Table 1: Car prices and fuel efficiency" "$TMP/ex04/cells.log"
check "price_mpg.png created" test -s "$TMP/ex04/price_mpg.png"
check "results.docx created" test -s "$TMP/ex04/results.docx"
check "results.pdf created" test -s "$TMP/ex04/results.pdf"
check "Word text has -49.5" docx_has "$TMP/ex04/results.docx" "-49.5 dollars"
check "Word document has the table" docx_has_table "$TMP/ex04/results.docx"
check "Word document has the figure" docx_has_image "$TMP/ex04/results.docx"

echo "=== Saving reference outputs to examples/*/expected/"
mkdir -p examples/02-stata-latex-macros/expected examples/03-stata-dyndoc-word/expected examples/04-jupyter-colab/expected
cp "$TMP/ex02-main/results_macros.tex" "$TMP/ex02-main/paper.pdf" examples/02-stata-latex-macros/expected/
# the reference report is the one without the 'Your turn' change
cp examples/03-stata-dyndoc-word/report.md "$TMP/ex03-main/report.md"
stata "$STATA_IMAGE" ex03-main run.do
cp "$TMP/ex03-main/report.docx" "$TMP/ex03-main/report.html" "$TMP/ex03-main/price_mpg.png" examples/03-stata-dyndoc-word/expected/
cp "$TMP/ex04/results.docx" "$TMP/ex04/results.pdf" "$TMP/ex04/price_mpg.png" "$TMP/ex04/table1.txt" examples/04-jupyter-colab/expected/

echo "=== All Stata tests passed"
