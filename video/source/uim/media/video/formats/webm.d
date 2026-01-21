/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.video.formats.webm;

import uim.media.video.base;
import std.exception;
import std.file;
import vibe.core.log;

@safe:

/**
 * WebM video format handler (subset of Matroska)
 */
class WebmVideo : Video {
    this() {
        super();
        this.format = VideoFormat.webm;
        // WebM typically uses VP8/VP9 video codec
        this.videoCodec = VideoCodec.vp8;
        // WebM typically uses Vorbis/Opus audio codec
        this.audioCodec = AudioCodec.vorbis;
    }

    this(string path) {
        super(path);
        this.format = VideoFormat.webm;
        this.videoCodec = VideoCodec.vp8;
        this.audioCodec = AudioCodec.vorbis;
    }

    /**
     * Read WebM header (EBML format, same as MKV)
     */
    bool readHeader(ubyte[] data) @trusted {
        if (data.length < 4) return false;

        // WebM files also start with EBML header (same as MKV)
        if (data[0] == 0x1A && data[1] == 0x45 && data[2] == 0xDF && data[3] == 0xA3) {
            _hasVideo = true;
            
            // Check for "webm" doctype
            foreach (i; 0 .. data.length - 4) {
                if (data[i .. i + 4] == cast(ubyte[])"webm") {
                    return true;
                }
            }
            
            // Even without finding "webm" string, the EBML signature is valid
            return true;
        }

        return false;
    }
}
