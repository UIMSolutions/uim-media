/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.comic.page;

import uim.media.comic.base;
import std.algorithm;
import std.conv;
import std.exception;

@safe:

/**
 * Represents a single page in a comic book
 */
class ComicPage : ComicData {
    string filename;            /// Original filename in archive
    size_t pageNumber;          /// Page number (0-indexed)
    PageType type;              /// Page type (cover, story, etc.)
    ubyte[] imageData;          /// Image data
    ImageFormat imageFormat;    /// Image format
    
    // Image properties
    uint width;
    uint height;
    uint fileSize;
    
    // Page properties
    bool isDoublePage;          /// Double-page spread
    bool isDeleted;             /// Marked for deletion
    string key;                 /// Unique identifier
    
    // Reading info
    uint bookmarkCount;
    string notes;
    
    this(string filename = "") @safe {
        this.filename = filename;
        this.type = PageType.story;
        this.imageFormat = ComicUtils.detectImageFormat(filename);
    }
    
    /**
     * Load image data
     */
    void loadImageData(ubyte[] data) @safe {
        this.imageData = data.dup;
        this.fileSize = cast(uint)data.length;
        
        // Try to detect image dimensions
        detectImageDimensions();
    }
    
    /**
     * Get image data
     */
    const(ubyte)[] getImageData() const @safe {
        return imageData;
    }
    
    /**
     * Detect if this is a double-page spread based on dimensions
     */
    void detectImageDimensions() @trusted {
        if (imageData.length < 24) return;
        
        // Simple dimension detection for common formats
        if (imageFormat == ImageFormat.png) {
            // PNG: dimensions at bytes 16-23
            if (imageData.length >= 24) {
                width = (imageData[16] << 24) | (imageData[17] << 16) | 
                        (imageData[18] << 8) | imageData[19];
                height = (imageData[20] << 24) | (imageData[21] << 16) | 
                         (imageData[22] << 8) | imageData[23];
                
                // Likely a double-page if width is more than 1.5x height
                isDoublePage = (width > height * 1.5);
            }
        } else if (imageFormat == ImageFormat.jpeg) {
            // JPEG: would need more complex parsing
            // Placeholder for now
        }
    }
    
    /**
     * Get aspect ratio
     */
    double getAspectRatio() const @safe {
        if (height == 0) return 0.0;
        return cast(double)width / height;
    }
    
    /**
     * Check if this is a cover page
     */
    bool isCover() const @safe {
        return type == PageType.frontCover || type == PageType.backCover;
    }
    
    /**
     * Get page type as string
     */
    string getTypeString() const @safe {
        final switch (type) with (PageType) {
            case frontCover: return "Front Cover";
            case innerCover: return "Inner Cover";
            case roundup: return "Roundup";
            case story: return "Story";
            case advertisement: return "Advertisement";
            case editorial: return "Editorial";
            case letters: return "Letters";
            case preview: return "Preview";
            case backCover: return "Back Cover";
            case other: return "Other";
            case deleted: return "Deleted";
        }
    }
    
    override bool validate() @safe {
        if (filename.length == 0) return false;
        if (imageFormat == ImageFormat.unknown) return false;
        return true;
    }
    
    override size_t getSize() const @safe {
        return imageData.length;
    }
    
    /**
     * Convert to string representation
     */
    override string toString() const @safe {
        string result = format("Page %d: %s\n", pageNumber, filename);
        result ~= "  Type: %s\n".format(getTypeString());
        result ~= "  Format: %s\n".format( imageFormat);
        
        if (width > 0 && height > 0) {
            result ~= format("  Dimensions: %dx%d\n", width, height);
        }
        
        if (fileSize > 0) {
            result ~= format("  Size: %s\n", ComicUtils.formatFileSize(fileSize));
        }
        
        if (isDoublePage) {
            result ~= "  Double-page spread\n";
        }
        
        return result;
    }
}

/**
 * Page information for ComicInfo.xml
 */
struct PageInfo {
    size_t image;       /// Index in archive
    PageType type;
    bool doublePage;
    string imageSize;
    string key;
    string bookmark;
    
    /// Convert to XML element
    string toXML() const @trusted {
        string xml = "  <Page";
        xml ~= format(" Image=\"%d\"", image);
        xml ~= format(" Type=\"%s\"", pageTypeToString(type));
        
        if (doublePage) {
            xml ~= " DoublePage=\"true\"";
        }
        
        if (imageSize.length > 0) {
            xml ~= format(" ImageSize=\"%s\"", imageSize);
        }
        
        if (key.length > 0) {
            xml ~= format(" Key=\"%s\"", key);
        }
        
        if (bookmark.length > 0) {
            xml ~= format(" Bookmark=\"%s\"", bookmark);
        }
        
        xml ~= " />\n";
        return xml;
    }
    
    private static string pageTypeToString(PageType type) @safe {
        final switch (type) with (PageType) {
            case frontCover: return "FrontCover";
            case innerCover: return "InnerCover";
            case roundup: return "Roundup";
            case story: return "Story";
            case advertisement: return "Advertisement";
            case editorial: return "Editorial";
            case letters: return "Letters";
            case preview: return "Preview";
            case backCover: return "BackCover";
            case other: return "Other";
            case deleted: return "Deleted";
        }
    }
}
