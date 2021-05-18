#!/bin/sh
set -e 
MODE="$1"
if [ "$MODE" = "HTML" -o "$MODE" = "html" -o "$MODE" = "gh-pages" ] ; then
    SRC=${2#.}
    SRC=${GITHUB_WORKSPACE%/}/${SRC#/}
    RELATIVE_DEST=${3#.}
    RELATIVE_DEST=${RELATIVE_DEST#/}
    RELATIVE_DEST=${RELATIVE_DEST%/}
    DEST=${GITHUB_WORKSPACE%/}/${RELATIVE_DEST}
    echo "Source: ${SRC}; Destination: ${DEST}/"

    # Output directory
    if [ ! -d "${DEST}/" ] ; then
        if mkdir -p "${DEST}" ; then
            echo "[INFO] Created output directory ${DEST}"
        else
            >&2 echo "[ERROR] ${DEST} is not valid destination path"
            exit 1
        fi
    fi

    # Source directory
    if [ -d "${SRC}" ] ; then
        export PLANTUML_JAVAOPTS="-Dplantuml.include.path=${SRC}"
        TOC="${SRC}contents.md"

        # Index is the entrypoint of every website so it's mandatory
        if [ ! -f "${SRC}/index.md" ] ; then
            echo "Index file (index.md) not found. It will be created using a script..."
            (cd "${SRC}" ; python /usr/local/src/toc.py "${SRC}/index.md")
        fi

        # TOC of the docs allows global navigation between files so it's mandatory
        if [ ! -f "${TOC}" ] ; then
            echo "TOC file (contents.md) not found. It will be created using a script..."
            (cd "${SRC}" ; python /usr/local/src/toc.py "${TOC}")
        fi

        # Styling should be provided inside a "css" folder but the default, base style file should be called style.css.
        # If absent, one default css file is provided.
        if [ ! -f "${SRC}/css/style.css" ] ; then
            echo "Main CSS style file (css/style.css) not found. It will be created using a script..."
            mkdir -p "${SRC}/css"
            cp /usr/local/src/style.css "${SRC}/css/style.css"
        fi

        # Mirrors the directory structure
        (cd "${SRC}" ; find * \( -path "${DEST#"${SRC}"}" -o -path .git -o -path .github \) -prune -o -type d -exec mkdir -p ${DEST}/{} \;)

        # Calls conversion script without infinite loops if destination is inside source
        (cd "${SRC}" ; find * \( -path "${DEST#"${SRC}"}" -o -path .git -o -path .github \) -prune -o -type f -exec try_convert.sh "${SRC}" "{}" "${DEST}/" "${TOC}" \;)
    else
        # Single files conversion
        if [ -f "${SRC}" ]; then
            try_convert.sh "${SRC%/*}/" "${SRC##*/}" "${DEST}/"
        else
            >&2 echo "[ERROR] ${SRC} is not valid source";
            exit 1
        fi
    fi

    # Print results
    echo "Done. Result:"
    tree $DEST
elif [ "$MODE" = "Markdown" -o "$MODE" = "markdown" -o "$MODE" = "md" ] ; then
    >&2 echo "[ERROR] ${MODE} is currently not supported";
else
    >&2 echo "[ERROR] ${MODE} is not a valide mode";
fi
