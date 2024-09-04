#!/bin/sh -e

if [ "$1" = "" ]; then
    echo "Usage: build.sh [dist/web/pdf]"
elif [ "$1" = "dist" ]; then
    PandocRulebookBase/scripts/sh/entry_dist.sh
elif [ "$1" = "web" ]; then
    PandocRulebookBase/scripts/sh/entry_web.sh
elif [ "$1" = "pdf" ]; then
    PandocRulebookBase/scripts/sh/entry_pdf.sh
else
    echo "I don't know what $1 means."
fi
