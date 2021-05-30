#!/bin/sh
# Fail script if a command fails
set -e
# Setup
WORKSPACE="${WORKSPACE:-${GITHUB_WORKSPACE:-/}}"
export REPOSITORY="${GITHUB_REPOSITORY:-Documentation}"
# Source folder
SRC=${1#.}
# Check if documentation is from GitHub
if [ ! -z "${GITHUB_SERVER_URL}" -a ! -z "${GITHUB_REPOSITORY}" ] ; then
    export GIT=1
    export REPO_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}"
    export EDIT_URI="${SRC#/}"
fi
export SRC=${WORKSPACE%/}/${SRC#/}
# PlantUML !include root folder
export PLANTUML_JAVAOPTS="-Dplantuml.include.path=${SRC}"
# Destination folder
RELATIVE_DST=${2#.}
RELATIVE_DST=${RELATIVE_DST#/}
RELATIVE_DST=${RELATIVE_DST%/}
DST=${WORKSPACE%/}/${RELATIVE_DST}
# Temp files
TMP_DST=/tmp/makedocs
echo "Source: ${SRC}; Destination: ${DST}"
# Generate index if absent
if [ ! -f "${SRC}/index.md" ] ; then
    echo "Index file (index.md) not found. It will be created using a script..."
    echo "# ${REPOSITORY}" > "${SRC}/index.md"
    CLEAN_INDEX=true
fi
# Convert docs to temp folder
mkdocs build -c -f /usr/local/src/mkdocs.yml -d "${TMP_DST}"
# Copy static assets to be added
cp -f /usr/local/src/arithmatex.config.js "${TMP_DST}/js/arithmatex.config.js"
# Prepare destination
rm -rf "${DST}"
# Move results to destination
mv -f "${TMP_DST}" "${DST}"
# Cleanup
if [ "${CLEAN_INDEX}" = true ] ; then
    rm "${SRC}/index.md"
fi
