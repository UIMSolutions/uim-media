/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
import std.stdio;
import uim.media.book;

void main() {
    writeln("=== UIM Book Library - Basic Usage Examples ===\n");
    
    // Example 1: Create a simple book
    example1_createBook();
    
    // Example 2: Work with metadata
    example2_metadata();
    
    // Example 3: Chapters and TOC
    example3_chapters();
    
    // Example 4: Reading and searching
    example4_readingAndSearch();
    
    // Example 5: Collections
    example5_collections();
    
    writeln("\nAll examples completed successfully!");
}

/// Create a simple book and save it
void example1_createBook() {
    writeln("Example 1: Creating a book");
    writeln("--------------------------");
    
    auto book = new BookFile();
    
    // Set metadata
    book.metadata.title = "My First Book";
    book.metadata.subtitle = "A Journey into D Programming";
    book.metadata.addAuthor("John Doe");
    book.metadata.publisher = "Tech Publishers";
    book.metadata.language = "en";
    book.metadata.description = "An introductory book about D programming language.";
    
    // Add chapters
    auto chapter1 = new Chapter("Introduction", 
        "Welcome to the world of D programming. This chapter introduces the basics...");
    book.addChapter(chapter1);
    
    auto chapter2 = new Chapter("Getting Started",
        "Let's write our first D program. We'll explore the syntax and basic concepts...");
    book.addChapter(chapter2);
    
    auto chapter3 = new Chapter("Advanced Topics",
        "Now that you understand the basics, let's dive into advanced features...");
    book.addChapter(chapter3);
    
    // Save as text file
    book.saveToFile("mybook.txt");
    writeln("Created: mybook.txt");
    writeln("  - Title: ", book.metadata.title);
    writeln("  - Chapters: ", book.chapters.length);
    writeln("  - Word count: ", book.getTotalWordCount());
    writeln("  - Estimated pages: ", book.pageCount());
    writeln();
}

/// Work with metadata
void example2_metadata() {
    writeln("Example 2: Working with metadata");
    writeln("--------------------------------");
    
    auto metadata = new BookMetadata();
    
    // Basic info
    metadata.title = "The D Programming Language";
    metadata.addAuthor("Andrei Alexandrescu");
    metadata.publisher = "Addison-Wesley";
    metadata.setPublicationDate("2010-06-01");
    metadata.language = "en";
    
    // ISBN
    metadata.isbn = ISBN("978-0321635365");
    writeln("ISBN valid: ", metadata.isbn.isValid());
    writeln("ISBN formatted: ", metadata.isbn.formatted());
    writeln("ISBN-13: ", metadata.isbn.toISBN13());
    
    // Categories and subjects
    metadata.category = BookCategory.technology;
    metadata.subjects = ["Programming", "Computer Science", "D Language"];
    metadata.keywords = ["programming", "systems", "metaprogramming"];
    
    // Series
    metadata.seriesTitle = "Programming Language Series";
    metadata.seriesNumber = 1;
    
    // Display metadata
    writeln();
    writeln(metadata.toString());
    
    // Export to Dublin Core
    auto dc = metadata.toDublinCore();
    writeln("Dublin Core export:");
    foreach (key, value; dc) {
        writeln("  ", key, ": ", value);
    }
    writeln();
}

/// Working with chapters and table of contents
void example3_chapters() {
    writeln("Example 3: Chapters and Table of Contents");
    writeln("------------------------------------------");
    
    auto book = new BookFile();
    book.metadata.title = "Programming Guide";
    
    // Create chapter with sub-sections
    auto mainChapter = new Chapter("Chapter 1: Fundamentals");
    mainChapter.content = "This chapter covers fundamental concepts...";
    
    // Add sub-chapters
    auto section1 = new Chapter("1.1 Variables", "Variables are containers for data...");
    auto section2 = new Chapter("1.2 Functions", "Functions are reusable blocks of code...");
    auto section3 = new Chapter("1.3 Control Flow", "Control flow determines execution order...");
    
    mainChapter.addChild(section1);
    mainChapter.addChild(section2);
    mainChapter.addChild(section3);
    
    book.addChapter(mainChapter);
    
    // Add another chapter
    auto chapter2 = new Chapter("Chapter 2: Advanced Topics");
    chapter2.content = "Now we explore advanced concepts...";
    book.addChapter(chapter2);
    
    // Build table of contents
    book.toc.buildFromChapters(book.chapters);
    
    writeln("Table of Contents:");
    writeln(book.toc.toPlainText());
    
    // Chapter statistics
    writeln("Chapter statistics:");
    writeln("  Total chapters: ", book.chapters.length);
    writeln("  Total words: ", book.getTotalWordCount());
    writeln("  Reading time: ", BookUtils.formatReadingTime(
        BookUtils.estimateReadingTime(book.getTotalWordCount())));
    writeln();
}

/// Reading and searching
void example4_readingAndSearch() {
    writeln("Example 4: Reading and Searching");
    writeln("--------------------------------");
    
    auto book = new BookFile();
    book.metadata.title = "Search Demo";
    
    auto chapter1 = new Chapter("Introduction",
        "The quick brown fox jumps over the lazy dog. " ~
        "This is a sample text for demonstration purposes.");
    
    auto chapter2 = new Chapter("Content",
        "More sample content here. The fox appears again in this chapter.");
    
    book.addChapter(chapter1);
    book.addChapter(chapter2);
    
    // Extract all text
    auto fullText = book.extractText();
    writeln("Full text length: ", fullText.length, " characters");
    writeln("Word count: ", BookUtils.countWords(fullText));
    
    // Search for a word
    auto results = book.search("fox");
    writeln("\nSearch results for 'fox':");
    writeln("  Found ", results.length, " occurrences");
    
    foreach (i, result; results) {
        writeln("  ", i + 1, ". Chapter ", result.chapterIndex + 1, 
                " at position ", result.position);
        writeln("     Context: \"", result.context, "\"");
    }
    
    // Add bookmarks
    auto bookmark = Bookmark.create("Interesting part", 0, 10);
    book.addBookmark(bookmark);
    writeln("\nBookmarks: ", book.bookmarks.length);
    
    // Track progress
    book.updateProgress(1);
    writeln("Reading progress: ", book.progress.percentage, "%");
    writeln();
}

/// Working with collections
void example5_collections() {
    writeln("Example 5: Book Collections");
    writeln("---------------------------");
    
    auto collection = new BookCollection("My Library");
    
    // Add several books
    auto book1 = new BookMetadata();
    book1.title = "D Programming";
    book1.addAuthor("Author One");
    book1.category = BookCategory.technology;
    collection.addBook(book1);
    
    auto book2 = new BookMetadata();
    book2.title = "Science Fiction Novel";
    book2.addAuthor("Author Two");
    book2.category = BookCategory.scienceFiction;
    collection.addBook(book2);
    
    auto book3 = new BookMetadata();
    book3.title = "Another Tech Book";
    book3.addAuthor("Author One");
    book3.category = BookCategory.technology;
    collection.addBook(book3);
    
    writeln("Collection: ", collection.collectionName);
    writeln("Total books: ", collection.count);
    
    // Find books by author
    auto byAuthor = collection.findByAuthor("Author One");
    writeln("\nBooks by 'Author One': ", byAuthor.length);
    foreach (book; byAuthor) {
        writeln("  - ", book.title);
    }
    
    // Get books by category
    auto techBooks = collection.getByCategory(BookCategory.technology);
    writeln("\nTechnology books: ", techBooks.length);
    foreach (book; techBooks) {
        writeln("  - ", book.title);
    }
    
    // Sort collection
    collection.sortByTitle();
    writeln("\nBooks sorted by title:");
    foreach (book; collection.books) {
        writeln("  - ", book.title);
    }
    writeln();
}
