repo=reproducible-documents
space=larsvilhuber
dockerrepo=$(echo $space/$repo | tr [A-Z] [a-z])
case $USER in
  codespace)
  WORKSPACE=/workspaces
  ;;
  *)
  #WORKSPACE=$HOME/Workspace/git/
  WORKSPACE=$PWD
  ;;
esac
tag=2026-10-09
