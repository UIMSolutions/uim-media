/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.book.formats.epub;

import uim.media.book.base;
import uim.media.book.metadata;

@safe:

/**
 * EPUB version enumeration
 */
enum EPUBVersion {
    epub20,
    epub30,
    epub31
}

/**
 * EPUB-specific metadata
 */
class EPUBMetadata {
    EPUBVersion version_;
    string uniqueIdentifier;
    string[] manifestItems;
    string[] spineItems;
    string ncxId;
    
    this() @safe {
        version_ = EPUBVersion.epub30;
        manifestItems = [];
        spineItems = [];
    }
}

/**
 * EPUB container structure
 */
struct EPUBContainer {
    string mimetype = "application/epub+zip";
    string containerXML;
    string contentOPF;
    string tocNCX;
}
