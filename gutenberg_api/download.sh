#!/usr/bin/env bash
set -euo pipefail

id="${1:?book id required}"
outdir="${2:-.}"
base="https://www.gutenberg.org/cache/epub/${id}"

mkdir -p "$outdir"

download() {
  local url="$1" out="$2"
  curl -sL --retry 3 --max-time 300 --fail "$url" -o "$out"
  printf 'saved %s (%s bytes)\n' "$out" "$(wc -c < "$out")"
}

download "${base}/pg${id}.txt" "${outdir}/${id}.txt"
download "${base}/pg${id}.epub" "${outdir}/${id}.epub"