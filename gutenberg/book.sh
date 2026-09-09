#!/usr/bin/env bash
set -euo pipefail

id="${1:?book id required}"
curl -sL --fail --max-time 30 "https://gutendex.com/books/${id}" | jq .