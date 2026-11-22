#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "error: $*" >&2
  exit 1
}

[ $# -eq 2 ] || fail "usage: shoot.sh <url-or-html-file> <out-dir>"
input="$1"
out_dir="$2"

if [[ "$input" =~ ^https?:// ]]; then
  target="$input"
elif [ -f "$input" ]; then
  target="file://$(realpath -- "$input")"
else
  fail "'$input' is neither an http(s) URL nor an existing file"
fi

command -v chromium >/dev/null || fail "chromium is not installed"

mkdir -p "$out_dir"
for width in 375 768 1440; do
  rm -f "$out_dir/$width.png"
  chromium --headless --disable-gpu --hide-scrollbars --virtual-time-budget=8000 \
    --window-size="$width,1200" --screenshot="$out_dir/$width.png" "$target" >/dev/null 2>&1
  [ -s "$out_dir/$width.png" ] || fail "no screenshot written for width $width"
done
echo "screenshots in $out_dir: 375.png 768.png 1440.png"
