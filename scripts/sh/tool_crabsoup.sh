#!/bin/sh

set -eu

VERSION="0.1.0-alpha5"
CRABSOUP="build/crabsoup-$VERSION"

if [ ! -f "$CRABSOUP" ]; then
    wget "https://github.com/Lymia/crabsoup/releases/download/v$VERSION/crabsoup-$VERSION-x86_64-linux" -O "$CRABSOUP"
    chmod +x "$CRABSOUP"
fi

"$CRABSOUP" "$@"
