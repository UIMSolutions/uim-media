/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.audio.formats.mp3;

import uim.media.audio.base;
import std.bitmanip;
import std.exception;
import std.file;
import core.time;
import vibe.core.log;

@safe:

/**
 * MP3 audio format handler
 */
class Mp3Audio : Audio {
    private {
        int _version;  // MPEG version (1, 2, 2.5)
        int _layer;    // MPEG layer (1, 2, 3)
        bool _protected;
        int _emphasis;
    }

    this() {
        super();
        this.format = AudioFormat.mp3;
        this.codec = AudioCodec.mp3;
    }

    this(string path) {
        super(path);
        this.format = AudioFormat.mp3;
        this.codec = AudioCodec.mp3;
    }

    /**
     * Read MP3 header and extract basic information
     */
    bool readHeader(ubyte[] data) @trusted {
        if (data.length < 4) return false;

        // Look for MP3 sync word (11 bits set): 0xFF 0xFx
        size_t pos = 0;
        while (pos < data.length - 4) {
            if (data[pos] == 0xFF && (data[pos + 1] & 0xE0) == 0xE0) {
                // Found sync word
                ubyte b2 = data[pos + 1];
                ubyte b3 = data[pos + 2];
                ubyte b4 = data[pos + 3];

                // Extract MPEG version
                int mpegVersion = (b2 >> 3) & 0x03;
                if (mpegVersion == 3) _version = 1;
                else if (mpegVersion == 2) _version = 2;
                else if (mpegVersion == 0) _version = 25; // MPEG 2.5

                // Extract layer
                int layerBits = (b2 >> 1) & 0x03;
                if (layerBits == 1) _layer = 3;
                else if (layerBits == 2) _layer = 2;
                else if (layerBits == 3) _layer = 1;

                // Protection bit
                _protected = (b2 & 0x01) == 0;

                // Extract bitrate index
                int bitrateIndex = (b3 >> 4) & 0x0F;
                
                // Extract sampling rate index
                int sampleRateIndex = (b3 >> 2) & 0x03;
                
                // Set sample rate based on version and index
                if (_version == 1) {
                    const int[4] rates = [44100, 48000, 32000, 0];
                    if (sampleRateIndex < 3) _sampleRate = rates[sampleRateIndex];
                } else if (_version == 2) {
                    const int[4] rates = [22050, 24000, 16000, 0];
                    if (sampleRateIndex < 3) _sampleRate = rates[sampleRateIndex];
                }

                // Channel mode
                int channelMode = (b4 >> 6) & 0x03;
                _channels = (channelMode == 3) ? 1 : 2;
                _channelConfig = (channelMode == 3) ? ChannelConfig.mono : ChannelConfig.stereo;

                // Set VBR flag (would need to check Xing/VBRI headers for accurate detection)
                _vbr = false;

                return true;
            }
            pos++;
        }

        return false;
    }

    @property int mpegVersion() const { return _version; }
    @property int layer() const { return _layer; }
    @property bool protected_() const { return _protected; }
}
