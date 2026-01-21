/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.comic.io;

import uim.media.comic.base;
import uim.media.comic.metadata;
import uim.media.comic.page;
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
 * Main comic book class
 */
class ComicBook : ComicData {
    ComicMetadata metadata;
    ComicPage[] pages;
    ComicFormat format;
    string sourceFile;
    
    this() @safe {
        metadata = new ComicMetadata();
        pages = [];
        format = ComicFormat.unknown;
    }
    
    /**
     * Load comic from file
     */
    static ComicBook fromFile(string filename) @trusted {
        auto comicFormat = ComicUtils.detectFormat(filename);
        
        final switch (comicFormat) with (ComicFormat) {
            case cbz:
                return CBZReader.read(filename);
            case cbt:
                return CBTReader.read(filename);
            case cbr:
            case cb7:
            case cba:
                throw new ComicException("Format not yet supported: " ~ comicFormat.to!string);
            case pdf:
            case epub:
            case unknown:
                throw new ComicException("Unsupported format: " ~ comicFormat.to!string);
        }
    }
    
    /**
     * Save comic to file
     */
    void saveToFile(string filename) @trusted {
        auto saveFormat = ComicUtils.detectFormat(filename);
        
        final switch (saveFormat) with (ComicFormat) {
            case cbz:
                CBZWriter.write(this, filename);
                break;
            case cbt:
                CBTWriter.write(this, filename);
                break;
            case cbr:
            case cb7:
            case cba:
            case pdf:
            case epub:
            case unknown:
                throw new ComicException("Format not supported for writing: " ~ saveFormat.to!string);
        }
    }
    
    /**
     * Add page from image file
     */
    void addPageFromFile(string filename, PageType type = PageType.story) @trusted {
        auto data = cast(ubyte[])read(filename);
        addPage(data, baseName(filename), type);
    }
    
    /**
     * Add page from image data
     */
    void addPage(ubyte[] imageData, string filename, PageType type = PageType.story) @safe {
        auto page = new ComicPage(filename);
        page.pageNumber = pages.length;
        page.type = type;
        page.loadImageData(imageData);
        pages ~= page;
        
        // Update metadata page count
        metadata.pageCount = cast(uint)pages.length;
    }
    
    /**
     * Get page by index
     */
    ComicPage getPage(size_t index) @safe {
        enforce(index < pages.length, "Page index out of range");
        return pages[index];
    }
    
    /**
     * Get page image data
     */
    const(ubyte)[] getPageImage(size_t index) @safe {
        return getPage(index).getImageData();
    }
    
    /**
     * Get page count
     */
    @property size_t pageCount() const @safe {
        return pages.length;
    }
    
    /**
     * Remove page
     */
    void removePage(size_t index) @trusted {
        enforce(index < pages.length, "Page index out of range");
        pages = pages[0..index] ~ pages[index+1..$];
        
        // Renumber pages
        foreach (i, page; pages) {
            page.pageNumber = i;
        }
        
        metadata.pageCount = cast(uint)pages.length;
    }
    
    /**
     * Sort pages by filename
     */
    void sortPages() @trusted {
        auto filenames = pages.map!(p => p.filename).array;
        filenames = ComicUtils.sortNaturally(filenames);
        
        ComicPage[] sortedPages;
        foreach (filename; filenames) {
            foreach (page; pages) {
                if (page.filename == filename) {
                    sortedPages ~= page;
                    break;
                }
            }
        }
        
        pages = sortedPages;
        
        // Renumber pages
        foreach (i, page; pages) {
            page.pageNumber = i;
        }
    }
    
    /**
     * Save as CBZ
     */
    void saveToCBZ(string filename) @trusted {
        format = ComicFormat.cbz;
        CBZWriter.write(this, filename);
    }
    
    /**
     * Extract all pages to directory
     */
    void extractToDirectory(string directory) @trusted {
        if (!exists(directory)) {
            mkdirRecurse(directory);
        }
        
        foreach (page; pages) {
            auto outputFile = buildPath(directory, page.filename);
            write(outputFile, page.getImageData());
        }
        
        // Save metadata
        auto metadataFile = buildPath(directory, "ComicInfo.xml");
        write(metadataFile, metadata.toXML());
    }
    
    override bool validate() @safe {
        if (!metadata.validate()) return false;
        if (pages.length == 0) return false;
        
        foreach (page; pages) {
            if (!page.validate()) return false;
        }
        
        return true;
    }
    
    override size_t getSize() const @safe {
        size_t total = metadata.getSize();
        foreach (page; pages) {
            total += page.getSize();
        }
        return total;
    }
}

/**
 * CBZ (ZIP) format reader
 */
private struct CBZReader {
    static ComicBook read(string filename) @trusted {
        auto comic = new ComicBook();
        comic.format = ComicFormat.cbz;
        comic.sourceFile = filename;
        
        // Read ZIP archive
        auto zipData = cast(ubyte[])std.file.read(filename);
        auto archive = new ZipArchive(zipData);
        
        // Extract files
        string[] imageFiles;
        
        foreach (name, member; archive.directory) {
            if (name == "ComicInfo.xml") {
                // Parse metadata
                archive.expand(member);
                auto xmlContent = cast(string)member.expandedData;
                comic.metadata = ComicMetadata.fromXML(xmlContent);
            } else if (ComicUtils.isImageFile(name)) {
                imageFiles ~= name;
            }
        }
        
        // Sort image files naturally
        imageFiles = ComicUtils.sortNaturally(imageFiles);
        
        // Load pages
        foreach (i, filename; imageFiles) {
            auto member = archive.directory[filename];
            archive.expand(member);
            
            auto page = new ComicPage(filename);
            page.pageNumber = i;
            page.loadImageData(member.expandedData);
            comic.pages ~= page;
        }
        
        // Update metadata page count
        comic.metadata.pageCount = cast(uint)comic.pages.length;
        
        return comic;
    }
}

/**
 * CBZ (ZIP) format writer
 */
private struct CBZWriter {
    static void write(ComicBook comic, string filename) @trusted {
        auto archive = new ZipArchive();
        
        // Add metadata
        auto metadataXML = comic.metadata.toXML();
        auto metadataMember = new ArchiveMember();
        metadataMember.name = "ComicInfo.xml";
        metadataMember.expandedData = cast(ubyte[])metadataXML;
        metadataMember.compressionMethod = CompressionMethod.deflate;
        archive.addMember(metadataMember);
        
        // Add pages
        foreach (page; comic.pages) {
            auto member = new ArchiveMember();
            member.name = page.filename;
            member.expandedData = cast(ubyte[])page.getImageData();
            member.compressionMethod = CompressionMethod.deflate;
            archive.addMember(member);
        }
        
        // Build and save archive
        auto zipData = archive.build();
        write(filename, zipData);
    }
}

/**
 * CBT (TAR) format reader
 */
private struct CBTReader {
    static ComicBook read(string filename) @trusted {
        auto comic = new ComicBook();
        comic.format = ComicFormat.cbt;
        comic.sourceFile = filename;
        
        // Basic TAR reading would be implemented here
        // For now, throw an exception
        throw new ComicException("CBT format reading not yet fully implemented");
    }
}

/**
 * CBT (TAR) format writer
 */
private struct CBTWriter {
    static void write(ComicBook comic, string filename) @trusted {
        // Basic TAR writing would be implemented here
        throw new ComicException("CBT format writing not yet fully implemented");
    }
}
