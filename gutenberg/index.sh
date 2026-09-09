#!/usr/bin/env bash
set -euo pipefail

OUT="index.csv"
MARK=".last_page"
PAGES_PER=32
api="https://gutendex.com/books"
sleep_sec=${INDEX_SLEEP:-0.15}

first=$(curl -sL --retry 3 --max-time 60 --fail "${api}/?page=1")
count=$(printf %s "$first" | jq -r '.count')
total_pages=$(( (count + PAGES_PER - 1) / PAGES_PER ))

start=1
[ -f "$MARK" ] && start=$(cat "$MARK")
if [ "$start" -eq 1 ] && [ ! -f "$OUT" ]; then
  echo "id,title,authors,languages" > "$OUT"
fi
if [ "$start" -gt "$total_pages" ]; then
  echo "index already complete ($count books, $total_pages pages)"
  exit 0
fi
echo "downloading index: $count books across $total_pages pages (resuming at $start)..."

for ((p = start; p <= total_pages; p++)); do
  rows=$(printf %s "$first" | jq -r '.results[] | [.id, .title, ([.authors[]?.name] | join("; ")), (.languages | join(","))] | @csv')
  if [ "$p" -eq 1 ]; then
    printf '%s\n' "$rows" >> "$OUT"
  else
    curl -sL --retry 3 --max-time 60 --fail "${api}/?page=${p}" |
      jq -r '.results[] | [.id, .title, ([.authors[]?.name] | join("; ")), (.languages | join(","))] | @csv' >> "$OUT"
  fi
  printf '%s\n' "$p" > "$MARK"
  if (( p % 100 == 0 )); then echo "page $p/$total_pages"; fi
  sleep "$sleep_sec"
done

echo "done: $count books → $OUT ($(wc -l < "$OUT") lines)"