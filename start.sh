#!/bin/sh
SRC=${1#.}
SRC=${GITHUB_WORKSPACE%/}/${SRC#/}
DEST=${2#.}
DEST=${GITHUB_WORKSPACE%/}/${DEST#/}
DEST=${DEST%/}
echo "Source: ${SRC}; Destination: ${DEST}/"

allowed_format() {
    grep -F -q -x ".${1#.}" <<EOF
.markdown
.mdown
.mkdn
.md
.mkd
.mdwn
.mdtxt
.mdtext
.text
.Rmd
EOF
}

if [ ! -d "${DEST}/" ] ; then
    >&2 echo "[ERROR] ${DEST} is not valid destination path"
    exit 1
fi

if [ -d "${SRC}" ] ; then
    export PLANTUML_JAVAOPTS="-Dplantuml.include.path=${SRC}"
    (cd ${SRC} ; find -type d -links 2 -exec mkdir -p "${DEST}/{}" \;)
    find ${SRC} -type f ! -path . ! -path ./.git ! -path ./.github -exec echo {} \;
        # OUTPUT=$DEST/${FOLDER:2}
        # mkdir -p "$OUTPUT"
        # FILENAME="${SRC%.*}"
        # RESULTNAME="${FILENAME}.html"
        # echo "Converting ${FILENAME} to ${RESULTNAME}..."
        # markdown_py -x plantuml_markdown -c /pymd_config.yml "${SRC}" > $2/${RESULTNAME}
        # DOCS+=( "${FOLDER:2}" )
    
else
    if [ -f "${SRC}" ]; then
        FILENAME="${SRC%.*}"
        FILENAME="${FILENAME#/}"
        FORMAT="${SRC#*.}"
        if allowed_format "$FORMAT" ; then
            RESULTNAME="${FILENAME##*/}.html"
            echo "Converting ${SRC} to $DEST/${RESULTNAME}..."
            markdown_py -x plantuml_markdown -c /pymd_config.yml "${SRC}" > $DEST/${RESULTNAME}
        else
            echo $FORMAT
            cp -f "$SRC" "$DEST/"
        fi
    else
        >&2 echo "[ERROR] ${SRC} is not valid source";
        exit 1
    fi
fi

ls $DEST
