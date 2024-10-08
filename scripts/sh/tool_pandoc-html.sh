#!/usr/bin/env sh
pandoc \
    -f markdown-auto_identifiers --section-divs=true -t html --no-highlight \
    --wrap=preserve --columns=1 \
    --lua-filter=PandocRulebookBase/pandoc/custom-classes.lua \
    --lua-filter=PandocRulebookBase/pandoc/html/breadcrumbs.lua \
    --lua-filter=PandocRulebookBase/pandoc/html/html-classes.lua \
    --lua-filter=PandocRulebookBase/pandoc/html/language-tags.lua \
    --lua-filter=PandocRulebookBase/pandoc/html/mdlinks-html.lua \
    "$@"
