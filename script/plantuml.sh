#!/bin/sh
echo "$PLANTUML_JAVAOPTS" > /debug.txt
java $PLANTUML_JAVAOPTS -jar /opt/plantuml/plantuml.jar ${@}