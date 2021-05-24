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
COPY script/plantuml.sh /usr/local/bin/plantuml 
RUN chmod +x /usr/local/bin/plantuml

# Configure Python Markdown
COPY config/pymd_config.yml /pymd_config.yml

# Utility scripts
COPY script/allowed_format.sh /usr/local/bin/allowed_format.sh
RUN chmod +x /usr/local/bin/allowed_format.sh
COPY script/resource_format.sh /usr/local/bin/resource_format.sh
RUN chmod +x /usr/local/bin/resource_format.sh
COPY script/try_convert.sh /usr/local/bin/try_convert.sh
RUN chmod +x /usr/local/bin/try_convert.sh
ADD script/md_file_tree.py /usr/local/src/toc.py

# HTML
COPY html/template.html /usr/local/src/template.html
# CSS
COPY css/style.css /usr/local/src/style.css
# JS
COPY js/script.js /usr/local/src/script.js

COPY script/start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT [ "/start.sh" ]

# RUN mkdir -p /github/workspace
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
