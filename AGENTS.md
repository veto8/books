# Project: books (extract-text)

## Overview
CLI tool to extract plain text from **PDF**, **EPUB**, and **MOBI** files. Batch-capable. Related doc: `CORPUS.md` — reference list of public LLM training corpora and licensing notes.

## Stack
- Python ≥ 3.10, Poetry
- `pymupdf` (PDF), `ebooklib` + `beautifulsoup4` + `lxml` (EPUB), `mobi` (MOBI/KF8)

## Usage
```bash
poetry run extract-text book.pdf            # single file → <input>.txt
poetry run extract-text /path/to/books/     # batch over a directory
python3 extract_text.py <file_or_dir>       # without Poetry
```

## Structure
```
books/
├── extract_text.py      # main script (single entry point)
├── pyproject.toml       # Poetry config, console script: extract-text
├── poetry.lock
├── CORPUS.md            # corpus/dataset reference notes (not code)
├── bookworm.svg         # README logo
├── AGENTS.md
└── dockers/
    └── dockers/
        ├── docker-compose.yml   # core dev: phoenix + mysql + phpmyadmin
        ├── dev.yml              # overlay variant with nginx-proxy + static IPs
        ├── init.sh              # first-run: generates Phoenix app at books/app if missing
        ├── mix-docker           # run `mix ...` inside the phoenix container
        └── etc/init-sql/setup.sql
```

## Docker dev environment
- Stack: **Phoenix (myridia/phoenix image) + MySQL 8.0 + phpMyAdmin**
- MySQL: container `books_mysql`, db `books_dev` (+`books_test`), root password `${MYSQL_ROOT_PASSWORD:-BooksDev2026}`, data volume `mysql_data`
- Phoenix app lives at `books/app` (mounted as `/app`); auto-generated on first start by `init.sh` (`--no-html --no-gettext`, MyXQL adapter)
- Run: `cd dockers/dockers && docker-compose up -d` → app on :4000, phpMyAdmin on 127.0.0.1:8080
- `dev.yml`: alternative with jwilder/nginx-proxy + TLS certs (www.app.local) + fixed subnet 10.7.0.0/16
- Migrations run automatically at container start (`mix ecto.create && mix ecto.migrate`)
- Docker commands must be run by the user on the target host (not available in this dev container)

## Conventions
- No comments in code unless asked.
- Verify with `python3 -m py_compile extract_text.py`.
- Output defaults to `<input>.txt` next to the input file; `-o` overrides.

## Notes
- `build-essential`/`python3-dev` only needed if wheels for lxml/pymupdf are unavailable on the platform.
- MOBI path falls back to raw binary scan if the `mobi` library fails.
