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
    
    # Check file format
    if allowed_format.sh "$FORMAT" ; then
        TMP_FILE="$(cat /proc/sys/kernel/random/uuid)"
        # Add TOC if present as fourth arg
        if [ -f "$4" -a ! "${FILE}" = "contents.md" ] ; then
            cat "$4" "${SRC}${FILE}" > "${TMP_DIR}${TMP_FILE}"
        else
            cp "${SRC}${FILE}" "${TMP_DIR}${TMP_FILE}"
        fi
        # Load CSS stylesheets inside the css folder
        ESCAPED_CSS=""
        for CSS_FILE in "${SRC}"css/*.css; do
            [ -e "$CSS_FILE" ] || continue
            ESCAPED_CSS=$(printf '%s\n' "${ESCAPED_CSS}<link rel=\"stylesheet\" href=\"css/${CSS_FILE##*/}\">\n  " | sed -e 's/[\/&]/\\&/g')
        done

        RESULTNAME="${BASENAME}.html"
        echo "Converting ${SRC}${FILE} to ${DEST}${RESULTNAME}..."

        # Change links to point to html files instead of markdown
        sed -i -r 's/\[\[(.*?)\.(markdown|mdown|mkdn|md|mkd|mdwn|mdtxt|mdtext|text)\]\]/[[\1.html]]/g' "${TMP_DIR}${TMP_FILE}"
        sed -i -r 's/\[(.*)\]\((.*)\.(markdown|mdown|mkdn|md|mkd|mdwn|mdtxt|mdtext|text)\)/[\1](\2.html)/g' "${TMP_DIR}${TMP_FILE}"

        # Convert markdown to HTML
        markdown_py -x tables -x toc -x plantuml_markdown -c /pymd_config.yml "${TMP_DIR}${TMP_FILE}" > "${DEST}${RESULTNAME}"

        # Fetch a title
        ESCAPED_TITLE=$(printf '%s\n' "${GITHUB_REPOSITORY:-Documentation}" | sed -e 's/[\/&]/\\&/g')

        # Backup generated html to temp file
        cp "${DEST}${RESULTNAME}" "${TMP_DIR}${TMP_FILE}"
        
        # Copy the html template to destination
        cp /usr/local/src/template.html "${DEST}${RESULTNAME}"

        # Substitute strings
        sed -i "s/___CSS___/${ESCAPED_CSS}/g" "${DEST}${RESULTNAME}"
        sed -i "s/___TITLE___/${ESCAPED_TITLE}/g" "${DEST}${RESULTNAME}"
        sed -i -e "/___BODY___/r ${TMP_DIR}${TMP_FILE}" "${DEST}${RESULTNAME}"
        sed -i '1,/___BODY___/s///' "${DEST}${RESULTNAME}"
    else
        if resource_format.sh "$FORMAT" ; then
            cp -f "${SRC}${FILE}" "${DEST}${FILE}"
        fi
    fi
else
    >&2 echo "[ERROR] ${SRC}${FILE} is not a file";
    exit 1
fi
