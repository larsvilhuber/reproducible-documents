#!/bin/bash


PWD=$(pwd)
. ${PWD}/.myconfig.sh

if [[ "$1" == "-h" ]]
then
cat << EOF
$0 (tag)

will start interactive environment for tag (TAG)
EOF
exit 0
fi

if [[ -z "$1" ]]
then
  DOCKERXTRA="-it"
else
  DOCKERXTRA=""
fi

echo "Using tag = $tag"

case $USER in
  codespace)
  WORKSPACE=/workspaces
  ;;
  *)
  WORKSPACE=$PWD
  ;;
esac
  
# pull the docker if necessary
set -ev

echo $space/$repo
tag_present=$(docker images --format '{{.Tag}}' $space/$repo | grep -x $tag)

if [[ -z "$tag_present" ]]
then
  echo "Building $space/$repo:$tag"
  bash ./build.sh $tag
else  
  echo "Found $space/$repo:$tag"
fi

# map cache if present

if [[ -d $WORKSPACE/.cache ]]
then
  echo "Found cache"
  DOCKERXTRA="$DOCKERXTRA -v $WORKSPACE/.cache:/home/rstudio/.cache"
fi


docker run  $DOCKERXTRA --user rstudio -v "$WORKSPACE":/home/rstudio/project -w /home/rstudio/project --entrypoint /bin/bash --rm  $space/$repo:$tag $@
