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
└── README.md
```

## Conventions
- No comments in code unless asked.
- Verify with `python3 -m py_compile extract_text.py`.
- Output defaults to `<input>.txt` next to the input file; `-o` overrides.

## Notes
- `build-essential`/`python3-dev` only needed if wheels for lxml/pymupdf are unavailable on the platform.
- MOBI path falls back to raw binary scan if the `mobi` library fails.
