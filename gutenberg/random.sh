#!/usr/bin/env bash
set -euo pipefail

curl -sL --fail --max-time 30 "https://gutendex.com/books/?sort=random" |
  jq -r '(.results[] | "\(.id)\t\(.title)\t[\(.languages|join(","))]\t\(( [.authors[].name] )|join(";"))")'