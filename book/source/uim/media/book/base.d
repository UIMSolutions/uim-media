/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.book.base;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.string;
import std.datetime;
import std.format : fmt = format;

@safe:

/**
 * Book format enumeration
 */
enum BookFormat {
    unknown,
    epub,       /// Electronic Publication (EPUB 2.0, 3.0)
    pdf,        /// Portable Document Format
    mobi,       /// Mobipocket (Amazon Kindle)
    azw,        /// Amazon Kindle format
    azw3,       /// Amazon Kindle Format 8
    txt,        /// Plain text
    html,       /// HTML document
    markdown,   /// Markdown document
    rtf,        /// Rich Text Format
    docx,       /// Microsoft Word document
    odt,        /// OpenDocument Text
    fb2,        /// FictionBook 2.0
    djvu,       /// DjVu document
    cbz,        /// Comic Book Archive (ZIP)
    cbr         /// Comic Book Archive (RAR)
}

/**
 * Book category enumeration
 */
enum BookCategory {
    unknown,
    fiction,
    nonFiction,
    biography,
    history,
    science,
    technology,
    mathematics,
    philosophy,
    religion,
    poetry,
    drama,
    children,
    youngAdult,
    reference,
    textbook,
    manual,
    cookbook,
    travel,
    selfHelp,
    business,
    romance,
    mystery,
    thriller,
    fantasy,
    scienceFiction,
    horror,
    comic,
    manga,
    graphicNovel
}

/**
 * Book language codes (ISO 639-1)
 */
struct LanguageCode {
    string code;
    string name;
    
    static immutable LanguageCode en = LanguageCode("en", "English");
    static immutable LanguageCode de = LanguageCode("de", "German");
    static immutable LanguageCode fr = LanguageCode("fr", "French");
    static immutable LanguageCode es = LanguageCode("es", "Spanish");
    static immutable LanguageCode it = LanguageCode("it", "Italian");
    static immutable LanguageCode pt = LanguageCode("pt", "Portuguese");
    static immutable LanguageCode ru = LanguageCode("ru", "Russian");
    static immutable LanguageCode zh = LanguageCode("zh", "Chinese");
    static immutable LanguageCode ja = LanguageCode("ja", "Japanese");
    static immutable LanguageCode ko = LanguageCode("ko", "Korean");
    static immutable LanguageCode ar = LanguageCode("ar", "Arabic");
    static immutable LanguageCode hi = LanguageCode("hi", "Hindi");
    static immutable LanguageCode tr = LanguageCode("tr", "Turkish");
}

/**
 * ISBN (International Standard Book Number) structure
 */
struct ISBN {
    string value;
    
    /// Check if ISBN is valid
    bool isValid() const @safe {
        auto digits = value.filter!(c => c >= '0' && c <= '9').array;
        
        if (digits.length == 10) {
            return validateISBN10(digits);
        } else if (digits.length == 13) {
            return validateISBN13(digits);
        }
        
        return false;
    }
    
    /// Format ISBN with hyphens
    string formatted() const @safe {
        auto digits = value.filter!(c => c >= '0' && c <= '9').array;
        
        if (digits.length == 10) {
            return format("%s-%s-%s-%s", 
                digits[0..1], digits[1..6], digits[6..9], digits[9..10]);
        } else if (digits.length == 13) {
            return format("%s-%s-%s-%s-%s",
                digits[0..3], digits[3..4], digits[4..9], digits[9..12], digits[12..13]);
        }
        
        return value;
    }
    
    /// Convert ISBN-10 to ISBN-13
    string toISBN13() const @safe {
        auto digits = value.filter!(c => c >= '0' && c <= '9').array;
        
        if (digits.length == 10) {
            // Add 978 prefix and recalculate check digit
            auto isbn13 = "978" ~ cast(string)digits[0..9];
            auto checksum = calculateISBN13Checksum(isbn13);
            return isbn13 ~ to!string(checksum);
        } else if (digits.length == 13) {
            return cast(string)digits;
        }
        
        return value;
    }
    
    private static bool validateISBN10(const char[] digits) @trusted {
        int sum = 0;
        foreach (i, d; digits[0..9]) {
            sum += (d - '0') * (10 - i);
        }
        
        auto checkDigit = digits[9];
        int expectedCheck = (11 - (sum % 11)) % 11;
        
        if (checkDigit == 'X' || checkDigit == 'x') {
            return expectedCheck == 10;
        }
        
        return (checkDigit - '0') == expectedCheck;
    }
    
    private static bool validateISBN13(const char[] digits) @trusted {
        int sum = 0;
        foreach (i, d; digits[0..12]) {
            sum += (d - '0') * (i % 2 == 0 ? 1 : 3);
        }
        
        int checkDigit = digits[12] - '0';
        int expectedCheck = (10 - (sum % 10)) % 10;
        
        return checkDigit == expectedCheck;
    }
    
    private static int calculateISBN13Checksum(string isbn12) @trusted {
        int sum = 0;
        foreach (i, c; isbn12) {
            sum += (c - '0') * (i % 2 == 0 ? 1 : 3);
        }
        return (10 - (sum % 10)) % 10;
    }
}

/**
 * Book contributor (author, editor, translator, etc.)
 */
struct Contributor {
    string name;
    string role;  // "aut" (author), "edt" (editor), "trl" (translator), etc.
    string sortName; // Last, First format for sorting
    
    /// Create author contributor
    static Contributor author(string name) @safe {
        return Contributor(name, "aut", name);
    }
    
    /// Create editor contributor
    static Contributor editor(string name) @safe {
        return Contributor(name, "edt", name);
    }
    
    /// Create translator contributor
    static Contributor translator(string name) @safe {
        return Contributor(name, "trl", name);
    }
}

/**
 * Reading progress tracking
 */
struct ReadingProgress {
    size_t currentPage;
    size_t totalPages;
    double percentage;
    DateTime lastRead;
    size_t bookmarkCount;
    
    /// Calculate percentage based on current page
    void updatePercentage() @safe {
        if (totalPages > 0) {
            percentage = (cast(double)currentPage / totalPages) * 100.0;
        }
    }
    
    /// Check if book is finished
    bool isFinished() const @safe {
        return currentPage >= totalPages;
    }
}

/**
 * Search result within a book
 */
struct SearchResult {
    size_t chapterIndex;
    size_t page;
    size_t position;
    string context;  // Text snippet around the match
    string matchedText;
}

/**
 * Base class for book data structures
 */
abstract class BookData {
    /// Validate data structure
    abstract bool validate() @safe;
    
    /// Get data size estimate
    abstract size_t getSize() const @safe;
}

/**
 * Exception thrown for book-related errors
 */
class BookException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__) @safe {
        super(msg, file, line);
    }
}

/**
 * Utility functions for book operations
 */
struct BookUtils {
    /**
     * Detect book format from file extension
     */
    static BookFormat detectFormat(string filename) @safe {
        auto ext = filename.toLower;
        
        if (ext.endsWith(".epub")) return BookFormat.epub;
        if (ext.endsWith(".pdf")) return BookFormat.pdf;
        if (ext.endsWith(".mobi")) return BookFormat.mobi;
        if (ext.endsWith(".azw")) return BookFormat.azw;
        if (ext.endsWith(".azw3")) return BookFormat.azw3;
        if (ext.endsWith(".txt")) return BookFormat.txt;
        if (ext.endsWith(".html") || ext.endsWith(".htm")) return BookFormat.html;
        if (ext.endsWith(".md") || ext.endsWith(".markdown")) return BookFormat.markdown;
        if (ext.endsWith(".rtf")) return BookFormat.rtf;
        if (ext.endsWith(".docx")) return BookFormat.docx;
        if (ext.endsWith(".odt")) return BookFormat.odt;
        if (ext.endsWith(".fb2")) return BookFormat.fb2;
        if (ext.endsWith(".djvu")) return BookFormat.djvu;
        if (ext.endsWith(".cbz")) return BookFormat.cbz;
        if (ext.endsWith(".cbr")) return BookFormat.cbr;
        
        return BookFormat.unknown;
    }
    
    /**
     * Get format description
     */
    static string formatDescription(BookFormat format) @safe {
        final switch (format) with (BookFormat) {
            case unknown: return "Unknown Format";
            case epub: return "EPUB (Electronic Publication)";
            case pdf: return "PDF (Portable Document Format)";
            case mobi: return "MOBI (Mobipocket)";
            case azw: return "AZW (Amazon Kindle)";
            case azw3: return "AZW3 (Kindle Format 8)";
            case txt: return "Plain Text";
            case html: return "HTML Document";
            case markdown: return "Markdown Document";
            case rtf: return "Rich Text Format";
            case docx: return "Microsoft Word";
            case odt: return "OpenDocument Text";
            case fb2: return "FictionBook 2.0";
            case djvu: return "DjVu Document";
            case cbz: return "Comic Book Archive (ZIP)";
            case cbr: return "Comic Book Archive (RAR)";
        }
    }
    
    /**
     * Calculate reading time estimate (words per minute)
     */
    static uint estimateReadingTime(size_t wordCount, uint wordsPerMinute = 250) @safe {
        if (wordsPerMinute == 0) return 0;
        return cast(uint)(wordCount / wordsPerMinute);
    }
    
    /**
     * Format reading time as human-readable string
     */
    static string formatReadingTime(uint minutes) @safe {
        if (minutes < 60) {
            return format("%d minutes", minutes);
        } else if (minutes < 1440) {
            auto hours = minutes / 60;
            auto mins = minutes % 60;
            return format("%d hours %d minutes", hours, mins);
        } else {
            auto days = minutes / 1440;
            auto hours = (minutes % 1440) / 60;
            return format("%d days %d hours", days, hours);
        }
    }
    
    /**
     * Count words in text
     */
    static size_t countWords(string text) @trusted {
        return text.splitter.filter!(w => w.length > 0).walkLength;
    }
    
    /**
     * Extract snippet of text around a position
     */
    static string extractSnippet(string text, size_t position, size_t contextLength = 50) @safe {
        if (text.length == 0 || position >= text.length) return "";
        
        auto start = position > contextLength ? position - contextLength : 0;
        auto end = position + contextLength < text.length ? position + contextLength : text.length;
        
        return text[start .. end];
    }
    
    /**
     * Sanitize filename for saving
     */
    static string sanitizeFilename(string filename) @trusted {
        import std.regex : regex, replaceAll;
        auto invalidChars = regex(r"[<>:\"/\\|?*]");
        return filename.replaceAll(invalidChars, "_");
    }
}
