#!/bin/sh -e

if [ "$1" = "" ]; then
    echo "Usage: build.sh [release/ci/playtest/draft/web/pdf]"
elif [ "$1" = "release" ]; then
    export DO_RELEASE=1
    nix develop path:PandocRulebookBase/nix/ --command PandocRulebookBase/scripts/sh/entry_dist.sh
elif [ "$1" = "ci" ]; then
    export DO_CI_RELEASE=1
    nix develop path:PandocRulebookBase/nix/ --command PandocRulebookBase/scripts/sh/entry_dist.sh
elif [ "$1" = "playtest" ]; then
    export DO_PLAYTEST=1
    nix develop path:PandocRulebookBase/nix/ --command PandocRulebookBase/scripts/sh/entry_dist.sh
elif [ "$1" = "draft" ]; then
    nix develop path:PandocRulebookBase/nix/ --command PandocRulebookBase/scripts/sh/entry_dist.sh
elif [ "$1" = "web" ]; then
    nix develop path:PandocRulebookBase/nix/ --command PandocRulebookBase/scripts/sh/entry_web.sh
elif [ "$1" = "pdf" ]; then
    nix develop path:PandocRulebookBase/nix/ --command PandocRulebookBase/scripts/sh/entry_pdf.sh
else
    echo "I don't know what $1 means."
fi
