#!/bin/zsh
# Theos rejects spaces in paths: build in ~/.materialyou-build.
set -e
export THEOS=${THEOS:-$HOME/theos}
SRC="$(cd "$(dirname "$0")" && pwd)"; B="$HOME/.materialyou-build"
rm -rf "$B"; mkdir -p "$B"; rsync -a --exclude .theos --exclude packages --exclude .git "$SRC/" "$B/"
D="$B/layout/Library/Application Support/MaterialYou"; mkdir -p "$D"; cp -R "$SRC/Resources/." "$D/"
cd "$B"; make clean package FINALPACKAGE=1
mkdir -p "$SRC/packages"; cp packages/*.deb "$SRC/packages/"; ls -la "$SRC/packages"
