# LLM Training Corpora — Where to Get Text Data

## General / Web Scrapes

| Corpus | Description | Source |
|---|---|---|
| **Common Crawl** | Petabytes of raw web crawl data; foundation for most LLMs | [commoncrawl.org](https://commoncrawl.org) |
| **C4** (Colossal Clean Crawled Corpus) | Google's cleaned Common Crawl subset, used for T5 | [Hugging Face](https://huggingface.co/datasets/allenai/c4) |
| **FineWeb** | 15T tokens of cleaned web data, one of the best open web corpora | [Hugging Face](https://huggingface.co/datasets/HuggingFaceFW/fineweb) |
| **RefinedWeb** | Used for Falcon models | [Hugging Face](https://huggingface.co/datasets/tiiuae/falcon-refinedweb) |
| **RedPajama** | Reproduction of LLaMA training data (1.2T tokens) | [Hugging Face](https://huggingface.co/datasets/togethercomputer/RedPajama-Data-1T) |

## Books

| Corpus | Description | Source |
|---|---|---|
| **Project Gutenberg** | 70k+ public domain books | [gutenberg.org](https://www.gutenberg.org) |
| **BookCorpus** | 11k+ unpublished books | [Hugging Face](https://huggingface.co/datasets/bookcorpus) |
| **Books3** | Large book collection (check licensing) | [Hugging Face](https://huggingface.co/datasets/the_pile/books3) |
| **PG-19** | 19th century books from Gutenberg | [Hugging Face](https://huggingface.co/datasets/deepmind/pg19) |

## Encyclopedias / Reference

| Corpus | Description | Source |
|---|---|---|
| **Wikipedia** | Full article dumps in 300+ languages | [dumps.wikimedia.org](https://dumps.wikimedia.org) |
| **Wiktionary** | Dictionary entries | [dumps.wikimedia.org](https://dumps.wikimedia.org) |
| **Wikiquote** | Quotations | [dumps.wikimedia.org](https://dumps.wikimedia.org) |
| **Wikibooks** | Textbooks | [dumps.wikimedia.org](https://dumps.wikimedia.org) |

## Code

| Corpus | Description | Source |
|---|---|---|
| **The Stack** (BigCode) | Permissively licensed code from GitHub | [Hugging Face](https://huggingface.co/datasets/bigcode/the-stack) |
| **StarCoder Data** | Filtered GitHub repos | [Hugging Face](https://huggingface.co/datasets/bigcode/starcoderdata) |
| **The Stack v2** | 900+ languages, 67TB compressed | [Hugging Face](https://huggingface.co/datasets/bigcode/starcoder2) |

## Scientific / Academic

| Corpus | Description | Source |
|---|---|---|
| **arXiv** | Full text of preprint papers | [AWS Open Data](https://registry.opendata.aws/arxiv/) |
| **PubMed Central** | Biomedical papers (open access subset) | [ncbi.nlm.nih.gov](https://www.ncbi.nlm.nih.gov/pmc/) |
| **Semantic Scholar** | 200M+ research papers | [allenai.org](https://www.semanticscholar.org/product/semantic-reader) |
| **S2ORC** | Scholarly article citations + full text | [Hugging Face](https://huggingface.co/datasets/allenai/s2orc) |

## Multi-language

| Corpus | Description | Source |
|---|---|---|
| **OSCAR** | Filtered Common Crawl in 160+ languages | [Hugging Face](https://huggingface.co/datasets/oscar-corpus/OSCAR-2301) |
| **CC-100** | Used for XLM-R training | [Hugging Face](https://huggingface.co/datasets/cc100) |
| **MC4** (Multilingual C4) | Multilingual version of C4 | [Hugging Face](https://huggingface.co/datasets/allenai/mc4) |
| **WikiMatrix** | Parallel sentences from Wikipedia in 85 languages | [Hugging Face](https://huggingface.co/datasets/facebook/wiki_matrix) |

## Download Platforms

| Platform | URL |
|---|---|
| **Hugging Face Datasets** | [huggingface.co/datasets](https://huggingface.co/datasets) |
| **Kaggle Datasets** | [kaggle.com/datasets](https://www.kaggle.com/datasets) |
| **AWS Open Data** | [aws.amazon.com/open-data](https://aws.amazon.com/open-data/) |
| **Google Dataset Search** | [datasetsearch.research.google.com](https://datasetsearch.research.google.com) |

## Licensing Notes

- **Public domain**: Project Gutenberg, Wikidata
- **Permissive**: The Stack, StarCoder, Wikipedia, OSCAR
- **Research only**: Books3, BookCorpus (check each dataset's license)
- **Web-scraped**: Common Crawl, C4, FineWeb — may contain copyrighted content; newer corpora (FineWeb, RedefinedWeb) include filtering for permissively licensed content
