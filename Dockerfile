FROM python:3.9-alpine

# Download Python Markdown dependencies
RUN pip install PyYAML six markdown plantuml-markdown

# Download PlantUML dependencies
RUN mkdir -p /usr/share/man/man1 && apk add -q openjdk11 maven graphviz

# Install PlantUML
ENV ALLOW_PLANTUML_INCLUDE=true
RUN wget -q -O plantuml.jar https://nav.dl.sourceforge.net/project/plantuml/plantuml.jar
RUN mkdir -p /opt/plantuml && mv plantuml.jar /opt/plantuml/plantuml.jar
COPY plantuml.sh /usr/local/bin/plantuml
RUN mkdir /wiki
ENV PLANTUML_JAVAOPTS="-Dplantuml.include.path=/wiki"

# Configure Python Markdown
COPY pymd_config.yml /pymd_config.yml

COPY start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT [ "/start.sh" ]
