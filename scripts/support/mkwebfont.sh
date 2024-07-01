#!/bin/sh

set -eu

VERSION="0.2.0-alpha3"
MKWEBFONT="build/mkwebfont-$VERSION"

if [ ! -f "$MKWEBFONT" ]; then
    wget "https://github.com/Lymia/mkwebfont/releases/download/v$VERSION/mkwebfont-$VERSION-x86_64.AppImage" -O "$MKWEBFONT"
    chmod +x "$MKWEBFONT"
fi

"$MKWEBFONT" "$@"
