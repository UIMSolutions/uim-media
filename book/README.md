# UIM Media - Book Library

A comprehensive D language library for working with book and ebook formats.

## Features

- **Multiple Format Support**: 
  - EPUB (Electronic Publication)
  - PDF (Portable Document Format)
  - MOBI/AZW (Amazon Kindle formats)
  - Plain Text
  - Markdown
  - HTML
- **Metadata Management**: Extract and modify book metadata
  - Title, Author, Publisher
  - ISBN, Language, Publication Date
  - Subject, Description, Rights
  - Series information
- **Content Structure**: 
  - Chapter management
  - Table of Contents (TOC)
  - Section navigation
  - Page handling
- **Text Operations**:
  - Full-text search
  - Content extraction
  - Text formatting
- **Cover Image Support**: Extract and manage cover images

## Installation

Add to your `dub.sdl`:
```sdl
dependency "uim-media-book" version="~>1.0.0"
```

Or to your `dub.json`:
```json
"dependencies": {
    "uim-media-book": "~>1.0.0"
}
```

## Quick Start

```d
import uim.media.book;

// Read an EPUB file
auto book = BookFile.fromFile("mybook.epub");

// Access metadata
writeln("Title: ", book.metadata.title);
writeln("Author: ", book.metadata.author);
writeln("ISBN: ", book.metadata.isbn);
writeln("Pages: ", book.pageCount);

// Get table of contents
foreach (chapter; book.tableOfContents) {
    writeln("Chapter: ", chapter.title);
}

// Extract text content
auto text = book.extractText();
writeln("Book contains ", text.length, " characters");

// Search within the book
auto results = book.search("keyword");
foreach (result; results) {
    writeln("Found at chapter ", result.chapterIndex, 
            ", page ", result.page);
}

// Create a new book
auto newBook = new BookFile();
newBook.metadata.title = "My Book";
newBook.metadata.author = "Author Name";
newBook.metadata.language = "en";

// Add chapters
auto chapter1 = new Chapter("Chapter 1", "Content of chapter 1...");
newBook.addChapter(chapter1);

// Save as EPUB
newBook.saveAsEPUB("output.epub");
```

## Supported Formats

### EPUB (Full Support)
- EPUB 2.0 and 3.0
- Metadata extraction and modification
- TOC parsing
- Content extraction
- Cover image handling

### PDF (Metadata Support)
- Metadata extraction
- Text extraction
- Page count
- Basic structure information

### Plain Text / Markdown (Full Support)
- Metadata from frontmatter
- Chapter detection
- Format conversion

### MOBI/AZW (Basic Support)
- Metadata extraction
- Header parsing

## Documentation

See the examples directory for more usage examples.

## License

Apache 2.0 - Copyright © 2018-2026 Ozan Nurettin Süel
