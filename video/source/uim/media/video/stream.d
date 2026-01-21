/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.video.stream;

import uim.media.video.base;
import std.string;
import std.format : fmt = format;

@safe:

/**
 * Stream type enumeration
 */
enum StreamType {
    video,
    audio,
    subtitle,
    data
}

/**
 * Video stream information
 */
class VideoStream {
    private {
        StreamType _type;
        int _index;
        VideoCodec _codec;
        size_t _width;
        size_t _height;
        double _frameRate;
        size_t _bitrate;
        string _language;
        bool _default;
    }

    this() {
        _type = StreamType.video;
        _default = false;
    }

    // Properties
    @property StreamType type() const { return _type; }
    
    @property int index() const { return _index; }
    @property void index(int value) { _index = value; }

    @property VideoCodec codec() const { return _codec; }
    @property void codec(VideoCodec value) { _codec = value; }

    @property size_t width() const { return _width; }
    @property void width(size_t value) { _width = value; }

    @property size_t height() const { return _height; }
    @property void height(size_t value) { _height = value; }

    @property double frameRate() const { return _frameRate; }
    @property void frameRate(double value) { _frameRate = value; }

    @property size_t bitrate() const { return _bitrate; }
    @property void bitrate(size_t value) { _bitrate = value; }

    @property string language() const { return _language; }
    @property void language(string value) { _language = value; }

    @property bool isDefault() const { return _default; }
    @property void isDefault(bool value) { _default = value; }

    override string toString() const {
        return fmt("VideoStream(index=%d, codec=%s, resolution=%dx%d, fps=%.2f)",
            _index, _codec, _width, _height, _frameRate);
    }
}

/**
 * Audio stream information
 */
class AudioStream {
    private {
        StreamType _type;
        int _index;
        AudioCodec _codec;
        size_t _sampleRate;
        size_t _channels;
        size_t _bitrate;
        string _language;
        bool _default;
    }

    this() {
        _type = StreamType.audio;
        _default = false;
    }

    // Properties
    @property StreamType type() const { return _type; }
    
    @property int index() const { return _index; }
    @property void index(int value) { _index = value; }

    @property AudioCodec codec() const { return _codec; }
    @property void codec(AudioCodec value) { _codec = value; }

    @property size_t sampleRate() const { return _sampleRate; }
    @property void sampleRate(size_t value) { _sampleRate = value; }

    @property size_t channels() const { return _channels; }
    @property void channels(size_t value) { _channels = value; }

    @property size_t bitrate() const { return _bitrate; }
    @property void bitrate(size_t value) { _bitrate = value; }

    @property string language() const { return _language; }
    @property void language(string value) { _language = value; }

    @property bool isDefault() const { return _default; }
    @property void isDefault(bool value) { _default = value; }

    override string toString() const {
        return fmt("AudioStream(index=%d, codec=%s, sampleRate=%d, channels=%d)",
            _index, _codec, _sampleRate, _channels);
    }
}

/**
 * Subtitle stream information
 */
class SubtitleStream {
    private {
        StreamType _type;
        int _index;
        string _format;
        string _language;
        bool _default;
        bool _forced;
    }

    this() {
        _type = StreamType.subtitle;
        _default = false;
        _forced = false;
    }

    // Properties
    @property StreamType type() const { return _type; }
    
    @property int index() const { return _index; }
    @property void index(int value) { _index = value; }

    @property string format() const { return _format; }
    @property void format(string value) { _format = value; }

    @property string language() const { return _language; }
    @property void language(string value) { _language = value; }

    @property bool isDefault() const { return _default; }
    @property void isDefault(bool value) { _default = value; }

    @property bool forced() const { return _forced; }
    @property void forced(bool value) { _forced = value; }

    override string toString() const {
        return fmt("SubtitleStream(index=%d, format=%s, language=%s)",
            _index, _format, _language);
    }
}
