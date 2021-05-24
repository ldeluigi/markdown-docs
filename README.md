[TOC]

# Markdown Docs
This repository contains the definition of a Docker image that can be used both as a **[builder](#as-docker-builder)** stage and as an **[action](#as-github-action)**.

**markdown-docs** is implemented as a jam of shell scripts, python scripts and python utilities like [Python Markdown](https://github.com/Python-Markdown/markdown), with some additional plugins like [Table of Contents](https://python-markdown.github.io/extensions/toc/), [Tables](https://python-markdown.github.io/extensions/tables/) and, on top of all, [PlantUML Markdown](https://github.com/mikitex70/plantuml-markdown). This extension enables the inclusion of PlantUML diagrams (UML, JSON...) rendered _inline_ inside your website. It also supports the `!include` directive for PlantUML reuse of code.

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
RUN /start.sh "HTML" "src" "dst"

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

### Entrypoint: `index.md`
The `index.md` file is considered as the entrypoint of the documentation. if it isn't provided the script will generate a very basic one, to be served as a land page when converted to `index.html`.

### Contents: `contents.md`
The `contents.md` file is considered as the place to put the global table of contents, a TOC that displays which files are available in the documentation folder and works as a navigation menu for them. If not provided the script will generate one with every file encountered during conversion.

### Custom CSS
You can provide any number of custom CSS files to be included inside every HTML page. The only requirement is that you put CSS files inside a `css` folder at the root level.
#### `css/style.css`
`style.css` file overrides the default CSS. Provide it only if you know what you are doing. If not provided, the script will generate one based on a template. Currently, the CSS supports both light and dark mode based on the system preferences.

### Custom JS
You can provide any number of custom JS files to be included inside every HTML page. The only requirement is that you put JS files inside a `js` folder at the root level.
#### `js/script.js`
`script.js` file overrides the fefault JS.
Provide it only when you know what you are doing. If not provided, the script will generate one based on a template. Currently, the JS supports collapsible table of contents.
