#!/usr/bin/env bash

set -eu

cd "$(realpath "$(dirname "$0")")/../.."

PandocRulebookBase/scripts/support/build_web.sh
PandocRulebookBase/scripts/sh/build_link_check.sh
