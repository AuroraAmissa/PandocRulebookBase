#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure -p soupault -p nix -p git -p git-lfs -p wget -p cacert
#! nix-shell -p pandoc -p minify -p dart-sass -p highlight -p imagemagick
#! nix-shell -p python311 -p python311Packages.beautifulsoup4 -p python311Packages.tomli-w
#! nix-shell -p linkchecker

set -eu

mkdir -p build/web/
rm -rf build/web/* build/web/.* build/soupault build/extract ||:
mkdir -p build/soupault/ build/extract/

# Build soupault directory
ln -s "$(pwd)/PandocRulebookBase" build/soupault/
python3.11 PandocRulebookBase/scripts/py/soupault_gen.py
mkdir -p build/soupault/

# Build content
python3.11 PandocRulebookBase/scripts/py/gather_headings.py
soupault --config build/soupault/soupault.toml --site-dir site --build-dir build/web

# Copy scss resources
WEB_ROOT="build/web/static"
mkdir -p "$WEB_ROOT"/img_XXXX "$WEB_ROOT"/img_XXXX/PandocRulebookBase/
cp -v resources/* "$WEB_ROOT"/img_XXXX/
cp -v PandocRulebookBase/*.scss "$WEB_ROOT"/img_XXXX/PandocRulebookBase/

# Generate webfonts
dart-sass -c --no-source-map "$WEB_ROOT"/img_XXXX/style.scss:build/extract/style.css
mkdir -p "$WEB_ROOT"/webfonts/
python3.11 PandocRulebookBase/scripts/py/prepare_fonts.py

# Minify
minify -vr build/web/ -o build/web/ --html-keep-comments
if [ -d build/web ]; then
    cp -rv templates/static/* build/web/
fi

# Build scss stylesheet
dart-sass -c "$WEB_ROOT"/img_XXXX/all_style.scss:"$WEB_ROOT"/img_XXXX/all_style.css --style=compressed

# Build hashed directories
IMG_HASH="$(nix hash path build/web/static/img_XXXX/ --base32 | tail -c +2 | cut -c-12)"
mv -v build/web/static/img_XXXX build/web/static/"img_$IMG_HASH"
find build/web -type f -name *.html -exec sed -i "s/img_XXXX/img_$IMG_HASH/g" {} \;

JS_HASH="$(nix hash path build/web/static/js_XXXX/ --base32 | tail -c +2 | cut -c-12)"
mv -v build/web/static/js_XXXX build/web/static/"js_$JS_HASH"
find build/web -type f -name *.html -exec sed -i "s/js_XXXX/js_$JS_HASH/g" {} \;

# Check links (validation step)
linkchecker --config PandocRulebookBase/scripts/steps/linkcheckerrc build/web/
