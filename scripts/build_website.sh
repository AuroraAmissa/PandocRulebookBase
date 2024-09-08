#!/usr/bin/env bash

set -eu

cd "$(realpath "$(dirname "$0")")/../.."

nix develop path:PandocRulebookBase/nix/ --command PandocRulebookBase/scripts/sh/entry_web.sh
