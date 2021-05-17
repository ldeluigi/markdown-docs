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
        markdown_py -x plantuml_markdown -c /pymd_config.yml "${SRC}${FILE}" > "${DEST}${RESULTNAME}"
    else
        cp -f "${SRC}${FILE}" "${DEST}${FILE}"
    fi
else
    >&2 echo "[ERROR] ${SRC}${FILE} is not a file";
    exit 1
fi
