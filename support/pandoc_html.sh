#!/usr/bin/env sh
pandoc -f markdown-auto_identifiers --section-divs=true -t html --no-highlight \
    --lua-filter=PandocRulebookBase/pandoc/include-files.lua \
    --lua-filter=PandocRulebookBase/pandoc/inline-spans.lua \
    --lua-filter=PandocRulebookBase/pandoc/html/language-tags.lua \
    --lua-filter=PandocRulebookBase/pandoc/html/mdlinks-html.lua \
    "$@"
