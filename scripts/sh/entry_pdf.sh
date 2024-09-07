#!/bin/sh -eu

if [ ! -d template/tex ]; then
    exit
fi

PandocRulebookBase/scripts/py/build_pdf.py
