/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.video.formats.mkv;

import uim.media.video.base;
import std.exception;
import std.file;
import vibe.core.log;

@safe:

/**
 * MKV (Matroska) video format handler
 */
class MkvVideo : Video {
    private {
        string _docType;
        uint _docTypeVersion;
    }

    this() {
        super();
        this.format = VideoFormat.mkv;
    }

    this(string path) {
        super(path);
        this.format = VideoFormat.mkv;
    }

    /**
     * Read MKV header (EBML format)
     */
    bool readHeader(ubyte[] data) @trusted {
        if (data.length < 4) return false;

        // MKV files start with EBML header
        // EBML uses variable-length encoding, complex to parse fully
        
        // Check for EBML magic bytes: 0x1A 0x45 0xDF 0xA3
        if (data[0] == 0x1A && data[1] == 0x45 && data[2] == 0xDF && data[3] == 0xA3) {
            _hasVideo = true;
            
            // Basic validation - full parsing would require EBML parser
            // MKV typically contains "matroska" or "webm" doctype
            foreach (i; 0 .. data.length - 8) {
                if (data[i .. i + 8] == cast(ubyte[])"matroska") {
                    _docType = "matroska";
                    return true;
                }
            }
            
            return true;
        }

        return false;
    }

    @property string docType() const { return _docType; }
    @property uint docTypeVersion() const { return _docTypeVersion; }
}
