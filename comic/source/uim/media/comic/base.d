/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.comic.base;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.string;
import std.path;
import std.format : fmt = format;

@safe:

/**
 * Comic book format enumeration
 */
enum ComicFormat {
    unknown,
    cbz,        /// Comic Book ZIP
    cbr,        /// Comic Book RAR
    cb7,        /// Comic Book 7z
    cbt,        /// Comic Book TAR
    cba,        /// Comic Book ACE
    pdf,        /// PDF (sometimes used for comics)
    epub        /// EPUB (for digital manga/comics)
}

/**
 * Page type enumeration (ComicInfo.xml standard)
 */
enum PageType {
    frontCover,
    innerCover,
    roundup,
    story,
    advertisement,
    editorial,
    letters,
    preview,
    backCover,
    other,
    deleted
}

/**
 * Reading direction
 */
enum ReadingDirection {
    leftToRight,    /// Western style
    rightToLeft     /// Manga style
}

/**
 * Age rating enumeration
 */
enum AgeRating {
    unknown,
    everyone,
    everyonePlus10,
    teen,
    teenPlus,
    mature,
    mature17Plus,
    adults18Plus,
    ratingPending
}

/**
 * Manga classification
 */
enum Manga {
    unknown,
    no,         /// Not manga
    yes,        /// Manga
    yesCJK      /// Manga with CJK (Chinese/Japanese/Korean) text
}

/**
 * Comic format type (single issue, TPB, etc.)
 */
enum ComicFormatType {
    unknown,
    issue,              /// Single issue
    tpb,                /// Trade Paperback
    hardcover,
    graphicNovel,
    digitalChapter,
    annuals,
    anthology,
    omnibus,
    limitedSeries,
    oneShot
}

/**
 * Image format within comic
 */
enum ImageFormat {
    unknown,
    jpeg,
    png,
    gif,
    bmp,
    webp,
    tiff
}

/**
 * Comic series information
 */
struct SeriesInfo {
    string title;
    uint number;            /// Issue number
    uint count;             /// Total issues in series
    uint volume;            /// Volume number
    string alternateNumber; /// Alternate numbering (e.g., "1A")
}

/**
 * Comic creator/contributor
 */
struct Creator {
    string name;
    string role;  /// Writer, Penciller, Inker, Colorist, Letterer, CoverArtist, Editor
    
    /// Create writer
    static Creator writer(string name) @safe {
        return Creator(name, "Writer");
    }
    
    /// Create penciller
    static Creator penciller(string name) @safe {
        return Creator(name, "Penciller");
    }
    
    /// Create inker
    static Creator inker(string name) @safe {
        return Creator(name, "Inker");
    }
    
    /// Create colorist
    static Creator colorist(string name) @safe {
        return Creator(name, "Colorist");
    }
    
    /// Create letterer
    static Creator letterer(string name) @safe {
        return Creator(name, "Letterer");
    }
    
    /// Create cover artist
    static Creator coverArtist(string name) @safe {
        return Creator(name, "CoverArtist");
    }
    
    /// Create editor
    static Creator editor(string name) @safe {
        return Creator(name, "Editor");
    }
}

/**
 * Reading progress tracking
 */
struct ReadingProgress {
    size_t currentPage;
    size_t totalPages;
    double percentage;
    bool isFinished;
    
    /// Update percentage based on current page
    void updatePercentage() @safe {
        if (totalPages > 0) {
            percentage = (cast(double)currentPage / totalPages) * 100.0;
            isFinished = currentPage >= totalPages - 1;
        }
    }
}

/**
 * Base class for comic data structures
 */
abstract class ComicData {
    /// Validate data structure
    abstract bool validate() @safe;
    
    /// Get data size estimate
    abstract size_t getSize() const @safe;
}

/**
 * Exception thrown for comic-related errors
 */
class ComicException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__) @safe {
        super(msg, file, line);
    }
}

/**
 * Utility functions for comic operations
 */
struct ComicUtils {
    /**
     * Detect comic format from file extension
     */
    static ComicFormat detectFormat(string filename) @safe {
        auto ext = filename.toLower;
        
        if (ext.endsWith(".cbz")) return ComicFormat.cbz;
        if (ext.endsWith(".cbr")) return ComicFormat.cbr;
        if (ext.endsWith(".cb7")) return ComicFormat.cb7;
        if (ext.endsWith(".cbt")) return ComicFormat.cbt;
        if (ext.endsWith(".cba")) return ComicFormat.cba;
        if (ext.endsWith(".pdf")) return ComicFormat.pdf;
        if (ext.endsWith(".epub")) return ComicFormat.epub;
        
        return ComicFormat.unknown;
    }
    
    /**
     * Get format description
     */
    static string formatDescription(ComicFormat format) @safe {
        final switch (format) with (ComicFormat) {
            case unknown: return "Unknown Format";
            case cbz: return "Comic Book Archive (ZIP)";
            case cbr: return "Comic Book Archive (RAR)";
            case cb7: return "Comic Book Archive (7-Zip)";
            case cbt: return "Comic Book Archive (TAR)";
            case cba: return "Comic Book Archive (ACE)";
            case pdf: return "PDF Comic";
            case epub: return "EPUB Comic/Manga";
        }
    }
    
    /**
     * Detect image format from filename
     */
    static ImageFormat detectImageFormat(string filename) @safe {
        auto ext = filename.toLower;
        
        if (ext.endsWith(".jpg") || ext.endsWith(".jpeg")) return ImageFormat.jpeg;
        if (ext.endsWith(".png")) return ImageFormat.png;
        if (ext.endsWith(".gif")) return ImageFormat.gif;
        if (ext.endsWith(".bmp")) return ImageFormat.bmp;
        if (ext.endsWith(".webp")) return ImageFormat.webp;
        if (ext.endsWith(".tif") || ext.endsWith(".tiff")) return ImageFormat.tiff;
        
        return ImageFormat.unknown;
    }
    
    /**
     * Check if filename is an image
     */
    static bool isImageFile(string filename) @safe {
        return detectImageFormat(filename) != ImageFormat.unknown;
    }
    
    /**
     * Natural sort comparison for filenames (handles numbers correctly)
     */
    static int naturalCompare(string a, string b) @trusted {
        import std.uni : isNumber;
        import std.algorithm : min;
        
        size_t i = 0, j = 0;
        
        while (i < a.length && j < b.length) {
            // Check if both are numbers
            if (isNumber(a[i]) && isNumber(b[j])) {
                // Extract numbers
                size_t numStartA = i;
                size_t numStartB = j;
                
                while (i < a.length && isNumber(a[i])) i++;
                while (j < b.length && isNumber(b[j])) j++;
                
                auto numA = to!long(a[numStartA .. i]);
                auto numB = to!long(b[numStartB .. j]);
                
                if (numA != numB) {
                    return numA < numB ? -1 : 1;
                }
            } else {
                // Regular character comparison
                if (a[i] != b[j]) {
                    return a[i] < b[j] ? -1 : 1;
                }
                i++;
                j++;
            }
        }
        
        // Handle different lengths
        if (a.length != b.length) {
            return a.length < b.length ? -1 : 1;
        }
        
        return 0;
    }
    
    /**
     * Sort filenames naturally (page01.jpg, page02.jpg, page10.jpg)
     */
    static string[] sortNaturally(string[] files) @trusted {
        import std.algorithm : sort;
        files.sort!((a, b) => naturalCompare(a, b) < 0);
        return files;
    }
    
    /**
     * Format file size to human-readable string
     */
    static string formatFileSize(size_t bytes) @trusted {
        if (bytes < 1024) {
            return format("%d B", bytes);
        } else if (bytes < 1024 * 1024) {
            return format("%.2f KB", bytes / 1024.0);
        } else if (bytes < 1024 * 1024 * 1024) {
            return format("%.2f MB", bytes / (1024.0 * 1024));
        } else {
            return format("%.2f GB", bytes / (1024.0 * 1024 * 1024));
        }
    }
    
    /**
     * Sanitize filename for archive
     */
    static string sanitizeFilename(string filename) @trusted {
        import std.regex : regex, replaceAll;
        auto invalidChars = regex(r"[<>:\"/\\|?*]");
        return filename.replaceAll(invalidChars, "_");
    }
    
    /**
     * Get page number from filename (e.g., "page001.jpg" -> 1)
     */
    static int extractPageNumber(string filename) @trusted {
        import std.regex : regex, matchFirst;
        
        auto numPattern = regex(r"(\d+)");
        auto match = filename.matchFirst(numPattern);
        
        if (!match.empty) {
            try {
                return to!int(match[1]);
            } catch (Exception e) {
                return -1;
            }
        }
        
        return -1;
    }
}
