#!/bin/sh
set -e 
set -o pipefail
MODE="$1"
if [ "$MODE" = "HTML" -o "$MODE" = "html" -o "$MODE" = "gh-pages" ] ; then
    SRC=${2#.}
    SRC=${GITHUB_WORKSPACE%/}/${SRC#/}
    RELATIVE_DEST=${3#.}
    RELATIVE_DEST=${RELATIVE_DEST#/}
    RELATIVE_DEST=${RELATIVE_DEST%/}
    DEST=${GITHUB_WORKSPACE%/}/${RELATIVE_DEST}
    echo "Source: ${SRC}; Destination: ${DEST}/"

    if [ ! -d "${DEST}/" ] ; then
        if mkdir -p "${DEST}" ; then
            echo "[INFO] Created output directory ${DEST}"
        else
            >&2 echo "[ERROR] ${DEST} is not valid destination path"
            exit 1
        fi
    fi

    if [ -d "${SRC}" ] ; then
        export PLANTUML_JAVAOPTS="-Dplantuml.include.path=${SRC}"
        (cd "${SRC}" ; find * -type d ! -path "${RELATIVE_DEST}" ! -path .git ! -path .github -exec mkdir -p ${DEST}/{} \;)
        (cd "${SRC}" ; find * -type f ! -path "${RELATIVE_DEST}" ! -path .git ! -path .github -exec try_convert.sh "${SRC}" "{}" "${DEST}/" \;)
    else
        if [ -f "${SRC}" ]; then
            try_convert.sh "${SRC%/*}/" "${SRC##*/}" "${DEST}/"
        else
            >&2 echo "[ERROR] ${SRC} is not valid source";
            exit 1
        fi
    fi
    echo "Done. Result:"
    tree $DEST
elif [ "$MODE" = "Markdown" -o "$MODE" = "markdown" -o "$MODE" = "md" ] ; then
    >&2 echo "[ERROR] ${MODE} is currently not supported";
else
    >&2 echo "[ERROR] ${MODE} is not a valide mode";
fi
