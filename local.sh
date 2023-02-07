#!/bin/bash

set -e
export MSYS_NO_PATHCONV=1

if [ -z "$1" -o -z "$2" ]; then
    echo "Usage: $0 <path to a src folder> <path to a dest folder>"
    exit 1
fi

docker build -t mdocs-local .
docker run --rm -e 'WORKSPACE=/github/workspace' -v "$(pwd):/github/workspace" mdocs-local "${1%/}" "${2%/}"
