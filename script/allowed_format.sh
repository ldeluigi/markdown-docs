#!/bin/sh
# Checks that first argument is the extension name of a markdown file
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
.css
.js
EOF
