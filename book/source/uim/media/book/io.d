/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.book.io;

import uim.media.book.base;
import uim.media.book.metadata;
import uim.media.book.chapter;
import uim.media.book.toc;
import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.file;
import std.path;
import std.stdio;
import std.string;
import std.zip;

@safe:

/**
 * Main book file class
 */
class BookFile : BookData {
    BookMetadata metadata;
    Chapter[] chapters;
    TableOfContents toc;
    ubyte[] coverImage;
    string coverImageMimeType;
    
    // Reading progress
    ReadingProgress progress;
    Bookmark[] bookmarks;
    Annotation[] annotations;
    
    this() @safe {
        metadata = new BookMetadata();
        chapters = [];
        toc = new TableOfContents();
        bookmarks = [];
        annotations = [];
    }
    
    /**
     * Load book from file
     */
    static BookFile fromFile(string filename) @trusted {
        auto format = BookUtils.detectFormat(filename);
        
        final switch (format) with (BookFormat) {
            case epub:
                return EPUBReader.read(filename);
            case txt:
                return TextReader.read(filename);
            case markdown:
                return MarkdownReader.read(filename);
            case html:
                return HTMLReader.read(filename);
            case pdf:
            case mobi:
            case azw:
            case azw3:
            case rtf:
            case docx:
            case odt:
            case fb2:
            case djvu:
            case cbz:
            case cbr:
            case unknown:
                throw new BookException("Format not yet supported: " ~ format.to!string);
        }
    }
    
    /**
     * Save book to file
     */
    void saveToFile(string filename) @trusted {
        auto format = BookUtils.detectFormat(filename);
        
        final switch (format) with (BookFormat) {
            case epub:
                EPUBWriter.write(this, filename);
                break;
            case txt:
                TextWriter.write(this, filename);
                break;
            case markdown:
                MarkdownWriter.write(this, filename);
                break;
            case html:
                HTMLWriter.write(this, filename);
                break;
            case pdf:
            case mobi:
            case azw:
            case azw3:
            case rtf:
            case docx:
            case odt:
            case fb2:
            case djvu:
            case cbz:
            case cbr:
            case unknown:
                throw new BookException("Format not yet supported for writing: " ~ format.to!string);
        }
    }
    
    /**
     * Add a chapter
     */
    void addChapter(Chapter chapter) @safe {
        chapter.chapterNumber = chapters.length + 1;
        chapters ~= chapter;
    }
    
    /**
     * Get page count estimate
     */
    size_t pageCount() @safe {
        // Estimate based on word count (250 words per page)
        auto totalWords = getTotalWordCount();
        return (totalWords + 249) / 250;
    }
    
    /**
     * Get total word count
     */
    size_t getTotalWordCount() @safe {
        size_t total = 0;
        foreach (chapter; chapters) {
            total += chapter.getTotalWordCount();
        }
        return total;
    }
    
    /**
     * Extract all text content
     */
    string extractText() @safe {
        string result;
        foreach (chapter; chapters) {
            result ~= chapter.title ~ "\n\n";
            result ~= chapter.getPlainText() ~ "\n\n";
        }
        return result;
    }
    
    /**
     * Search within book
     */
    SearchResult[] search(string query) @trusted {
        SearchResult[] results;
        foreach (chapter; chapters) {
            results ~= chapter.search(query);
        }
        return results;
    }
    
    /**
     * Add bookmark
     */
    void addBookmark(Bookmark bookmark) @safe {
        bookmarks ~= bookmark;
    }
    
    /**
     * Add annotation
     */
    void addAnnotation(Annotation annotation) @safe {
        annotations ~= annotation;
    }
    
    /**
     * Update reading progress
     */
    void updateProgress(size_t currentPage) @safe {
        progress.currentPage = currentPage;
        progress.totalPages = pageCount();
        progress.updatePercentage();
    }
    
    /**
     * Convenience method to save as EPUB
     */
    void saveAsEPUB(string filename) @trusted {
        metadata.format = BookFormat.epub;
        EPUBWriter.write(this, filename);
    }
    
    override bool validate() @safe {
        return metadata.validate() && chapters.length > 0;
    }
    
    override size_t getSize() const @safe {
        size_t total = metadata.getSize();
        foreach (chapter; chapters) {
            total += chapter.getSize();
        }
        return total;
    }
}

/**
 * EPUB format reader
 */
private struct EPUBReader {
    static BookFile read(string filename) @trusted {
        auto book = new BookFile();
        book.metadata.format = BookFormat.epub;
        book.metadata.title = "Sample EPUB Book";
        book.metadata.addAuthor("Unknown Author");
        book.metadata.language = "en";
        
        // Add a sample chapter
        auto chapter = new Chapter("Chapter 1", "This is a placeholder for EPUB reading functionality.");
        book.addChapter(chapter);
        
        return book;
    }
}

/**
 * EPUB format writer
 */
private struct EPUBWriter {
    static void write(BookFile book, string filename) @trusted {
        // Placeholder implementation
        // Real implementation would create proper EPUB structure with:
        // - mimetype file
        // - META-INF/container.xml
        // - OEBPS/content.opf (metadata)
        // - OEBPS/toc.ncx (table of contents)
        // - OEBPS/Text/*.xhtml (chapters)
        
        throw new BookException("EPUB writing not yet fully implemented");
    }
}

/**
 * Plain text reader
 */
private struct TextReader {
    static BookFile read(string filename) @trusted {
        auto content = readText(filename);
        auto book = new BookFile();
        
        book.metadata.format = BookFormat.txt;
        book.metadata.title = baseName(filename, ".txt");
        book.metadata.language = "en";
        
        // Create single chapter with all content
        auto chapter = new Chapter("Content", content);
        book.addChapter(chapter);
        
        return book;
    }
}

/**
 * Plain text writer
 */
private struct TextWriter {
    static void write(BookFile book, string filename) @trusted {
        auto f = File(filename, "w");
        
        // Write metadata as header
        f.writeln(book.metadata.getFullTitle());
        f.writeln("=".replicate(book.metadata.getFullTitle().length));
        f.writeln();
        
        auto authors = book.metadata.getAuthors();
        if (authors.length > 0) {
            f.writeln("By: ", authors.join(", "));
            f.writeln();
        }
        
        // Write chapters
        foreach (chapter; book.chapters) {
            f.writeln();
            f.writeln(chapter.title);
            f.writeln("-".replicate(chapter.title.length));
            f.writeln();
            f.writeln(chapter.content);
            f.writeln();
        }
        
        f.close();
    }
}

/**
 * Markdown reader
 */
private struct MarkdownReader {
    static BookFile read(string filename) @trusted {
        auto content = readText(filename);
        auto book = new BookFile();
        
        book.metadata.format = BookFormat.markdown;
        book.metadata.title = baseName(filename, ".md");
        book.metadata.language = "en";
        
        // Parse markdown into chapters (simplified)
        auto lines = content.splitLines();
        Chapter currentChapter = null;
        string currentContent = "";
        
        foreach (line; lines) {
            if (line.startsWith("# ")) {
                // Main heading - new chapter
                if (currentChapter !is null) {
                    currentChapter.content = currentContent.strip;
                    book.addChapter(currentChapter);
                }
                currentChapter = new Chapter(line[2..$].strip, "");
                currentContent = "";
            } else {
                currentContent ~= line ~ "\n";
            }
        }
        
        // Add last chapter
        if (currentChapter !is null) {
            currentChapter.content = currentContent.strip;
            book.addChapter(currentChapter);
        } else {
            // No chapters found, create single chapter
            auto chapter = new Chapter("Content", content);
            book.addChapter(chapter);
        }
        
        return book;
    }
}

/**
 * Markdown writer
 */
private struct MarkdownWriter {
    static void write(BookFile book, string filename) @trusted {
        auto f = File(filename, "w");
        
        // Write frontmatter
        f.writeln("---");
        f.writeln("title: ", book.metadata.title);
        
        auto authors = book.metadata.getAuthors();
        if (authors.length > 0) {
            f.writeln("author: ", authors.join(", "));
        }
        
        if (book.metadata.language.length > 0) {
            f.writeln("language: ", book.metadata.language);
        }
        
        f.writeln("---");
        f.writeln();
        
        // Write chapters
        foreach (chapter; book.chapters) {
            f.writeln("# ", chapter.title);
            f.writeln();
            f.writeln(chapter.content);
            f.writeln();
        }
        
        f.close();
    }
}

/**
 * HTML reader
 */
private struct HTMLReader {
    static BookFile read(string filename) @trusted {
        auto content = readText(filename);
        auto book = new BookFile();
        
        book.metadata.format = BookFormat.html;
        book.metadata.title = baseName(filename, ".html");
        book.metadata.language = "en";
        
        // Create single chapter with HTML content
        auto chapter = new Chapter("Content", content);
        book.addChapter(chapter);
        
        return book;
    }
}

/**
 * HTML writer
 */
private struct HTMLWriter {
    static void write(BookFile book, string filename) @trusted {
        auto f = File(filename, "w");
        
        // Write HTML header
        f.writeln("<!DOCTYPE html>");
        f.writeln("<html lang=\"", book.metadata.language, "\">");
        f.writeln("<head>");
        f.writeln("  <meta charset=\"UTF-8\">");
        f.writeln("  <title>", book.metadata.getFullTitle(), "</title>");
        f.writeln("</head>");
        f.writeln("<body>");
        
        // Write title
        f.writeln("  <h1>", book.metadata.getFullTitle(), "</h1>");
        
        auto authors = book.metadata.getAuthors();
        if (authors.length > 0) {
            f.writeln("  <p class=\"author\">By ", authors.join(", "), "</p>");
        }
        
        // Write chapters
        foreach (chapter; book.chapters) {
            f.writeln("  <section>");
            f.writeln("    <h2>", chapter.title, "</h2>");
            f.writeln("    <div>", chapter.content, "</div>");
            f.writeln("  </section>");
        }
        
        f.writeln("</body>");
        f.writeln("</html>");
        
        f.close();
    }
}
