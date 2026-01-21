/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
import std.stdio;
import std.file;
import uim.media.book;

void main() {
    writeln("Running Book Library Tests...\n");
    
    testISBN();
    testMetadata();
    testChapters();
    testTOC();
    testBookCreation();
    testFileIO();
    testSearch();
    testUtils();
    testCollections();
    
    writeln("\n✓ All tests passed!");
}

void testISBN() {
    writeln("Test: ISBN validation");
    
    // Valid ISBN-10
    auto isbn10 = ISBN("0321635361");
    assert(isbn10.isValid(), "Valid ISBN-10 should pass");
    
    // Valid ISBN-13
    auto isbn13 = ISBN("978-0-321-63536-5");
    assert(isbn13.isValid(), "Valid ISBN-13 should pass");
    
    // ISBN-10 to ISBN-13 conversion
    auto converted = isbn10.toISBN13();
    assert(converted.length == 13, "Converted ISBN should be 13 digits");
    
    writeln("  ✓ ISBN validation");
}

void testMetadata() {
    writeln("Test: Book metadata");
    
    auto metadata = new BookMetadata();
    metadata.title = "Test Book";
    metadata.addAuthor("Test Author");
    metadata.publisher = "Test Publisher";
    metadata.language = "en";
    
    assert(metadata.title == "Test Book", "Title should be set");
    assert(metadata.getAuthor() == "Test Author", "Author should be set");
    assert(metadata.isComplete(), "Metadata should be complete");
    assert(metadata.validate(), "Metadata should validate");
    
    // Test contributors
    metadata.addContributor("Editor Name", "edt");
    assert(metadata.contributors.length == 2, "Should have 2 contributors");
    
    // Test publication date
    metadata.setPublicationDate("2024-01-15");
    assert(metadata.getPublicationYear() == "2024", "Year should be 2024");
    
    writeln("  ✓ Metadata");
}

void testChapters() {
    writeln("Test: Chapters");
    
    auto chapter = new Chapter("Test Chapter", "This is test content.");
    assert(chapter.title == "Test Chapter", "Chapter title should be set");
    assert(chapter.content.length > 0, "Chapter should have content");
    
    chapter.updateCounts();
    assert(chapter.wordCount > 0, "Word count should be calculated");
    assert(chapter.characterCount > 0, "Character count should be calculated");
    
    // Test sub-chapters
    auto subChapter = new Chapter("Sub Chapter", "Sub content");
    chapter.addChild(subChapter);
    assert(chapter.children.length == 1, "Should have 1 child");
    assert(subChapter.level == chapter.level + 1, "Child level should be incremented");
    
    // Test total word count
    auto totalWords = chapter.getTotalWordCount();
    assert(totalWords > chapter.wordCount, "Total should include children");
    
    writeln("  ✓ Chapters");
}

void testTOC() {
    writeln("Test: Table of Contents");
    
    auto toc = new TableOfContents();
    
    auto entry1 = TOCEntry.create("Chapter 1", 0, 0);
    entry1.page = 1;
    toc.addEntry(entry1);
    
    auto entry2 = TOCEntry.create("Chapter 2", 0, 1);
    entry2.page = 10;
    toc.addEntry(entry2);
    
    assert(toc.entries.length == 2, "Should have 2 entries");
    assert(toc.validate(), "TOC should validate");
    
    // Test entry lookup
    auto found = toc.findEntry("Chapter 1");
    assert(found !is null, "Should find entry");
    assert(found.title == "Chapter 1", "Found entry should match");
    
    writeln("  ✓ Table of Contents");
}

void testBookCreation() {
    writeln("Test: Book creation");
    
    auto book = new BookFile();
    book.metadata.title = "Test Book";
    book.metadata.addAuthor("Test Author");
    book.metadata.language = "en";
    
    auto chapter1 = new Chapter("Chapter 1", "Content 1");
    auto chapter2 = new Chapter("Chapter 2", "Content 2");
    
    book.addChapter(chapter1);
    book.addChapter(chapter2);
    
    assert(book.chapters.length == 2, "Should have 2 chapters");
    assert(book.validate(), "Book should validate");
    assert(book.getTotalWordCount() > 0, "Should have word count");
    assert(book.pageCount() > 0, "Should have page count");
    
    writeln("  ✓ Book creation");
}

void testFileIO() {
    writeln("Test: File I/O");
    
    auto book = new BookFile();
    book.metadata.title = "Test Book";
    book.metadata.addAuthor("Test Author");
    book.metadata.language = "en";
    
    auto chapter = new Chapter("Chapter 1", "Test content for file I/O.");
    book.addChapter(chapter);
    
    // Save as text
    string txtFile = "test_book.txt";
    book.saveToFile(txtFile);
    assert(exists(txtFile), "Text file should be created");
    
    // Read back
    auto loadedBook = BookFile.fromFile(txtFile);
    assert(loadedBook !is null, "Should load book");
    assert(loadedBook.chapters.length > 0, "Loaded book should have chapters");
    
    // Clean up
    remove(txtFile);
    
    // Test Markdown
    string mdFile = "test_book.md";
    book.saveToFile(mdFile);
    assert(exists(mdFile), "Markdown file should be created");
    
    auto mdBook = BookFile.fromFile(mdFile);
    assert(mdBook !is null, "Should load markdown book");
    
    remove(mdFile);
    
    writeln("  ✓ File I/O");
}

void testSearch() {
    writeln("Test: Search functionality");
    
    auto book = new BookFile();
    auto chapter = new Chapter("Test", "The quick brown fox jumps over the lazy dog.");
    book.addChapter(chapter);
    
    auto results = book.search("fox");
    assert(results.length > 0, "Should find search results");
    assert(results[0].matchedText == "fox", "Should match search term");
    
    // Test no results
    auto noResults = book.search("elephant");
    assert(noResults.length == 0, "Should have no results");
    
    writeln("  ✓ Search");
}

void testUtils() {
    writeln("Test: Utility functions");
    
    // Test format detection
    auto format = BookUtils.detectFormat("test.epub");
    assert(format == BookFormat.epub, "Should detect EPUB format");
    
    format = BookUtils.detectFormat("test.pdf");
    assert(format == BookFormat.pdf, "Should detect PDF format");
    
    // Test word counting
    auto wordCount = BookUtils.countWords("Hello world, this is a test.");
    assert(wordCount == 6, "Should count 6 words");
    
    // Test reading time estimation
    auto readingTime = BookUtils.estimateReadingTime(500);
    assert(readingTime == 2, "500 words should take ~2 minutes");
    
    // Test snippet extraction
    auto snippet = BookUtils.extractSnippet("The quick brown fox", 4, 5);
    assert(snippet.length > 0, "Should extract snippet");
    
    writeln("  ✓ Utils");
}

void testCollections() {
    writeln("Test: Book collections");
    
    auto collection = new BookCollection("Test Library");
    
    auto book1 = new BookMetadata();
    book1.title = "Book One";
    book1.addAuthor("Author A");
    
    auto book2 = new BookMetadata();
    book2.title = "Book Two";
    book2.addAuthor("Author B");
    
    collection.addBook(book1);
    collection.addBook(book2);
    
    assert(collection.count == 2, "Should have 2 books");
    
    // Test search
    auto found = collection.findByAuthor("Author A");
    assert(found.length == 1, "Should find 1 book");
    assert(found[0].title == "Book One", "Should find correct book");
    
    // Test sorting
    collection.sortByTitle();
    assert(collection.books[0].title == "Book One", "Should be sorted");
    
    writeln("  ✓ Collections");
}
