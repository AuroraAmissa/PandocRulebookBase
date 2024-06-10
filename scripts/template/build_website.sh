#!/bin/sh -e

git submodule update --init --recursive
PandocRulebookBase/scripts/build_website.sh "$@"
