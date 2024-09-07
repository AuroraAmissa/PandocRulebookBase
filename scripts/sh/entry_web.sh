#!/bin/sh -eu

if [ ! -d template/web ]; then
    exit
fi

PandocRulebookBase/scripts/py/build_html.py
