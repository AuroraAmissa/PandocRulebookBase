#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure -p zip -p git -p linkchecker

set -eu

# Check links (validation step)
linkchecker --config PandocRulebookBase/scripts/steps/linkcheckerrc build/web/

# Build archive zip
cd build
VERSION="$(git describe --always --dirty=-DIRTY)"
CONTENT_DIR="Project Unison $VERSION"
ZIP_FILE="ProjectUnison-$VERSION.zip"
rm -rf "$CONTENT_DIR" "$ZIP_FILE" dist ||:
mkdir -p dist
cp -r web "$CONTENT_DIR"
zip -r -q "$ZIP_FILE" "$CONTENT_DIR"
rm -rf "$CONTENT_DIR"
mv -v "$ZIP_FILE" dist/
