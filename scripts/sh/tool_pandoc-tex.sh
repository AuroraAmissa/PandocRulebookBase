#!/usr/bin/env sh
pandoc \
    -f markdown -t context \
    --lua-filter=PandocRulebookBase/pandoc/custom-classes.lua \
    "$@"
