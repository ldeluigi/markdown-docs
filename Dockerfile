FROM python:3.8-alpine

# Download utilities
# TODO remove git with mkdocs 1.2
RUN apk add tree gcc musl-dev git 

# Download Python Markdown dependencies
COPY config/requirements.txt /usr/local/src/requirements.txt
RUN pip -q install -r /usr/local/src/requirements.txt

# Download PlantUML dependencies
RUN mkdir -p /usr/share/man/man1 && apk add -q openjdk11 maven graphviz




# Install PlantUML
ENV ALLOW_PLANTUML_INCLUDE=true
RUN wget -q -O plantuml.jar https://netcologne.dl.sourceforge.net/project/plantuml/plantuml.jar
RUN mkdir -p /opt/plantuml && mv plantuml.jar /opt/plantuml/plantuml.jar
COPY script/plantuml.sh /usr/local/bin/plantuml 
RUN chmod +x /usr/local/bin/plantuml

# Configuration
COPY config/mkdocs.yml /usr/local/src/mkdocs.yml

COPY script/makedocs.sh /usr/local/bin/makedocs
RUN chmod +x /usr/local/bin/makedocs
ENTRYPOINT [ "makedocs" ]
