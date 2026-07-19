# extract-text

Extract plain text from **PDF**, **EPUB**, and **MOBI** files.

## Requirements

### System packages (Debian/Ubuntu)

```bash
sudo apt-get update
sudo apt-get install -y python3 python3-venv python3-pip python3-dev build-essential
```

`build-essential` and `python3-dev` are needed to compile `lxml` and `pymupdf` from source if binary wheels are unavailable for your platform. On most x86_64 systems they install from prebuilt wheels and the dev headers are not strictly required, but having them avoids surprises.

### Python dependencies (managed by Poetry)

| Package | Purpose |
|---|---|
| `pymupdf` | PDF text extraction (most accurate, handles multi-column layouts) |
| `ebooklib` | EPUB parsing |
| `beautifulsoup4` | HTML → text conversion for EPUB content |
| `lxml` | Fast HTML parser used by BeautifulSoup |
| `mobi` | MOBI/KF8 unpacking and text extraction |

## Installation

```bash
cd /home/veto/webs/books

# install Poetry if not present
pip3 install poetry

# install project + all dependencies
poetry install
```

## Usage

### Single file

```bash
poetry run extract-text book.pdf
poetry run extract-text book.epub -o output.txt
poetry run extract-text book.mobi
```

Output defaults to `<input>.txt` in the same directory.

### Batch mode (whole directory)

```bash
poetry run extract-text /path/to/books/
```

Processes every `.pdf`, `.epub`, and `.mobi` file found in the directory.

### Without Poetry

```bash
python3 extract_text.py <file_or_directory> [-o output.txt]
```

Make sure the dependencies from the table above are installed in your Python environment.

## How it works

| Format | Strategy |
|---|---|
| **PDF** | `pymupdf` extracts raw text with reading-order sorting (`sort=True`) for correct multi-column output. |
| **EPUB** | Unpacked via `ebooklib`, each HTML document parsed by BeautifulSoup (`lxml`). Nav/TOC elements are stripped. |
| **MOBI** | The `mobi` package unwraps KF7/KF8 containers and exposes the inner HTML. Falls back to raw binary scanning if the library fails. |

## Project structure

```
books/
├── extract_text.py      # main script
├── pyproject.toml       # Poetry project config
└── README.md
```
