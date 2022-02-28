#!/bin/sh
# Fail script if a command fails
set -e
# Setup
WORKSPACE="${WORKSPACE:-${GITHUB_WORKSPACE:-/}}"
if [ "${HIDE_REPOSITORY}" = "true" ]; then
    echo "Hiding repository location from documentation."
    unset GITHUB_REPOSITORY
fi
export TITLE="${TITLE:-${GITHUB_REPOSITORY:-Documentation}}"
# Source folder
SRC=${1#.}
# Check if documentation is from GitHub
if [ ! -z "${GITHUB_SERVER_URL}" -a ! -z "${GITHUB_REPOSITORY}" ] ; then
    export GIT=1
    export REPO_URL="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}"
    EDIT_URI="${SRC#/}"
    case "${GITHUB_REF}" in
        refs/heads/* )
            BRANCH_NAME=${GITHUB_REF#refs/heads/}
    esac
    if [ ! -z "${BRANCH_NAME}" ] ; then
        export EDIT_URI="edit/${BRANCH_NAME}/${EDIT_URI}"
    fi
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
echo "Source: ${SRC}; Destination: ${DST};"
# MkDocs default config
if [ ! -z "${ICON}" ] ; then
    export ICON=material/${ICON##*/}
fi
# Generate index if absent
if [ ! -f "${SRC}/index.md" -a ! -f "${SRC}/README.md" ] ; then
    echo "Index file (index.md) not found. It will be created using a script..."
    echo "# ${TITLE}" > "${SRC}/index.md"
    CLEAN_INDEX=true
fi
# Copy static template files
export SRC_THEME="${SRC}/theme"
mkdir -p "${SRC_THEME}" && cp -f /usr/local/src/theme.main.html "${SRC_THEME}/main.html" && cp -f /usr/local/src/theme.404.html "${SRC_THEME}/404.html"
CLEAN_THEME=true
# Convert docs to temp folder
( cd "${SRC}" ; mkdocs build -c -f /usr/local/src/mkdocs.yml -d "${TMP_DST}" )
# Start cleanup phase
echo "Cleanup..."
# Copy static assets to be added
mkdir -p "${TMP_DST}/js" && cp -f /usr/local/src/arithmatex.config.js "${TMP_DST}/js/arithmatex.config.js"
# Prepare destination
rm -rf "${DST}"
# Move results to destination
mv -f "${TMP_DST}" "${DST}"
# Cleanup
if [ "${CLEAN_INDEX}" = true ] ; then
    rm "${SRC}/index.md"
fi
if [ "${CLEAN_THEME}" = true ] ; then
    rm -rf "${SRC_THEME}"
fi
# End task
echo "Done"
