#!/usr/bin/env sh
pandoc \
    -f markdown -t latex --pdf-engine=lualatex \
    --lua-filter=PandocRulebookBase/pandoc/custom-classes.lua \
    --lua-filter=PandocRulebookBase/pandoc/tex/tex-classes.lua \
    --lua-filter=PandocRulebookBase/pandoc/tex/tagpdf.lua \
    "$@"
