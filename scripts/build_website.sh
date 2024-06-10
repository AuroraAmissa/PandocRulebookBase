#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure -p nix -p python311
#! nix-shell --keep NIX_PATH

set -eu

cd "$(realpath "$(dirname "$0")")/../.."

PandocRulebookBase/scripts/steps/build_html_website.sh
