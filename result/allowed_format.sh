#!/bin/sh
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
