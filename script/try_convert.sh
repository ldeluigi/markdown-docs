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
        
        RESULTNAME="${BASENAME}.html"
        echo "Converting ${SRC}${FILE} to ${DEST}${RESULTNAME}..."

        # Calculate depth for resource linking
        FILE_SLASHES=${FILE//[!\/]}
        FILE_DEPTH_PARENTS=${FILE_SLASHES//\//../}

        # Add navbar
        echo -e "<nav><a href=\"${FILE_DEPTH_PARENTS}contents.html\">TOC</a>\n<a href=\"${FILE_DEPTH_PARENTS}index.html\">HOME</a></nav>\n" > "${DEST}${RESULTNAME}"

        # Prepare source markdown
        cp "${SRC}${FILE}" "${TMP_DIR}${TMP_FILE}"

        # Load CSS stylesheets inside the css folder
        ESCAPED_CSS=""
        for CSS_FILE in "${SRC}"css/*.css; do
            [ -e "$CSS_FILE" ] || continue
            ESCAPED_CSS="${ESCAPED_CSS}<link rel=\"stylesheet\" href=\"${FILE_DEPTH_PARENTS}css/${CSS_FILE##*/}\">  "
        done
        ESCAPED_CSS=$(printf '%s\n' "${ESCAPED_CSS}" | sed -e 's/[\/&]/\\&/g')

        # Load JS scripts inside the js folder
        ESCAPED_JS=""
        for JS_FILE in "${SRC}"js/*.js; do
            [ -e "$JS_FILE" ] || continue
            ESCAPED_JS="${ESCAPED_JS}<script defer src=\"${FILE_DEPTH_PARENTS}js/${JS_FILE##*/}\"></script>  "
        done
        ESCAPED_JS=$(printf '%s\n' "${ESCAPED_JS}" | sed -e 's/[\/&]/\\&/g')
        
        # Convert markdown to HTML
        markdown_py -x tables -x toc -x plantuml_markdown -c /pymd_config.yml "${TMP_DIR}${TMP_FILE}" >> "${DEST}${RESULTNAME}"

        # Change links to point to html files instead of markdown
        sed -i -r 's/(<a.+href=["'"'"'][\/\.].+\.)(markdown|mdown|mkdn|md|mkd|mdwn|mdtxt|mdtext|text)(["'"'"'].*>)/\1html\3/g' "${DEST}${RESULTNAME}"

        # Fetch a title
        ESCAPED_TITLE=$(printf '%s\n' "${GITHUB_REPOSITORY:-Documentation}" | sed -e 's/[\/&]/\\&/g')

        # Backup generated html to temp file
        cp "${DEST}${RESULTNAME}" "${TMP_DIR}${TMP_FILE}"
        
        # Copy the html template to destination
        cp /usr/local/src/template.html "${DEST}${RESULTNAME}"

        # Substitute strings
        sed -i "s/___CSS___/${ESCAPED_CSS}/g" "${DEST}${RESULTNAME}"
        sed -i "s/___JS___/${ESCAPED_JS}/g" "${DEST}${RESULTNAME}"
        sed -i "s/___TITLE___/${ESCAPED_TITLE}/g" "${DEST}${RESULTNAME}"
        sed -i -e "/___BODY___/r ${TMP_DIR}${TMP_FILE}" "${DEST}${RESULTNAME}"
        sed -i '1,/___BODY___/s///' "${DEST}${RESULTNAME}"
        sed -i 's/<!--__TOC_START__-->/<div class="toc">/g' "${DEST}${RESULTNAME}"
        sed -i "s/<!--__TOC_END__-->/<\/div>/g" "${DEST}${RESULTNAME}"
    else
        if resource_format.sh "$FORMAT" ; then
            cp -f "${SRC}${FILE}" "${DEST}${FILE}"
        fi
    fi
else
    >&2 echo "[ERROR] ${SRC}${FILE} is not a file";
    exit 1
fi
