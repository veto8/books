#!/usr/bin/env bash
set -euo pipefail

q="${1:?query required}"
uri=$(printf %s "$q" | jq -sRr @uri)
curl -sL --fail --max-time 30 "https://gutendex.com/books?search=${uri}" |
  jq -r '"COUNT: \(.count)", (.results[] | "\(.id)\t\(.title)\t[\(.languages|join(","))]\t\(( [.authors[].name] // ["?"] )|join(";"))")'