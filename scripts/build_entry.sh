#!/bin/sh -e

if [ "$1" = "" ]; then
    PandocRulebookBase/scripts/build.sh
elif [ "$1" = "web" ]; then
    PandocRulebookBase/scripts/build_web.sh
else
    echo "I don't know what $1 means."
fi
