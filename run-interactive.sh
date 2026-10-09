#!/bin/bash
# Start RStudio in a container, with this project mounted: like posit.cloud,
# but on your own computer. Then open http://localhost:8787
#
# Uses the image built from the Dockerfile (rocker/verse + libraries.R).

. ./.myconfig.sh
image=$space/$repo:$tag

if [[ "$1" == "-h" ]]
then
cat << EOF
$0

will start RStudio in the $image container, on port 8787
EOF
exit 0
fi

PWD=$(pwd)

case $USER in
  codespace)
  WORKSPACE=/workspaces
  ;;
  *)
  WORKSPACE=$PWD
  ;;
esac

# build the image if necessary
docker image inspect $image > /dev/null 2>&1 || bash ./build.sh $tag

[[ -d "$PWD/.cache" ]] || mkdir "$PWD/.cache"
DOCKEREXTRA="$DOCKEREXTRA -v $PWD/.cache:/home/rstudio/.cache"

docker run $DOCKEREXTRA -e DISABLE_AUTH=true -v "$WORKSPACE":/home/rstudio/project -w /home/rstudio/project --rm -p 8787:8787 $image
