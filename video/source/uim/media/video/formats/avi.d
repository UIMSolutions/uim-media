/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.video.formats.avi;

import uim.media.video.base;
import std.exception;
import std.file;
import core.time;
import vibe.core.log;

@safe:

/**
 * AVI (Audio Video Interleave) format handler
 */
class AviVideo : Video {
    private {
        uint _maxBytesPerSec;
        uint _totalFrames;
    }

    this() {
        super();
        this.format = VideoFormat.avi;
    }

    this(string path) {
        super(path);
        this.format = VideoFormat.avi;
    }

    /**
     * Read AVI header (RIFF format)
     */
    bool readHeader(ubyte[] data) @trusted {
        if (data.length < 12) return false;

        // Check for RIFF signature
        if (data[0 .. 4] != cast(ubyte[])"RIFF") {
            return false;
        }

        // Read file size (4 bytes, little-endian)
        // uint fileSize = data[4] | (data[5] << 8) | (data[6] << 16) | (data[7] << 24);

        // Check for AVI format
        if (data[8 .. 12] != cast(ubyte[])"AVI ") {
            return false;
        }

        // Look for 'avih' (AVI header) in LIST chunk
        size_t pos = 12;
        while (pos + 8 <= data.length) {
            string chunkId = cast(string)data[pos .. pos + 4].dup;
            pos += 4;
            
            uint chunkSize = data[pos] | (data[pos + 1] << 8) | 
                            (data[pos + 2] << 16) | (data[pos + 3] << 24);
            pos += 4;

            if (chunkId == "LIST" && pos + 4 <= data.length) {
                string listType = cast(string)data[pos .. pos + 4].dup;
                
                if (listType == "hdrl") {
                    // Header list - contains avih
                    pos += 4;
                    
                    if (pos + 8 <= data.length) {
                        string avihId = cast(string)data[pos .. pos + 4].dup;
                        
                        if (avihId == "avih") {
                            pos += 8; // Skip avih chunk header
                            
                            if (pos + 32 <= data.length) {
                                // Read microseconds per frame
                                uint microSecPerFrame = data[pos] | (data[pos + 1] << 8) | 
                                                       (data[pos + 2] << 16) | (data[pos + 3] << 24);
                                
                                if (microSecPerFrame > 0) {
                                    _frameRate = 1_000_000.0 / microSecPerFrame;
                                }
                                
                                pos += 4;
                                
                                // Read max bytes per sec
                                _maxBytesPerSec = data[pos] | (data[pos + 1] << 8) | 
                                                 (data[pos + 2] << 16) | (data[pos + 3] << 24);
                                _bitrate = _maxBytesPerSec * 8;
                                
                                pos += 12; // Skip to width/height
                                
                                // Read width
                                _width = data[pos] | (data[pos + 1] << 8) | 
                                        (data[pos + 2] << 16) | (data[pos + 3] << 24);
                                pos += 4;
                                
                                // Read height
                                _height = data[pos] | (data[pos + 1] << 8) | 
                                         (data[pos + 2] << 16) | (data[pos + 3] << 24);
                                
                                _hasVideo = true;
                                return true;
                            }
                        }
                    }
                }
            }
            
            // Move to next chunk
            if (chunkSize > 0 && pos + chunkSize <= data.length) {
                pos += chunkSize;
            } else {
                break;
            }
        }

        return false;
    }

    @property uint totalFrames() const { return _totalFrames; }
}
