#!/bin/sh -e

if [ "$1" = "" ]; then
    echo "Usage: build.sh [dist/web]"
elif [ "$1" = "dist" ]; then
    PandocRulebookBase/scripts/sh/entry_dist.sh
elif [ "$1" = "web" ]; then
    PandocRulebookBase/scripts/sh/entry_web.sh
else
    echo "I don't know what $1 means."
fi
