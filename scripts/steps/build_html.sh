#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure -p soupault -p nix -p git -p git-lfs -p wget -p cacert
#! nix-shell -i bash --pure -p pandoc -p minify -p dart-sass -p highlight -p imagemagick
#! nix-shell -p python311 -p python311Packages.beautifulsoup4 -p python311Packages.tomli-w

set -eu

git lfs pull

mkdir -p build/web/
rm -rf build/web/* build/web/.* build/soupault build/extract ||:
mkdir -p build/soupault/ build/extract/

# Build soupault directory
ln -s "$(pwd)/PandocRulebookBase" build/soupault/
python3.11 PandocRulebookBase/scripts/py/soupault_gen.py
WEB_PATH="$(cat build/extract/web_path)"
mkdir -p build/soupault/site/"$WEB_PATH"/
ln -s "$(pwd)"/content/* build/soupault/site/"$WEB_PATH"/

# Build content
python3.11 PandocRulebookBase/scripts/py/gather_headings.py
soupault --config build/soupault/soupault.toml --site-dir build/soupault/site --build-dir build/web

# Copy scss resources
WEB_ROOT="build/web/$WEB_PATH"
mkdir -p "$WEB_ROOT"/img/ "$WEB_ROOT"/img/PandocRulebookBase/
cp -v resources/* "$WEB_ROOT"/img/
cp -v PandocRulebookBase/*.scss "$WEB_ROOT"/img/PandocRulebookBase/

# Generate webfonts
dart-sass -c --no-source-map "$WEB_ROOT"/img/style.scss:build/extract/style.css
mkdir -p "$WEB_ROOT"/webfonts/
python3.11 PandocRulebookBase/scripts/py/prepare_fonts.py

# Minify
minify -vr build/web/ -o build/web/ --html-keep-comments

# Build scss stylesheet
dart-sass -c "$WEB_ROOT"/img/all_style.scss:"$WEB_ROOT"/img/all_style.css --style=compressed
