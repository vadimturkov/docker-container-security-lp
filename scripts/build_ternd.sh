#!/bin/bash

readonly TMPDIR=$PWD/tmp
readonly IMAGE_NAME=ternd

if [ ! -d $TMPDIR ]; then 
  mkdir tmp
fi

if [ ! -d $TMPDIR/tern ]; then
  git clone --quiet https://github.com/tern-tools/tern $TMPDIR/tern
fi

if [[ "$(docker images -q $IMAGE_NAME)" == "" ]]; then
  docker build $TMPDIR/tern/docker -t $IMAGE_NAME > /dev/null
fi
