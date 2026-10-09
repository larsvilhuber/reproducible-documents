#!/bin/bash

# Call this from the main directory, go up a directory if we are in the presentation directory
if [[ $(basename "$PWD") == "presentation" ]]; then
    cd ..
fi

# The output directory is relative to presentation/: presentation/_html
[[ -z $QUARTO_OPTS ]] && QUARTO_OPTS="--output-dir _html"
quarto render presentation/index.qmd $QUARTO_OPTS
