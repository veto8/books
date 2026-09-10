#!/usr/bin/env bash
set -euo pipefail

OUT="catalog.csv"
url="https://www.gutenberg.org/cache/epub/feeds/pg_catalog.csv.gz"

curl -sL --retry 3 --fail --max-time 300 "$url" | gzip -dc > "${OUT}.tmp"
mv "${OUT}.tmp" "$OUT"
echo "saved $OUT ($(wc -l < "$OUT") lines)"