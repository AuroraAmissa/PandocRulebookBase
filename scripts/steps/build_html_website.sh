#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure -p soupault -p nix -p git -p git-lfs -p wget -p cacert
#! nix-shell -p pandoc -p minify -p dart-sass -p highlight -p imagemagick
#! nix-shell -p python311 -p python311Packages.beautifulsoup4 -p python311Packages.tomli-w
#! nix-shell -p linkchecker

set -eu

mkdir -p build/web/
rm -rf build/web/* build/web/.* build/soupault build/extract build/css ||:
mkdir -p build/soupault/ build/extract/ build/css/

# Build soupault directory
ln -s "$(pwd)/PandocRulebookBase" build/soupault/
python3.11 PandocRulebookBase/scripts/py/soupault_gen.py
mkdir -p build/soupault/

# Build content
python3.11 PandocRulebookBase/scripts/py/gather_headings.py
soupault --config build/soupault/soupault.toml --site-dir site --build-dir build/web

# Build stylesheet
mkdir -p build/css/PandocRulebookBase/
cp -r resources/*.scss build/css/
cp -v PandocRulebookBase/*.scss build/css/PandocRulebookBase/

for css in build/css/*.scss; do
    TARGET="$(echo "$css" | sed "s/\.scss$/.css/g" | sed "s_.*/__g")"
    dart-sass -c --no-source-map "$css":build/web/static/img_XXXX/"$TARGET"
done

cp -v resources/* build/web/static/img_XXXX/
rm -v build/web/static/img_XXXX/*.scss

# Generate webfonts
WEB_ROOT="build/web/static"
PandocRulebookBase/support/mkwebfont.sh \
    --store "build/web/static/webfonts" --webroot "build/web" \
    --write-to-webroot --subset

# Minify
minify -vr build/web/ -o build/web/ --html-keep-comments
if [ -d build/web ]; then
    cp -rv templates/static/* build/web/
fi

# Build hashed directories
IMG_HASH="$(nix hash path build/web/static/img_XXXX/ --base32 | tail -c +2 | cut -c-12)"
mv -v build/web/static/img_XXXX build/web/static/"img_$IMG_HASH"
find build/web -type f -name *.html -exec sed -i "s/img_XXXX/img_$IMG_HASH/g" {} \;

JS_HASH="$(nix hash path build/web/static/js_XXXX/ --base32 | tail -c +2 | cut -c-12)"
mv -v build/web/static/js_XXXX build/web/static/"js_$JS_HASH"
find build/web -type f -name *.html -exec sed -i "s/js_XXXX/js_$JS_HASH/g" {} \;

# Check links (validation step)
linkchecker --config PandocRulebookBase/scripts/steps/linkcheckerrc build/web/
