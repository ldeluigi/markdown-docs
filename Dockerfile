FROM python:3.9-alpine

# Download utilities
RUN apk add tree

# Download Python Markdown dependencies
RUN pip -q install PyYAML six markdown plantuml-markdown markdown-toc markdown-table

# Download PlantUML dependencies
RUN mkdir -p /usr/share/man/man1 && apk add -q openjdk11 maven graphviz

# Install PlantUML
ENV ALLOW_PLANTUML_INCLUDE=true
RUN wget -q -O plantuml.jar https://netcologne.dl.sourceforge.net/project/plantuml/plantuml.jar
RUN mkdir -p /opt/plantuml && mv plantuml.jar /opt/plantuml/plantuml.jar
COPY plantuml.sh /usr/local/bin/plantuml 
RUN chmod +x /usr/local/bin/plantuml

# Configure Python Markdown
COPY pymd_config.yml /pymd_config.yml

# Utility scripts
COPY allowed_format.sh /usr/local/bin/allowed_format.sh
RUN chmod +x /usr/local/bin/allowed_format.sh
COPY try_convert.sh /usr/local/bin/try_convert.sh
RUN chmod +x /usr/local/bin/try_convert.sh
ADD md_file_tree.py /usr/local/src/toc.py

# CSS
COPY css/style.css /usr/local/src/style.css

COPY start.sh /start.sh
RUN chmod +x /start.sh
RUN mkdir -p /github/workspace
ENTRYPOINT [ "/start.sh" ]

# RUN touch /github/workspace/test.md \
# && touch /github/workspace/test.mk \
# && mkdir /github/workspace/test \
# && mkdir /github/workspace/test/asd \
# && mkdir /github/workspace/test/asd/topkek \
# && touch /github/workspace/test/test.md \
# && touch /github/workspace/test/test.mk \
# && touch /github/workspace/test/test.md \
# && touch /github/workspace/test/test.mk \
# && echo "# Ok" > /github/workspace/test/asd/topkek/test.md \
# && touch /github/workspace/test/asd/topkek/test.mk
