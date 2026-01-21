/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.audio.formats.flac;

import uim.media.audio.base;
import std.exception;
import std.file;
import core.time;
import vibe.core.log;

@safe:

/**
 * FLAC (Free Lossless Audio Codec) format handler
 */
class FlacAudio : Audio {
    private {
        uint _minBlockSize;
        uint _maxBlockSize;
        uint _minFrameSize;
        uint _maxFrameSize;
        ulong _totalSamples;
        ubyte[16] _md5;
    }

    this() {
        super();
        this.format = AudioFormat.flac;
        this.codec = AudioCodec.flac;
    }

    this(string path) {
        super(path);
        this.format = AudioFormat.flac;
        this.codec = AudioCodec.flac;
    }

    /**
     * Read FLAC header
     */
    bool readHeader(ubyte[] data) @trusted {
        if (data.length < 42) return false;

        // Check for FLAC signature: "fLaC"
        if (data[0 .. 4] != cast(ubyte[])"fLaC") {
            return false;
        }

        // First metadata block should be STREAMINFO
        ubyte blockHeader = data[4];
        bool lastBlock = (blockHeader & 0x80) != 0;
        ubyte blockType = blockHeader & 0x7F;

        if (blockType != 0) { // 0 = STREAMINFO
            return false;
        }

        // Read block length (24-bit big-endian)
        uint blockLength = (data[5] << 16) | (data[6] << 8) | data[7];
        
        if (blockLength < 34 || data.length < 42) return false;

        // Read STREAMINFO data
        size_t pos = 8;
        
        // Min/max block size (16 bits each)
        _minBlockSize = (data[pos] << 8) | data[pos + 1];
        pos += 2;
        _maxBlockSize = (data[pos] << 8) | data[pos + 1];
        pos += 2;

        // Min/max frame size (24 bits each)
        _minFrameSize = (data[pos] << 16) | (data[pos + 1] << 8) | data[pos + 2];
        pos += 3;
        _maxFrameSize = (data[pos] << 16) | (data[pos + 1] << 8) | data[pos + 2];
        pos += 3;

        // Sample rate (20 bits), channels (3 bits), bit depth (5 bits)
        ulong temp = 0;
        for (int i = 0; i < 8; i++) {
            temp = (temp << 8) | data[pos + i];
        }
        
        _sampleRate = cast(uint)((temp >> 44) & 0xFFFFF);
        _channels = cast(uint)(((temp >> 41) & 0x07) + 1);
        _bitDepth = cast(uint)(((temp >> 36) & 0x1F) + 1);
        
        // Total samples (36 bits)
        _totalSamples = temp & 0xFFFFFFFFF;
        
        pos += 8;

        // Calculate duration
        if (_sampleRate > 0 && _totalSamples > 0) {
            double durationSecs = cast(double)_totalSamples / cast(double)_sampleRate;
            _duration = dur!"msecs"(cast(long)(durationSecs * 1000));
        }

        // MD5 signature (16 bytes)
        if (pos + 16 <= data.length) {
            _md5[0 .. 16] = data[pos .. pos + 16];
        }

        // Set channel config
        if (_channels == 1) {
            _channelConfig = ChannelConfig.mono;
        } else if (_channels == 2) {
            _channelConfig = ChannelConfig.stereo;
        } else if (_channels == 6) {
            _channelConfig = ChannelConfig.surround_5_1;
        } else if (_channels == 8) {
            _channelConfig = ChannelConfig.surround_7_1;
        } else {
            _channelConfig = ChannelConfig.custom;
        }

        return true;
    }

    @property ulong totalSamples() const { return _totalSamples; }
}
