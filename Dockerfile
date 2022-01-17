FROM python:3.10.1-alpine

# Download PlantUML + dependencies
RUN mkdir -p /usr/share/man/man1 && apk add --no-cache openjdk8 graphviz && \
  wget -q -O plantuml.jar https://netcologne.dl.sourceforge.net/project/plantuml/plantuml.jar && \
  mkdir -p /opt/plantuml && mv plantuml.jar /opt/plantuml/plantuml.jar
ENV ALLOW_PLANTUML_INCLUDE=true
COPY script/plantuml.sh /usr/local/bin/plantuml 
RUN chmod +x /usr/local/bin/plantuml

# Download Python Markdown + dependencies
COPY config/requirements.txt /usr/local/src/requirements.txt
RUN apk add --no-cache gcc git musl-dev libffi-dev && \
  pip install --no-cache-dir -r /usr/local/src/requirements.txt && \
  apk del gcc musl-dev libffi-dev

# Configuration
COPY config/mkdocs.yml /usr/local/src/mkdocs.yml
COPY config/arithmatex.config.js /usr/local/src/arithmatex.config.js
COPY config/theme.main.html /usr/local/src/theme.main.html
COPY config/theme.404.html /usr/local/src/theme.404.html

# Entrypoint
COPY script/makedocs.sh /usr/local/bin/makedocs
RUN chmod +x /usr/local/bin/makedocs
ENTRYPOINT [ "makedocs" ]
