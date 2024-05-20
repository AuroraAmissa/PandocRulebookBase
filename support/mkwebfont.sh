#!/bin/sh

set -eu

if [ ! -f build/mkwebfont ]; then
    wget https://github.com/Lymia/mkwebfont/releases/download/v0.2.0-alpha1/mkwebfont-0.2.0-alpha1-no_data-x86_64.AppImage -O build/mkwebfont
    chmod +x build/mkwebfont
fi

build/mkwebfont "$@"
