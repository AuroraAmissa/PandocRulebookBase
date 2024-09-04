#!/usr/bin/env sh
pandoc \
    -f markdown -t latex \
    --lua-filter=PandocRulebookBase/pandoc/custom-classes.lua \
    "$@"
