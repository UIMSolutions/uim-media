/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.book.toc;

import uim.media.book.base;
import uim.media.book.chapter;
import std.algorithm;
import std.array;
import std.conv;
import std.string;

@safe:

/**
 * Table of Contents entry
 */
struct TOCEntry {
    string title;
    size_t level;         // Nesting level
    size_t chapterIndex;  // Index in chapters array
    string href;          // Link/reference
    size_t page;          // Page number (if available)
    
    TOCEntry[] children;  // Sub-entries
    
    /// Create a new TOC entry
    static TOCEntry create(string title, size_t level = 0, size_t chapterIndex = 0) @safe {
        TOCEntry entry;
        entry.title = title;
        entry.level = level;
        entry.chapterIndex = chapterIndex;
        entry.children = [];
        return entry;
    }
    
    /// Add a child entry
    void addChild(TOCEntry child) @safe {
        child.level = this.level + 1;
        children ~= child;
    }
    
    /// Get all descendants
    TOCEntry[] getAllDescendants() @safe {
        TOCEntry[] result = children.dup;
        foreach (child; children) {
            result ~= child.getAllDescendants();
        }
        return result;
    }
    
    /// Convert to string with indentation
    string toString() const @safe {
        string indent = "";
        for (size_t i = 0; i < level; i++) {
            indent ~= "  ";
        }
        
        string result = indent ~ title;
        if (page > 0) {
            result ~= " ................... " ~ to!string(page);
        }
        result ~= "\n";
        
        foreach (child; children) {
            result ~= child.toString();
        }
        
        return result;
    }
}

/**
 * Table of Contents manager
 */
class TableOfContents : BookData {
    TOCEntry[] entries;
    string title = "Table of Contents";
    
    this() @safe {
        entries = [];
    }
    
    /**
     * Add a top-level entry
     */
    void addEntry(TOCEntry entry) @safe {
        entry.level = 0;
        entries ~= entry;
    }
    
    /**
     * Build TOC from chapters
     */
    void buildFromChapters(Chapter[] chapters) @safe {
        entries = [];
        
        foreach (i, chapter; chapters) {
            auto entry = TOCEntry.create(chapter.title, 0, i);
            entry.page = chapter.startPage;
            
            // Add child chapters
            foreach (j, child; chapter.children) {
                auto childEntry = TOCEntry.create(child.title, 1, i);
                childEntry.page = child.startPage;
                entry.addChild(childEntry);
            }
            
            entries ~= entry;
        }
    }
    
    /**
     * Get flat list of all entries
     */
    TOCEntry[] getAllEntries() @safe {
        TOCEntry[] result = entries.dup;
        foreach (entry; entries) {
            result ~= entry.getAllDescendants();
        }
        return result;
    }
    
    /**
     * Find entry by title
     */
    TOCEntry* findEntry(string title) @trusted {
        auto allEntries = getAllEntries();
        foreach (ref entry; allEntries) {
            if (entry.title.toLower == title.toLower) {
                return &entry;
            }
        }
        return null;
    }
    
    /**
     * Get entry by chapter index
     */
    TOCEntry* getEntry(size_t chapterIndex) @trusted {
        auto allEntries = getAllEntries();
        foreach (ref entry; allEntries) {
            if (entry.chapterIndex == chapterIndex) {
                return &entry;
            }
        }
        return null;
    }
    
    /**
     * Get total number of entries
     */
    size_t getEntryCount() @safe {
        return getAllEntries().length;
    }
    
    /**
     * Export to HTML
     */
    string toHTML() @safe {
        string html = "<nav id=\"toc\">\n";
        html ~= "  <h2>" ~ title ~ "</h2>\n";
        html ~= "  <ol>\n";
        
        foreach (entry; entries) {
            html ~= entryToHTML(entry, 2);
        }
        
        html ~= "  </ol>\n";
        html ~= "</nav>\n";
        return html;
    }
    
    private string entryToHTML(TOCEntry entry, size_t indentLevel) @safe {
        string indent = "";
        for (size_t i = 0; i < indentLevel; i++) {
            indent ~= "  ";
        }
        
        string html = indent ~ "<li>";
        
        if (entry.href.length > 0) {
            html ~= "<a href=\"" ~ entry.href ~ "\">" ~ entry.title ~ "</a>";
        } else {
            html ~= entry.title;
        }
        
        if (entry.children.length > 0) {
            html ~= "\n" ~ indent ~ "  <ol>\n";
            foreach (child; entry.children) {
                html ~= entryToHTML(child, indentLevel + 2);
            }
            html ~= indent ~ "  </ol>\n" ~ indent;
        }
        
        html ~= "</li>\n";
        return html;
    }
    
    /**
     * Export to plain text
     */
    string toPlainText() @safe {
        string result = title ~ "\n";
        result ~= "=" ~ "=".replicate(title.length) ~ "\n\n";
        
        foreach (entry; entries) {
            result ~= entry.toString();
        }
        
        return result;
    }
    
    override bool validate() @safe {
        return entries.length > 0;
    }
    
    override size_t getSize() const @safe {
        size_t total = 0;
        foreach (entry; entries) {
            total += entry.title.length;
        }
        return total;
    }
    
    override string toString() const @safe {
        return toPlainText();
    }
}

/**
 * Navigation helper for books
 */
struct BookNavigator {
    Chapter[] chapters;
    size_t currentChapter;
    
    /// Initialize navigator with chapters
    static BookNavigator create(Chapter[] chapters) @safe {
        BookNavigator nav;
        nav.chapters = chapters;
        nav.currentChapter = 0;
        return nav;
    }
    
    /// Go to next chapter
    bool nextChapter() @safe {
        if (currentChapter < chapters.length - 1) {
            currentChapter++;
            return true;
        }
        return false;
    }
    
    /// Go to previous chapter
    bool previousChapter() @safe {
        if (currentChapter > 0) {
            currentChapter--;
            return true;
        }
        return false;
    }
    
    /// Go to specific chapter
    bool gotoChapter(size_t index) @safe {
        if (index < chapters.length) {
            currentChapter = index;
            return true;
        }
        return false;
    }
    
    /// Get current chapter
    Chapter getCurrentChapter() @safe {
        if (currentChapter < chapters.length) {
            return chapters[currentChapter];
        }
        return null;
    }
    
    /// Check if at first chapter
    bool isFirstChapter() const @safe {
        return currentChapter == 0;
    }
    
    /// Check if at last chapter
    bool isLastChapter() const @safe {
        return currentChapter == chapters.length - 1;
    }
    
    /// Get progress percentage
    double getProgress() const @safe {
        if (chapters.length == 0) return 0.0;
        return (cast(double)currentChapter / chapters.length) * 100.0;
    }
}
