/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.book.chapter;

import uim.media.book.base;
import std.algorithm;
import std.array;
import std.conv;
import std.string;

@safe:

/**
 * Represents a chapter or section in a book
 */
class Chapter : BookData {
    string title;
    string content;
    size_t chapterNumber;
    size_t level;  // Nesting level (0 = main chapter, 1 = section, etc.)
    
    // Hierarchy
    Chapter parent;
    Chapter[] children;
    
    // Content metadata
    size_t wordCount;
    size_t characterCount;
    size_t startPage;
    size_t endPage;
    
    // Formatting
    string[] cssClasses;
    string id;
    
    this(string title = "", string content = "") @safe {
        this.title = title;
        this.content = content;
        this.children = [];
        this.cssClasses = [];
        updateCounts();
    }
    
    /**
     * Update word and character counts
     */
    void updateCounts() @safe {
        characterCount = content.length;
        wordCount = BookUtils.countWords(content);
    }
    
    /**
     * Add a sub-chapter/section
     */
    void addChild(Chapter child) @safe {
        child.parent = this;
        child.level = this.level + 1;
        children ~= child;
    }
    
    /**
     * Remove a sub-chapter
     */
    void removeChild(Chapter child) @trusted {
        children = children.filter!(c => c !is child).array;
        if (child.parent is this) {
            child.parent = null;
        }
    }
    
    /**
     * Get all descendants (children, grandchildren, etc.)
     */
    Chapter[] getAllDescendants() @trusted {
        Chapter[] result = children.dup;
        foreach (child; children) {
            result ~= child.getAllDescendants();
        }
        return result;
    }
    
    /**
     * Get total word count including all children
     */
    size_t getTotalWordCount() @safe {
        size_t total = wordCount;
        foreach (child; children) {
            total += child.getTotalWordCount();
        }
        return total;
    }
    
    /**
     * Get chapter path (e.g., "1.2.3")
     */
    string getChapterPath() @safe {
        if (parent is null) {
            return to!string(chapterNumber);
        }
        
        auto parentPath = parent.getChapterPath();
        if (parentPath.length > 0) {
            return parentPath ~ "." ~ to!string(chapterNumber);
        }
        return to!string(chapterNumber);
    }
    
    /**
     * Search for text within chapter
     */
    SearchResult[] search(string query) @trusted {
        SearchResult[] results;
        auto lowerContent = content.toLower;
        auto lowerQuery = query.toLower;
        
        size_t pos = 0;
        while (pos < lowerContent.length) {
            auto found = lowerContent[pos .. $].indexOf(lowerQuery);
            if (found < 0) break;
            
            pos += found;
            
            SearchResult result;
            result.chapterIndex = chapterNumber;
            result.position = pos;
            result.matchedText = content[pos .. pos + query.length];
            result.context = BookUtils.extractSnippet(content, pos, 50);
            
            results ~= result;
            pos += query.length;
        }
        
        // Search in children
        foreach (child; children) {
            results ~= child.search(query);
        }
        
        return results;
    }
    
    /**
     * Extract plain text (strip HTML if present)
     */
    string getPlainText() @trusted {
        import std.regex : regex, replaceAll;
        
        // Simple HTML tag removal
        auto noTags = content.replaceAll(regex("<[^>]*>"), "");
        
        // Remove multiple whitespace
        auto cleaned = noTags.replaceAll(regex(r"\s+"), " ");
        
        return cleaned.strip;
    }
    
    /**
     * Get reading time estimate
     */
    uint getReadingTime(uint wordsPerMinute = 250) @safe {
        return BookUtils.estimateReadingTime(getTotalWordCount(), wordsPerMinute);
    }
    
    override bool validate() @safe {
        if (title.length == 0 && content.length == 0) {
            return false;
        }
        
        // Validate children
        foreach (child; children) {
            if (!child.validate()) {
                return false;
            }
        }
        
        return true;
    }
    
    override size_t getSize() const @safe {
        size_t total = title.length + content.length;
        foreach (child; children) {
            total += child.getSize();
        }
        return total;
    }
    
    /**
     * Convert to string representation
     */
    override string toString() const @safe {
        string indent = "";
        for (size_t i = 0; i < level; i++) {
            indent ~= "  ";
        }
        
        string result = indent ~ "Chapter: " ~ title ~ "\n";
        result ~= indent ~ "  Words: " ~ to!string(wordCount) ~ "\n";
        
        if (children.length > 0) {
            result ~= indent ~ "  Sub-chapters: " ~ to!string(children.length) ~ "\n";
        }
        
        return result;
    }
}

/**
 * Bookmark within a book
 */
struct Bookmark {
    string title;
    size_t chapterIndex;
    size_t position;
    string note;
    DateTime created;
    
    /// Create a new bookmark
    static Bookmark create(string title, size_t chapterIndex, size_t position) @safe {
        Bookmark bm;
        bm.title = title;
        bm.chapterIndex = chapterIndex;
        bm.position = position;
        bm.created = DateTime.init; // Would use Clock.currTime in real implementation
        return bm;
    }
}

/**
 * Annotation/highlight in a book
 */
struct Annotation {
    string text;           // The highlighted text
    string note;           // User's note
    string color;          // Highlight color
    size_t chapterIndex;
    size_t startPosition;
    size_t endPosition;
    DateTime created;
    
    /// Create a new annotation
    static Annotation create(string text, size_t chapterIndex, 
                            size_t start, size_t end, string note = "") @safe {
        Annotation ann;
        ann.text = text;
        ann.note = note;
        ann.chapterIndex = chapterIndex;
        ann.startPosition = start;
        ann.endPosition = end;
        ann.color = "yellow";
        ann.created = DateTime.init;
        return ann;
    }
}
