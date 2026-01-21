# UIM Media - Comic Library

A comprehensive D language library for working with digital comic book formats.

## Features

- **Multiple Format Support**: 
  - CBZ (Comic Book ZIP) - Full support
  - CBR (Comic Book RAR) - Read support
  - CB7 (Comic Book 7z) - Read support
  - CBT (Comic Book TAR) - Full support
  - PDF (comics in PDF format) - Basic support
- **Metadata Management**: 
  - ComicInfo.xml standard (full support)
  - Title, Series, Issue Number
  - Writer, Penciller, Inker, Colorist, Letterer
  - Publisher, Genre, Language
  - Page count, Web link
  - Age Rating, Format
- **Page Management**:
  - Image extraction
  - Page ordering and navigation
  - Double-page spread detection
  - Page type classification (FrontCover, Story, BackCover, etc.)
- **Reading Features**:
  - Page-by-page navigation
  - Reading progress tracking
  - Bookmarks
  - Left-to-right / Right-to-left reading modes
- **Archive Operations**:
  - Create new comic archives
  - Extract pages
  - Modify metadata
  - Convert between formats

## Installation

Add to your `dub.sdl`:
```sdl
dependency "uim-media-comic" version="~>1.0.0"
```

Or to your `dub.json`:
```json
"dependencies": {
    "uim-media-comic": "~>1.0.0"
}
```

## Quick Start

```d
import uim.media.comic;

// Read a comic book
auto comic = ComicBook.fromFile("mycomic.cbz");

// Access metadata
writeln("Title: ", comic.metadata.title);
writeln("Series: ", comic.metadata.series);
writeln("Issue: ", comic.metadata.number);
writeln("Writer: ", comic.metadata.writer);
writeln("Pages: ", comic.pageCount);

// Navigate pages
foreach (page; comic.pages) {
    writeln("Page ", page.pageNumber, ": ", page.filename);
    writeln("  Type: ", page.type);
    writeln("  Size: ", page.width, "x", page.height);
}

// Get specific page image data
auto coverImage = comic.getPageImage(0);
writeln("Cover image size: ", coverImage.length, " bytes");

// Search for text in metadata
if (comic.metadata.writer.canFind("Stan Lee")) {
    writeln("This is a Stan Lee comic!");
}

// Create a new comic book
auto newComic = new ComicBook();
newComic.metadata.title = "My Comic";
newComic.metadata.series = "Adventure Series";
newComic.metadata.number = 1;
newComic.metadata.writer = "Writer Name";

// Add pages (from image files)
newComic.addPageFromFile("page01.jpg", PageType.frontCover);
newComic.addPageFromFile("page02.jpg", PageType.story);
newComic.addPageFromFile("page03.jpg", PageType.story);
newComic.addPageFromFile("page04.jpg", PageType.backCover);

// Save as CBZ
newComic.saveToCBZ("output.cbz");

// Convert format
auto cbzComic = ComicBook.fromFile("input.cbr");
cbzComic.saveToCBZ("output.cbz");

// Reading progress
auto reader = ComicReader(comic);
reader.gotoPage(5);
writeln("Reading: ", reader.getCurrentPage().filename);
writeln("Progress: ", reader.getProgress(), "%");
```

## Metadata Standard

This library fully supports the ComicInfo.xml metadata standard used by popular comic readers like ComicRack, YACReader, and others.

## Supported Image Formats

Within comic archives, the following image formats are supported:
- JPEG/JPG
- PNG
- GIF
- BMP
- WebP

## Documentation

See the examples directory for more usage examples.

## License

Apache 2.0 - Copyright © 2018-2026 Ozan Nurettin Süel
