FROM python:3.8-alpine

# Download utilities
RUN apk add --update tree gcc git musl-dev

# Downlad draw.io + dependencies
#RUN apk add --update alsa-lib-dev xvfb-run
#ADD https://github.com/jgraph/drawio-desktop/releases/download/v14.6.13/draw.io-14.6.13.zip /drawio.zip
#RUN tar -xf /drawio.zip -C /drawio

# Download PlantUML + dependencies
RUN mkdir -p /usr/share/man/man1 && apk add -q openjdk11 maven graphviz

ENV ALLOW_PLANTUML_INCLUDE=true
RUN wget -q -O plantuml.jar https://netcologne.dl.sourceforge.net/project/plantuml/plantuml.jar
RUN mkdir -p /opt/plantuml && mv plantuml.jar /opt/plantuml/plantuml.jar
COPY script/plantuml.sh /usr/local/bin/plantuml 
RUN chmod +x /usr/local/bin/plantuml

# Download Python Markdown dependencies
COPY config/requirements.txt /usr/local/src/requirements.txt
RUN pip install -r /usr/local/src/requirements.txt

# Configuration
COPY config/mkdocs.yml /usr/local/src/mkdocs.yml

COPY script/makedocs.sh /usr/local/bin/makedocs
RUN chmod +x /usr/local/bin/makedocs
ENTRYPOINT [ "makedocs" ]
