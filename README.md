# Markdown Docs
This repository contains the definition of a Docker image that can be used both as a **[builder](#as-docker-builder)** stage and as an **[action](#as-github-action)**.

**markdown-docs** is implemented as a jam of stuff you don't even need to know about. Just assume that everything is supported until you find that it's not, then submit an issue to add support for even that thing. Only if you really need it.

## Supported Markdown extensions:
WIP

## Usage
You can use **markdown-docs** both as a [GitHub Acton](#as-github-action) or a [Docker builder stage](#as-docker-builder) inside your dockerfile.

### As GitHub Action
To use **markdown-docs** as a GitHub Action, use the following syntax in your workflow:
```yaml
      - name: Generate HTML from Markdown
        uses: ldeluigi/markdown-docs@master
        with:
          mode: HTML
          src: doc
          dst: generated
```
This means that every markdown file inside the `doc` folder in the current workspace will be converted and mapped to a corresponding HTML file inside the `generated` directory.  
Some non-markdown files are considered as resources and will be copied to the output folder in order to preserve resource links. This works for CSS, JS, images, audio, videos, pdf...  
In addition to that, JS files put inside a `js/` folder and CSS files inside `css/` folder are automatically linked to every html generated with **markdown-docs**. See the [custom css](#custom-css) and [custom js](#custom-js) sections.

### As Docker builder
To use **markdown-docs** as a Docker builder stage use the following syntax in your Dockerfile:  
```dockerfile
FROM deloo/markdown-docs AS builder

COPY doc/ /home/src
ENV WORKSPACE=/home
RUN makedocs "HTML" "src" "dst"

FROM ...

COPY --from=builder /home/dst /var/www/static/
```
This means that first docker creates a builder container where it runs the /start.sh script, then will copy the resulting, generated HTML files in the production image, specifically in `/var/www/static`.
## Documenting
The idea behind **markdown-docs** is that all the documentation that can be written in separate files from the code should be mantained like the code documentation, that is thinking about the content and not the appearence. In addition, some of the most important tools for documentation are UML diagrams. In particular, one of the most maintainable way to draw UMLs is [PlantUML](https://plantuml.com/), which can generate UML diagrams for a text specification.  
One of the most important features of **markdown-docs** is the support of PlantUML syntax embedded inside documentation sources, in Markdown.
### Markdown
**markdown-docs** makes use of Python Markdown generator, with the following plugins:
- **TOC**  
  _You can use [TOC] to spawn a table of content inside your markdown file_
- **Tables**  
  _You can write Markdown tables to be rendered appropriately_
- **PlantUML**  
  _You can put PlantUML syntax as speficied in this [readme](https://github.com/mikitex70/plantuml-markdown/blob/master/README.md)_
