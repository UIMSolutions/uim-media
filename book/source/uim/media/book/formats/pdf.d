/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.book.formats.pdf;

import uim.media.book.base;

@safe:

/**
 * PDF version enumeration
 */
enum PDFVersion {
    pdf10,
    pdf11,
    pdf12,
    pdf13,
    pdf14,
    pdf15,
    pdf16,
    pdf17,
    pdf20
}

/**
 * PDF-specific metadata
 */
class PDFMetadata {
    PDFVersion version_;
    string producer;
    string creator;
    bool encrypted;
    string[] permissions;
    
    this() @safe {
        version_ = PDFVersion.pdf17;
        encrypted = false;
        permissions = [];
    }
}
