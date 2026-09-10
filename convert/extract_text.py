#!/usr/bin/env python3
"""
Extract plain text from PDF, EPUB, and MOBI files.

Usage:
    extract-text <input_file> [-o output.txt]
    extract-text <directory>    # batch mode: processes all supported files
"""

import argparse
import re
import sys
from pathlib import Path
from html.parser import HTMLParser


# ---------------------------------------------------------------------------
# Minimal HTML → text converter (no external deps needed for EPUB fallback)
# ---------------------------------------------------------------------------
class _HTMLTextExtractor(HTMLParser):
    """Strip tags, collapse whitespace, emit text lines."""

    BLOCK_TAGS = frozenset([
        "p", "div", "br", "h1", "h2", "h3", "h4", "h5", "h6",
        "li", "tr", "blockquote", "pre", "section", "article",
    ])
    SKIP_TAGS = frozenset(["script", "style", "head"])

    def __init__(self):
        super().__init__()
        self._parts: list[str] = []
        self._skip_depth = 0

    def handle_starttag(self, tag, attrs):
        if tag in self.SKIP_TAGS:
            self._skip_depth += 1
        elif tag in self.BLOCK_TAGS:
            self._parts.append("\n")

    def handle_endtag(self, tag):
        if tag in self.SKIP_TAGS:
            self._skip_depth = max(0, self._skip_depth - 1)
        elif tag in self.BLOCK_TAGS:
            self._parts.append("\n")

    def handle_data(self, data):
        if self._skip_depth == 0:
            self._parts.append(data)

    def get_text(self) -> str:
        raw = "".join(self._parts)
        raw = re.sub(r"[^\S\n]+", " ", raw)
        raw = re.sub(r"\n{3,}", "\n\n", raw)
        return raw.strip()


def _html_to_text(html: str) -> str:
    parser = _HTMLTextExtractor()
    parser.feed(html)
    return parser.get_text()


# ---------------------------------------------------------------------------
# PDF extraction — PyMuPDF (fitz)
# ---------------------------------------------------------------------------
def extract_pdf(path: str) -> str:
    import fitz

    doc = fitz.open(path)
    pages: list[str] = []
    for page in doc:
        text = page.get_text("text", sort=True)
        if text.strip():
            pages.append(text)
    doc.close()
    return "\n\n".join(pages)


# ---------------------------------------------------------------------------
# EPUB extraction — ebooklib + BeautifulSoup
# ---------------------------------------------------------------------------
def extract_epub(path: str) -> str:
    from ebooklib import epub
    from bs4 import BeautifulSoup

    book = epub.read_epub(path, options={"ignore_ncx": True})
    parts: list[str] = []

    for item in book.get_items():
        if item.get_type() == epub.ITEM_DOCUMENT:
            html = item.get_content().decode("utf-8", errors="replace")
            soup = BeautifulSoup(html, "lxml")

            for nav in soup.find_all("nav"):
                nav.decompose()

            text = soup.get_text(separator="\n")
            text = re.sub(r"\n{3,}", "\n\n", text).strip()
            if text:
                parts.append(text)

    return "\n\n".join(parts)


# ---------------------------------------------------------------------------
# MOBI extraction — mobi package
# ---------------------------------------------------------------------------
def extract_mobi(path: str) -> str:
    try:
        from mobi import Mobi

        book = Mobi(path)
        book.parse()
        html = book.html().decode("utf-8", errors="replace")
        return _html_to_text(html)
    except Exception:
        pass

    with open(path, "rb") as f:
        data = f.read()

    markers = [b"<html", b"<HTML", b"<body", b"<BODY"]
    for marker in markers:
        idx = data.find(marker)
        if idx != -1:
            end = data.find(b"\x00\x00", idx)
            if end == -1:
                end = len(data)
            chunk = data[idx:end]
            try:
                return _html_to_text(chunk.decode("utf-8", errors="replace"))
            except Exception:
                continue

    raise RuntimeError(
        "Could not extract text from MOBI. "
        "Install calibre and use: ebook-convert input.mobi output.txt"
    )


# ---------------------------------------------------------------------------
# Dispatcher
# ---------------------------------------------------------------------------
EXTRACTORS = {
    ".pdf": extract_pdf,
    ".epub": extract_epub,
    ".mobi": extract_mobi,
}


def extract(file_path: str) -> str:
    ext = Path(file_path).suffix.lower()
    if ext not in EXTRACTORS:
        raise ValueError(f"Unsupported format: {ext}")
    return EXTRACTORS[ext](file_path)


def process_file(input_path: str, output_path: str | None) -> None:
    path = Path(input_path).resolve()
    if not path.is_file():
        print(f"[ERROR] Not a file: {path}", file=sys.stderr)
        return

    ext = path.suffix.lower()
    if ext not in EXTRACTORS:
        print(f"[SKIP] Unsupported format: {path.name}", file=sys.stderr)
        return

    print(f"[...] Extracting: {path.name}")
    try:
        text = extract(str(path))
    except Exception as e:
        print(f"[FAIL] {path.name}: {e}", file=sys.stderr)
        return

    if output_path:
        out = Path(output_path)
    else:
        out = path.with_suffix(".txt")

    out.write_text(text, encoding="utf-8")
    print(f"[OK]  -> {out}  ({len(text):,} chars)")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
def main() -> None:
    parser = argparse.ArgumentParser(
        description="Extract text from PDF, EPUB, and MOBI files."
    )
    parser.add_argument(
        "input",
        help="File or directory to process.",
    )
    parser.add_argument(
        "-o", "--output",
        help="Output .txt path (single-file mode only).",
        default=None,
    )
    args = parser.parse_args()

    target = Path(args.input).resolve()

    if target.is_dir():
        files = sorted(
            f for f in target.iterdir()
            if f.suffix.lower() in EXTRACTORS and f.is_file()
        )
        if not files:
            print("No supported files found in directory.", file=sys.stderr)
            sys.exit(1)
        for f in files:
            process_file(str(f), None)
    elif target.is_file():
        process_file(str(target), args.output)
    else:
        print(f"[ERROR] Path not found: {target}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
