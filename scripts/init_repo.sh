#!/usr/bin/env bash

set -eu

cp -v PandocRulebookBase/scripts/template/{build.sh,.gitignore,.gitattributes} .
rm -rfv .github
cp -rv PandocRulebookBase/scripts/template/github .github
