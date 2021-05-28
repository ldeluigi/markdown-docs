#!/bin/sh
set -e
WORKSPACE="${WORKSPACE:-${GITHUB_WORKSPACE:-/}}"
export REPOSITORY="${GITHUB_REPOSITORY:-Documentation}"
if [ -z "${GITHUB_SERVER_URL}" -a -z "${GITHUB_REPOSITORY}" ] ; then
    export GIT=1
    export REPO_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}"
fi
SRC=${1#.}
export SRC=${WORKSPACE%/}/${SRC#/}
export PLANTUML_JAVAOPTS="-Dplantuml.include.path=${SRC}"
RELATIVE_DST=${2#.}
RELATIVE_DST=${RELATIVE_DST#/}
RELATIVE_DST=${RELATIVE_DST%/}
DST=${WORKSPACE%/}/${RELATIVE_DST}
TMP_DST=/tmp/makedocs
echo "Source: ${SRC}; Destination: ${DST}"

#xvfb-run -a mkdocs build -c -f /usr/local/src/mkdocs.yml -d "${DST}"
rm -rf "${DST}"
mkdocs build -c -f /usr/local/src/mkdocs.yml -d "${TMP_DST}"
cp -r "${TMP_DST}" "${DST}"