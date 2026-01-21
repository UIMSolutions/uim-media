/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.book.metadata;

import uim.media.book.base;
import std.datetime;
import std.conv;
import std.algorithm;
import std.array;
import std.string;

@safe:

/**
 * Book metadata container
 */
class BookMetadata : BookData {
    // Core metadata
    string title;
    string subtitle;
    Contributor[] contributors;
    string publisher;
    string language;
    Date publicationDate;
    
    // Identifiers
    ISBN isbn;
    string[] otherIdentifiers;
    
    // Categorization
    BookCategory category;
    string[] subjects;
    string[] keywords;
    
    // Description
    string description;
    string rights;
    
    // Series information
    string seriesTitle;
    uint seriesNumber;
    
    // Technical metadata
    BookFormat format;
    string version_;
    size_t fileSize;
    
    // Additional metadata
    string[string] customMetadata;
    
    this() @safe {
        contributors = [];
        subjects = [];
        keywords = [];
        otherIdentifiers = [];
        customMetadata = null;
    }
    
    /**
     * Get primary author
     */
    string getAuthor() const @safe {
        foreach (contrib; contributors) {
            if (contrib.role == "aut") {
                return contrib.name;
            }
        }
        return "";
    }
    
    /**
     * Get all authors
     */
    string[] getAuthors() const @safe {
        return contributors
            .filter!(c => c.role == "aut")
            .map!(c => c.name)
            .array;
    }
    
    /**
     * Add author
     */
    void addAuthor(string name) @safe {
        contributors ~= Contributor.author(name);
    }
    
    /**
     * Add contributor with specific role
     */
    void addContributor(string name, string role) @safe {
        contributors ~= Contributor(name, role, name);
    }
    
    /**
     * Get formatted publication year
     */
    string getPublicationYear() const @safe {
        if (publicationDate == Date.init) return "";
        return to!string(publicationDate.year);
    }
    
    /**
     * Set publication date from string
     */
    void setPublicationDate(string dateStr) @trusted {
        try {
            // Try parsing different date formats
            if (dateStr.length == 4) {
                // Year only
                publicationDate = Date(to!int(dateStr), 1, 1);
            } else if (dateStr.length >= 10) {
                // Full date YYYY-MM-DD
                auto parts = dateStr.split("-");
                if (parts.length >= 3) {
                    publicationDate = Date(
                        to!int(parts[0]),
                        to!int(parts[1]),
                        to!int(parts[2])
                    );
                }
            }
        } catch (Exception e) {
            // Keep default date if parsing fails
        }
    }
    
    /**
     * Get full title (including subtitle)
     */
    string getFullTitle() const @safe {
        if (subtitle.length > 0) {
            return title ~ ": " ~ subtitle;
        }
        return title;
    }
    
    /**
     * Check if metadata is complete
     */
    bool isComplete() const @safe {
        return title.length > 0 && 
               contributors.length > 0 &&
               language.length > 0;
    }
    
    override bool validate() @safe {
        // Basic validation
        if (title.length == 0) return false;
        
        // Validate ISBN if present
        if (isbn.value.length > 0 && !isbn.isValid()) {
            return false;
        }
        
        return true;
    }
    
    override size_t getSize() const @safe {
        size_t total = 0;
        total += title.length;
        total += subtitle.length;
        total += publisher.length;
        total += description.length;
        
        foreach (contrib; contributors) {
            total += contrib.name.length;
        }
        
        return total;
    }
    
    /**
     * Convert metadata to human-readable string
     */
    override string toString() const @safe {
        string result = "Book Metadata:\n";
        
        result ~= "  Title: " ~ getFullTitle() ~ "\n";
        
        auto authors = getAuthors();
        if (authors.length > 0) {
            result ~= "  Author(s): " ~ authors.join(", ") ~ "\n";
        }
        
        if (publisher.length > 0) {
            result ~= "  Publisher: " ~ publisher ~ "\n";
        }
        
        if (publicationDate != Date.init) {
            result ~= "  Publication Date: " ~ publicationDate.toISOExtString() ~ "\n";
        }
        
        if (isbn.value.length > 0) {
            result ~= "  ISBN: " ~ isbn.formatted() ~ "\n";
        }
        
        if (language.length > 0) {
            result ~= "  Language: " ~ language ~ "\n";
        }
        
        if (seriesTitle.length > 0) {
            result ~= "  Series: " ~ seriesTitle;
            if (seriesNumber > 0) {
                result ~= " #" ~ to!string(seriesNumber);
            }
            result ~= "\n";
        }
        
        if (subjects.length > 0) {
            result ~= "  Subjects: " ~ subjects.join(", ") ~ "\n";
        }
        
        if (description.length > 0) {
            result ~= "  Description: " ~ (description.length > 100 ? 
                description[0..100] ~ "..." : description) ~ "\n";
        }
        
        return result;
    }
    
    /**
     * Export metadata to Dublin Core format
     */
    string[string] toDublinCore() const @safe {
        string[string] dc;
        
        if (title.length > 0) dc["dc:title"] = title;
        
        foreach (author; getAuthors()) {
            if ("dc:creator" in dc) {
                dc["dc:creator"] ~= "; " ~ author;
            } else {
                dc["dc:creator"] = author;
            }
        }
        
        if (publisher.length > 0) dc["dc:publisher"] = publisher;
        if (publicationDate != Date.init) dc["dc:date"] = publicationDate.toISOExtString();
        if (language.length > 0) dc["dc:language"] = language;
        if (description.length > 0) dc["dc:description"] = description;
        if (rights.length > 0) dc["dc:rights"] = rights;
        if (isbn.value.length > 0) dc["dc:identifier"] = "ISBN:" ~ isbn.value;
        
        if (subjects.length > 0) {
            dc["dc:subject"] = subjects.join("; ");
        }
        
        return dc;
    }
}

/**
 * Collection of book metadata for libraries
 */
class BookCollection {
    BookMetadata[] books;
    string collectionName;
    string description;
    
    this(string name = "") @safe {
        this.collectionName = name;
        this.books = [];
    }
    
    /// Add book to collection
    void addBook(BookMetadata book) @safe {
        books ~= book;
    }
    
    /// Remove book from collection
    void removeBook(BookMetadata book) @trusted {
        books = books.filter!(b => b !is book).array;
    }
    
    /// Get total number of books
    @property size_t count() const @safe {
        return books.length;
    }
    
    /// Find books by author
    BookMetadata[] findByAuthor(string author) @trusted {
        return books.filter!(b => 
            b.getAuthors().any!(a => a.toLower.canFind(author.toLower))
        ).array;
    }
    
    /// Find books by title
    BookMetadata[] findByTitle(string title) @trusted {
        return books.filter!(b => 
            b.title.toLower.canFind(title.toLower)
        ).array;
    }
    
    /// Find books by ISBN
    BookMetadata findByISBN(string isbn) @trusted {
        auto found = books.filter!(b => b.isbn.value == isbn).array;
        return found.length > 0 ? found[0] : null;
    }
    
    /// Get books by category
    BookMetadata[] getByCategory(BookCategory category) @trusted {
        return books.filter!(b => b.category == category).array;
    }
    
    /// Sort books by title
    void sortByTitle() @trusted {
        books.sort!((a, b) => a.title < b.title);
    }
    
    /// Sort books by author
    void sortByAuthor() @trusted {
        books.sort!((a, b) => a.getAuthor() < b.getAuthor());
    }
    
    /// Sort books by publication date
    void sortByDate() @trusted {
        books.sort!((a, b) => a.publicationDate < b.publicationDate);
    }
}
