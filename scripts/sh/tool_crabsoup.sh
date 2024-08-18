#!/bin/sh

set -eu

VERSION="0.1.0-alpha1"
CRABSOUP="build/crabsoup-$VERSION"

#if [ ! -f "$CRABSOUP" ]; then
    cp -v ~/Projects/crates/crabsoup/target/debug/crabsoup "$CRABSOUP" # TODO: Very temporary.
#    chmod +x "$CRABSOUP"
#fi

"$CRABSOUP" "$@"
