#!/usr/bin/env bash

set -eu

# Setup build steps
TITLE="$(cat build/PARAM_TITLE)"
ARCHIVE_TITLE="$(cat build/PARAM_ARCHIVE_TITLE)"

cd build
VERSION="$(git describe --candidates=1000 --exclude="ci_draft*" --always --dirty=-DIRTY)"
CONTENT_DIR="$TITLE $VERSION"
ZIP_FILE="$ARCHIVE_TITLE-$VERSION.zip"
rm -rf "$CONTENT_DIR" "$ZIP_FILE" dist ||:

mkdir -p dist "$CONTENT_DIR"

# Copy files to content directory
if [ -d ../template/web ]; then
    cp -rv web/* "$CONTENT_DIR"/
fi
if [ -d ../template/tex ]; then
    cp -rv pdf/out/* "$CONTENT_DIR"/
fi

# Build archive
zip -r -q "$ZIP_FILE" "$CONTENT_DIR"
rm -rf "$CONTENT_DIR"
mv -v "$ZIP_FILE" dist/
