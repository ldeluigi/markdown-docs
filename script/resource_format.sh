#!/bin/sh
# Checks that first argument is the extension name of a markdown file
grep -F -q -x ".${1#.}" <<EOF
.css
.js
.png
.jpg
.jpeg
.gif
.bmp
.svg
.mp3
.webm
.wav
.m4a
.ogg
.3gp
.flac
.mp4
.webm
.og
.pdf
.draw.io
.drawio
EOF
