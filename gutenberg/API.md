# Gutenberg API notes

Documented while building the scripts in this folder. Verified on 2026-09-09.

## 1. Gutendex — the JSON API

- Base URL: `https://gutendex.com` (no auth).
- Endpoints:
  - `GET /books` — list/search all books (paginated).
  - `GET /books/{id}` — single book (redirects with trailing slash: `/books/2701/`).
  - `GET /authors/{id}` — author + their books.
- Catalog today: `count = 79357` books, 32 results per page → **2480 pages**.

### Query params (on /books)
| Param | Meaning |
|---|---|
| `search` | free-text search (title/author) |
| `sort` | `popular`, `ascending`, `random` |
| `languages` | comma list, e.g. `en,fr` |
| `ids` | comma list of book ids |
| `shelf` | bookshelf, e.g. `Science Fiction` |
| `mime_type` | e.g. `application/pdf`, `application/epub+zip` |
| `file_format` | e.g. `image/jpeg`, `text/plain; charset=utf-8` |
| `topic` | subject or bookshelf keyword |
| `authors_year_start` / `authors_year_end` | author birth/death year range |
| `page` | page number (1-based) |
| `page_size` | **not supported** — ignored, always 32 (verified) |

Pagination is via `page` and the `next`/`previous` links in each response.

### Response schema
```json
{
  "count": 79357,
  "next": "https://gutendex.com/books/?page=2",
  "previous": null,
  "results": [
    {
      "id": 2701,
      "title": "Moby Dick; Or, The Whale",
      "authors": [{"name": "Melville, Herman", "birth_year": 1819, "death_year": 1891}],
      "translators": [],                 // non-empty ⇒ it's a translation
      "bookshelves": ["Banned Books from Anne Haight's list"],
      "languages": ["en"],
      "copyright": false,
      "media_type": "Text",
      "formats": { "text/plain; charset=utf-8": "https://..." },
      "download_count": 123456
    }
  ]
}
```

### Useful facts
- Originals-only filter: keep books where `translators == []`; drop the rest.
- `sort=random` returns a random sample.
- Derived from the same data as the official catalog CSV (below).
- Be polite: sleep between requests when paginating (Gutendex is a third-party public service).

## 2. Official full-catalog downloads (one file, no API)
On www.gutenberg.org these replace thousands of API calls:

| URL | Size | Contents |
|---|---|---|
| `https://www.gutenberg.org/cache/epub/feeds/pg_catalog.csv.gz` | ~5.6 MB | full index CSV, updated nightly |
| `https://www.gutenberg.org/cache/epub/feeds/rdf-files.tar.bz2` | ~121 MB | one RDF per book (complete metadata) |

`pg_catalog.csv.gz` columns (header): `id,title,authors,translators,bookshelves,loans,subjects,languages,copyright,media_type,formats,...` — the `translators` column is the basis for the originals-only filter.

## 3. File downloads (book content)
- Single text via HTTP: `https://www.gutenberg.org/cache/epub/{id}/pg{id}.txt` (UTF-8 variant).
- Text encoding variants in the main collection:
  - `{id}.txt` (legacy/varies), `{id}-0.txt` (UTF-8), `{id}-8.txt` (ASCII); some books only have one variant.
- Generated (EPUB/MOBI/gen-htm): `https://www.gutenberg.org/cache/epub/{id}/pg{id}.epub` etc.
- Scraping the web site in a loop is throttled/discouraged — prefer mirrors (below).

## 4. Mirroring (rsync) — the official way to bulk-download
Two collections on the mirrors:

| Collection | Contents | rsync module | Path layout |
|---|---|---|---|
| main | curated HTML + plain text + zips + audio | `::gutenberg` | `1/2/3/4/{id}/` |
| generated | EPUB, MOBI, generated HTML | `::gutenberg-epub` | `{id}/` under root |

Mirror servers: `gutenberg.pglaf.org` (San Diego, fast) and `rsync.ibiblio.org` (main home).

- Download tree **without** walking the 6M-file source — `--files-from` requests exactly the wanted paths (fast, resumable):
  ```bash
  rsync -avHS -R --files-from=files.txt gutenberg.pglaf.org::gutenberg <dest>/
  ```
- Filter a full mirror to plain text only:
  ```bash
  rsync -avHS --include='*/' --include='*.txt' --exclude='*' gutenberg.pglaf.org::gutenberg <dest>/
  ```
- Size guidance: full main collection is ~1 TB (audio/html dominate). Text-only ≈ tens of GB. EPUB (generated) collection was ~218 GB in 2015, larger today.

## Scripts in this folder
- `book.sh <id>` — one book's JSON (`GET /books/{id}`).
- `search.sh "<query>"` — `GET /books?search=` → id/title/languages/authors table.
- `random.sh` — `GET /books?sort=random` sample.
- `index.sh` — paginated full index (`index.csv`, resume-safe). Could be replaced by a single `pg_catalog.csv.gz` download.