# Markdown Docs
_The same readme, built with this: [here](https://ldeluigi.github.io/markdown-docs/)!_  

This repository contains the definition of a Docker image that can be used both as a **[builder](#as-docker-builder)** stage and as an **[action](#as-github-action)**.

**markdown-docs** is implemented as a jam of stuff you don't even need to know about. Just assume that everything is supported until you find that it's not, then submit an issue to add support for even that thing. Only if you really need it.

## Supported Markdown extensions:
- The default, standard, Markdown syntax, described at [this website](https://daringfireball.net/projects/markdown/syntax), with [these differences](https://python-markdown.github.io/#differences).
- **markdown_include**: `{!<filename>!}` where `<filename>` is the name of the Markdown file to include. Headers will be shifted to subheaders relative to enclosing header.
- **plantuml_markdown**: See the official [readme](https://github.com/mikitex70/plantuml-markdown#readme). Supports non-UML tags like `@startjson` or math equations too.
- **arithmatex**: See the [docs](https://facelessuser.github.io/pymdown-extensions/extensions/arithmatex/). Provides mathematical style and fonts for expressions.
- **admonition** and **details**: See the [details docs](https://facelessuser.github.io/pymdown-extensions/extensions/details/) and [admonitions docs](https://squidfunk.github.io/mkdocs-material/reference/admonitions/). Provides highlighted text cells for many purposes.
- **keys**: You can embed keyboard symbols in text. See the [docs](https://facelessuser.github.io/pymdown-extensions/extensions/keys/).
- **tabs**: Enables content tabs. See the [docs](https://squidfunk.github.io/mkdocs-material/reference/content-tabs/).
- **tasklist**: Enables GitHub style tasks list. See the [docs](https://facelessuser.github.io/pymdown-extensions/extensions/tasklist/).
- **abbreviations**: Enables explanations for abbrevations. See the [docs](https://python-markdown.github.io/extensions/abbreviations/).
- **footnotes**: Enables footnotes. See the [docs](https://python-markdown.github.io/extensions/footnotes/).
- **git-revision-date-localized**: Enables linking last edit date of the page. See the [docs](https://timvink.github.io/mkdocs-git-revision-date-localized-plugin/index.html).

## Usage
You can use **markdown-docs** both as a [GitHub Acton](#as-github-action) or a [Docker builder stage](#as-docker-builder) inside your dockerfile.

### As GitHub Action
To use **markdown-docs** as a GitHub Action, use the following syntax in your workflow:
```yaml
      - name: Generate HTML from Markdown
        uses: ldeluigi/markdown-docs@master
        with:
          src: doc
          dst: generated
```
This means that every markdown file inside the `doc` folder in the current workspace will be converted and mapped to a corresponding HTML file inside the `generated` directory. You can pass `.` as src to search the entire repo for markdown files. `dst` folder will be emptied before generation.

In order to make the "last edit date" plugin work you need to clone the full history of your documentation inside your CI. With GitHub actions this can be done using the option `fetch-depth: 0` with the `actions/checkout@v2` step.

### As Docker builder
To use **markdown-docs** as a Docker builder stage use the following syntax in your Dockerfile:  
```dockerfile
FROM deloo/markdown-docs AS builder

COPY docs/ /home/src
ENV WORKSPACE=/home
RUN makedocs "src" "dst"

FROM ...

COPY --from=builder /home/dst /var/www/static/
```
This means that first docker stage creates a container where it runs the makedocs script, then will copy the resulting, generated HTML files in the production image, specifically in `/var/www/static`. This can be useful for your static website hosting. See [the Wiki](https://github.com/ldeluigi/markdown-docs/wiki) for more examples.

## Notes about documenting your software
The idea behind **markdown-docs** is that all the documentation that can be written in separate files from the code should be mantained like the code documentation, that is thinking about the content and not the appearence. In addition, some of the most important tools for documentation are UML diagrams. In particular, one of the most maintainable way to draw UMLs is [PlantUML](https://plantuml.com/), which can generate UML diagrams for a text specification.  
One of the most important features of **markdown-docs** is the support of PlantUML syntax embedded inside documentation sources, in Markdown.
