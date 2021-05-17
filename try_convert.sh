#!/bin/sh
set -e 
SRC="${1%/}/"
FILE="${2#/}"
DEST="${3%/}/"
if [ -f "${SRC}${FILE}" ]; then
    BASENAME="${FILE%%.*}"
    FORMAT="${FILE#*.}"
    if allowed_format.sh "$FORMAT" ; then
        RESULTNAME="${BASENAME}.html"
        echo "Converting ${SRC}${FILE} to ${DEST}${RESULTNAME}..."
        sed 's/\[\[(.*?)\.(markdown|mdown|mkdn|md|mkd|mdwn|mdtxt|mdtext|text)\]\]/[[\1.html]]/g' | sed 's/\[(.*)\]\((.*)\.(markdown|mdown|mkdn|md|mkd|mdwn|mdtxt|mdtext|text)\)/[\1](\2.html)/g' < "${SRC}${FILE}" > "${SRC}${FILE}"
        markdown_py -x plantuml_markdown -c /pymd_config.yml "${SRC}${FILE}" > "${DEST}${RESULTNAME}"
    else
        cp -f "${SRC}${FILE}" "${DEST}${FILE}"
    fi
else
    >&2 echo "[ERROR] ${SRC}${FILE} is not a file";
    exit 1
fi
