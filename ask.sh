#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

GUTENBERG_DIR="gutenberg_api"
CONVERT_DIR="convert"
READER_DIR="reader"

bold=$(tput bold 2>/dev/null || printf '')
green=$(tput setaf 2 2>/dev/null || printf '')
cyan=$(tput setaf 6 2>/dev/null || printf '')
reset=$(tput sgr0 2>/dev/null || printf '')

info()  { printf '%s%s%s\n' "$green" "$1" "$reset"; }
title() { printf '\n%s%s%s\n' "$cyan" "$1" "$reset"; }

die() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

prompt() {
  local msg="$1" var="$2" default="${3:-}"
  printf '%s [%s]: ' "$msg" "$default"
  read -r "$var"
  if [ -z "${!var}" ]; then
    printf -v "$var" '%s' "$default"
  fi
}

run() { (
  set -euo pipefail
  "$@"
); }

task_search() {
  local q
  prompt "Search query" q "mark twain"
  run ./gutenberg_api/search.sh "$q"
}

task_random() {
  run ./gutenberg_api/random.sh
}

task_book() {
  local id
  prompt "Book id" id "2701"
  run ./gutenberg_api/book.sh "$id"
}

task_download() {
  local id outdir
  prompt "Book id" id "1995"
  prompt "Output directory" outdir "$HOME/books"
  mkdir -p "$outdir"
  run ./gutenberg_api/download.sh "$id" "$outdir"
}

task_convert() {
  local input out
  prompt "Input ebook (epub/mobi/pdf) or directory" input ""
  [ -n "$input" ] || die "no input given"
  if command -v extract-text >/dev/null 2>&1; then
    run extract-text "$input"
  elif command -v poetry >/dev/null 2>&1 && [ -f "$CONVERT_DIR/pyproject.toml" ]; then
    run poetry -C "$CONVERT_DIR" run extract-text "$input"
  else
    die "extract-text is not installed (cd $CONVERT_DIR && poetry install)"
  fi
}

need_mix() {
  command -v mix >/dev/null 2>&1 && [ -f "$READER_DIR/mix.exs" ]
}

task_install() {
  title "Install Elixir (only needed outside the docker container)"
  cat <<'EOF'
This project's reader app needs Elixir + Erlang. On a Debian 13 host:

  sudo apt update
  sudo apt install -y elixir erlang-dev erlang-xmerl build-essential libsqlite3-dev

Ubuntu alt (use asdf -- the packaged elixir may be older):

  sudo apt install -y curl git unzip build-essential libsqlite3-dev \
    automake autoconf libncurses-dev libssl-dev libyaml-dev \
    libreadline-dev libtool
  # then: asdf install erlang latest && asdf install elixir latest

erlang-xmerl is needed for the reader's EPUB parsing (installed by default
with Docker's Elixir). If it is missing, the reader falls back to the
plain-text download instead.

Run this task again after installing, then pick 7 to start the server.
EOF
  prompt "Run apt install now? [y/N]" go "N"
  case "$go" in
    y|Y) run sudo apt update && sudo apt install -y elixir erlang-dev erlang-xmerl build-essential libsqlite3-dev ;;
    *) info "skipping install" ;;
  esac
}

task_server() {
  if need_mix; then
    if [ ! -d "$READER_DIR/deps" ]; then
      info "installing reader dependencies..."
      (cd "$READER_DIR" && mix deps.get && mix assets.build)
    fi
    info "starting reader webapp at http://localhost:4000"
    (cd "$READER_DIR" && mix phx.server)
  else
    info "mix is not installed on this host."
    task_install
  fi
}

task_catalog() {
  title "Catalog sources"
  printf '  1) Download official catalog.csv.gz (one file)\n'
  printf '  2) Build index.csv via Gutendex API (paginated, resume-safe)\n'
  prompt "Choice" choice "1"
  case "$choice" in
    1) run ./gutenberg_api/fetch_catalog.sh ;;
    2) run ./gutenberg_api/index.sh ;;
    *) die "unknown choice: $choice" ;;
  esac
}

menu() {
  while true; do
    title "books — task launcher"
    printf 'Available tasks:\n'
    printf '\n'
    printf '  %sGutenberg API%s\n' "$cyan" "$reset"
    printf '  1) search catalog\n'
    printf '  2) random book\n'
    printf '  3) book details (JSON)\n'
    printf '  4) download book (text + epub)\n'
    printf '  %sCorpus tooling%s\n' "$cyan" "$reset"
    printf '  5) convert ebook to text\n'
    printf '  6) fetch/build local catalog index\n'
    printf '  %sReader app%s\n' "$cyan" "$reset"
    printf '  7) run the reader webapp\n'
    printf '  8) install Elixir (host setup)\n'
    printf '\n'
    printf '  0) quit\n'
    printf '\n'
    prompt "Choose a task" choice "0"
    case "$choice" in
      1) task_search ;;
      2) task_random ;;
      3) task_book ;;
      4) task_download ;;
      5) task_convert ;;
      6) task_catalog ;;
      7) task_server ;;
      8) task_install ;;
      0) echo "bye"; exit 0 ;;
      *) printf 'unknown choice: %s\n' "$choice" ;;
    esac
  done
}

if [ $# -gt 0 ]; then
  task="$1"; shift
  case "$task" in
    search)     task_search ;;
    random)     task_random ;;
    book)       task_book ;;
    download)   task_download ;;
    convert)    task_convert ;;
    server)     task_server ;;
    catalog)    task_catalog ;;
    install)    task_install ;;
    help|--help|-h)
      echo "usage: ./ask.sh [task]"
      echo "tasks: search | random | book | download | convert | catalog | server | install | help"
      exit 0
      ;;
    *) die "unknown task: $task (run ./ask.sh help)" ;;
  esac
else
  menu
fi