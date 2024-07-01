#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure -p linkchecker

set -eu

# Check links (validation step)
linkchecker --config PandocRulebookBase/scripts/sh/linkcheckerrc build/web/
