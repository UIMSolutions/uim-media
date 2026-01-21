/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.audio.formats.wav;

import uim.media.audio.base;
import std.exception;
import std.file;
import core.time;
import vibe.core.log;

@safe:

/**
 * WAV (Waveform Audio File Format) handler
 */
class WavAudio : Audio {
    private {
        ushort _audioFormat;
        uint _byteRate;
        ushort _blockAlign;
    }

    this() {
        super();
        this.format = AudioFormat.wav;
        this.codec = AudioCodec.pcm;
    }

    this(string path) {
        super(path);
        this.format = AudioFormat.wav;
        this.codec = AudioCodec.pcm;
    }

    /**
     * Read WAV header (RIFF format)
     */
    bool readHeader(ubyte[] data) @trusted {
        if (data.length < 44) return false;

        // Check for RIFF signature
        if (data[0 .. 4] != cast(ubyte[])"RIFF") {
            return false;
        }

        // Read file size (4 bytes, little-endian)
        // uint fileSize = data[4] | (data[5] << 8) | (data[6] << 16) | (data[7] << 24);

        // Check for WAVE format
        if (data[8 .. 12] != cast(ubyte[])"WAVE") {
            return false;
        }

        // Look for 'fmt ' chunk
        if (data[12 .. 16] != cast(ubyte[])"fmt ") {
            return false;
        }

        // Read fmt chunk size
        uint fmtSize = data[16] | (data[17] << 8) | (data[18] << 16) | (data[19] << 24);
        
        if (fmtSize < 16 || data.length < 36) return false;

        // Read audio format (1 = PCM)
        _audioFormat = cast(ushort)(data[20] | (data[21] << 8));
        
        // Read number of channels
        _channels = cast(ushort)(data[22] | (data[23] << 8));
        _channelConfig = (_channels == 1) ? ChannelConfig.mono : ChannelConfig.stereo;
        
        // Read sample rate
        _sampleRate = data[24] | (data[25] << 8) | (data[26] << 16) | (data[27] << 24);
        
        // Read byte rate
        _byteRate = data[28] | (data[29] << 8) | (data[30] << 16) | (data[31] << 24);
        
        // Read block align
        _blockAlign = cast(ushort)(data[32] | (data[33] << 8));
        
        // Read bits per sample
        _bitDepth = cast(ushort)(data[34] | (data[35] << 8));
        
        // Calculate bitrate
        _bitrate = _byteRate * 8;
        
        return true;
    }

    @property ushort audioFormat() const { return _audioFormat; }
    @property uint byteRate() const { return _byteRate; }
}
