/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.audio.formats.ogg;

import uim.media.audio.base;
import std.exception;
import std.file;
import vibe.core.log;

@safe:

/**
 * OGG Vorbis audio format handler
 */
class OggAudio : Audio {
    private {
        uint _version;
        uint _bitrateNominal;
        uint _bitrateMaximum;
        uint _bitrateMinimum;
    }

    this() {
        super();
        this.format = AudioFormat.ogg;
        this.codec = AudioCodec.vorbis;
    }

    this(string path) {
        super(path);
        this.format = AudioFormat.ogg;
        this.codec = AudioCodec.vorbis;
    }

    /**
     * Read OGG header
     */
    bool readHeader(ubyte[] data) @trusted {
        if (data.length < 27) return false;

        // Check for OGG signature: "OggS"
        if (data[0 .. 4] != cast(ubyte[])"OggS") {
            return false;
        }

        // Version (should be 0)
        _version = data[4];
        
        // Header type flag
        ubyte headerType = data[5];
        
        // Skip granule position (8 bytes)
        // Skip serial number (4 bytes)
        // Skip sequence number (4 bytes)
        // Skip checksum (4 bytes)
        
        // Number of page segments
        ubyte numSegments = data[26];
        
        if (data.length < 27 + numSegments) return false;

        // Look for Vorbis identification header
        size_t pos = 27 + numSegments;
        
        if (pos + 30 <= data.length) {
            // Check for vorbis packet type (1 = identification)
            if (data[pos] == 1) {
                pos++;
                
                // Check for "vorbis" string
                if (data[pos .. pos + 6] == cast(ubyte[])"vorbis") {
                    pos += 6;
                    
                    if (pos + 23 <= data.length) {
                        // Vorbis version (4 bytes, little-endian)
                        uint vorbisVersion = data[pos] | (data[pos + 1] << 8) | 
                                           (data[pos + 2] << 16) | (data[pos + 3] << 24);
                        pos += 4;
                        
                        // Number of channels (1 byte)
                        _channels = data[pos++];
                        _channelConfig = (_channels == 1) ? ChannelConfig.mono : ChannelConfig.stereo;
                        
                        // Sample rate (4 bytes, little-endian)
                        _sampleRate = data[pos] | (data[pos + 1] << 8) | 
                                     (data[pos + 2] << 16) | (data[pos + 3] << 24);
                        pos += 4;
                        
                        // Bitrate maximum (4 bytes)
                        _bitrateMaximum = data[pos] | (data[pos + 1] << 8) | 
                                         (data[pos + 2] << 16) | (data[pos + 3] << 24);
                        pos += 4;
                        
                        // Bitrate nominal (4 bytes)
                        _bitrateNominal = data[pos] | (data[pos + 1] << 8) | 
                                         (data[pos + 2] << 16) | (data[pos + 3] << 24);
                        pos += 4;
                        
                        // Bitrate minimum (4 bytes)
                        _bitrateMinimum = data[pos] | (data[pos + 1] << 8) | 
                                         (data[pos + 2] << 16) | (data[pos + 3] << 24);
                        
                        // Use nominal bitrate if available
                        if (_bitrateNominal > 0) {
                            _bitrate = _bitrateNominal;
                        }
                        
                        _vbr = (_bitrateMinimum != _bitrateMaximum);
                        
                        return true;
                    }
                }
            }
        }

        return false;
    }

    @property uint bitrateNominal() const { return _bitrateNominal; }
    @property uint bitrateMaximum() const { return _bitrateMaximum; }
    @property uint bitrateMinimum() const { return _bitrateMinimum; }
}
