/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.video.formats.mp4;

import uim.media.video.base;
import std.bitmanip;
import std.exception;
import std.file;
import core.time;
import vibe.core.log;

@safe:

/**
 * MP4/M4V video format handler (MPEG-4 Part 14)
 */
class Mp4Video : Video {
    private {
        string _brand;
        uint _timescale;
        bool _fragmented;
    }

    this() {
        super();
        this.format = VideoFormat.mp4;
    }

    this(string path) {
        super(path);
        this.format = VideoFormat.mp4;
    }

    /**
     * Read MP4 header and extract basic information
     * MP4 uses atoms/boxes structure
     */
    bool readHeader(ubyte[] data) @trusted {
        if (data.length < 8) return false;

        try {
            size_t pos = 0;
            
            // MP4 files start with 'ftyp' box
            while (pos + 8 <= data.length) {
                // Read box size (4 bytes, big-endian)
                uint boxSize = (data[pos] << 24) | (data[pos + 1] << 16) | 
                               (data[pos + 2] << 8) | data[pos + 3];
                pos += 4;

                // Read box type (4 bytes)
                string boxType = cast(string)data[pos .. pos + 4].dup;
                pos += 4;

                if (boxType == "ftyp") {
                    // File type box - read brand
                    if (pos + 4 <= data.length) {
                        _brand = cast(string)data[pos .. pos + 4].dup;
                        
                        // Common MP4 brands
                        if (_brand == "isom" || _brand == "mp41" || _brand == "mp42" || 
                            _brand == "M4V " || _brand == "M4A ") {
                            _hasVideo = true;
                        }
                    }
                    
                    // Skip rest of ftyp box
                    if (boxSize > 8 && pos + boxSize - 8 <= data.length) {
                        pos += boxSize - 8;
                    }
                    return true;
                }
                else if (boxType == "moov") {
                    // Movie box - contains metadata
                    // This would require deeper parsing
                    return true;
                }
                else {
                    // Skip unknown box
                    if (boxSize > 8 && pos + boxSize - 8 <= data.length) {
                        pos += boxSize - 8;
                    } else {
                        break;
                    }
                }

                // Prevent infinite loop
                if (boxSize == 0 || pos >= data.length) break;
            }
        } catch (Exception e) {
            logError("Failed to parse MP4 header: %s", e.msg);
            return false;
        }

        return false;
    }

    @property string brand() const { return _brand; }
    @property bool fragmented() const { return _fragmented; }
}
