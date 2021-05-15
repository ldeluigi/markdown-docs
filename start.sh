#!/bin/sh
#cp -R $2 /wiki
echo "# Test\n" >> src.md
markdown_py -x plantuml_markdown -c /pymd_config.yml src.md > out.html
cat out.html
