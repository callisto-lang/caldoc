# Caldoc
Documentation generator (a very lazy one) for Callisto

## Build
```
dub build
```

## How to use
Caldoc needs 2 parameters, a section parameter (can be multiple) and an output path

Sections are just folders containing callisto source files or markdown files. Sections
get their own folder in the output directory.

The output path is the folder where the generated documentation is stored

Use a tool of your choice to render the generated markdown files as a webpage
