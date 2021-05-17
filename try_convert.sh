#!/bin/sh
set -e 
SRC="${1%/}/"
FILE="${2#/}"
DEST="${3%/}/"

# Temp directory
TMP_DIR=/tmp/try_convert/
mkdir -p "$TMP_DIR"

if [ -f "${SRC}${FILE}" ]; then
    BASENAME="${FILE%%.*}"
    FORMAT="${FILE#*.}"
    if allowed_format.sh "$FORMAT" ; then
        # Add TOC if present as fourth arg
        if [ -f "$4" -a ! "${FILE}" = "contents.md" ] ; then
            TMP_FILE="${FILE##*/}"
            cat "$4" "${SRC}${FILE}" > "${TMP_DIR}${TMP_FILE}"
            mv "${TMP_DIR}${TMP_FILE}" "${SRC}${FILE}"
        fi
        RESULTNAME="${BASENAME}.html"
        echo "Converting ${SRC}${FILE} to ${DEST}${RESULTNAME}..."
        # sed 's/\[\[(.*?)\.(markdown|mdown|mkdn|md|mkd|mdwn|mdtxt|mdtext|text)\]\]/[[\1.html]]/g' | sed 's/\[(.*)\]\((.*)\.(markdown|mdown|mkdn|md|mkd|mdwn|mdtxt|mdtext|text)\)/[\1](\2.html)/g' < "${SRC}${FILE}" > "${SRC}${FILE}"
        markdown_py -x plantuml_markdown -c /pymd_config.yml "${SRC}${FILE}" > "${DEST}${RESULTNAME}"
    else
        cp -f "${SRC}${FILE}" "${DEST}${FILE}"
    fi
else
    >&2 echo "[ERROR] ${SRC}${FILE} is not a file";
    exit 1
fi
