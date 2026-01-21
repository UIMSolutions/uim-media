/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.video.base;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.file;
import std.path;
import std.string;
import std.format : fmt = format;
import core.time;
import vibe.core.file;
import vibe.core.log;

@safe:

/**
 * Video format enumeration
 */
enum VideoFormat {
    unknown,
    mp4,
    avi,
    mov,
    mkv,
    webm,
    flv,
    wmv,
    m4v,
    mpeg,
    mpg,
    ogv,
    _3gp
}

/**
 * Video codec enumeration
 */
enum VideoCodec {
    unknown,
    h264,
    h265,
    vp8,
    vp9,
    av1,
    mpeg4,
    mpeg2,
    theora,
    xvid,
    divx
}

/**
 * Audio codec enumeration
 */
enum AudioCodec {
    unknown,
    aac,
    mp3,
    opus,
    vorbis,
    flac,
    pcm,
    ac3,
    dts
}

/**
 * Video quality preset
 */
enum VideoQuality {
    low,
    medium,
    high,
    veryhigh,
    lossless
}

/**
 * Base video class representing a video file
 */
class Video {
    protected {
        string _path;
        string _filename;
        VideoFormat _format;
        size_t _width;
        size_t _height;
        double _frameRate;
        Duration _duration;
        size_t _bitrate;
        VideoCodec _videoCodec;
        AudioCodec _audioCodec;
        size_t _audioBitrate;
        size_t _audioSampleRate;
        size_t _audioChannels;
        ubyte[] _data;
        bool _loaded;
        bool _hasAudio;
        bool _hasVideo;
    }

    /**
     * Constructor
     */
    this() {
        _loaded = false;
        _hasAudio = false;
        _hasVideo = true;
        _audioChannels = 2;
        _audioSampleRate = 44100;
    }

    /**
     * Constructor with path
     */
    this(string path) {
        this();
        _path = path;
        _filename = baseName(path);
    }

    // Properties
    @property string path() const { return _path; }
    @property void path(string value) { _path = value; _filename = baseName(value); }

    @property string filename() const { return _filename; }

    @property VideoFormat format() const { return _format; }
    @property void format(VideoFormat value) { _format = value; }

    @property size_t width() const { return _width; }
    @property void width(size_t value) { _width = value; }

    @property size_t height() const { return _height; }
    @property void height(size_t value) { _height = value; }

    @property double frameRate() const { return _frameRate; }
    @property void frameRate(double value) { _frameRate = value; }

    @property Duration duration() const { return _duration; }
    @property void duration(Duration value) { _duration = value; }

    @property size_t bitrate() const { return _bitrate; }
    @property void bitrate(size_t value) { _bitrate = value; }

    @property VideoCodec videoCodec() const { return _videoCodec; }
    @property void videoCodec(VideoCodec value) { _videoCodec = value; }

    @property AudioCodec audioCodec() const { return _audioCodec; }
    @property void audioCodec(AudioCodec value) { _audioCodec = value; }

    @property size_t audioBitrate() const { return _audioBitrate; }
    @property void audioBitrate(size_t value) { _audioBitrate = value; }

    @property size_t audioSampleRate() const { return _audioSampleRate; }
    @property void audioSampleRate(size_t value) { _audioSampleRate = value; }

    @property size_t audioChannels() const { return _audioChannels; }
    @property void audioChannels(size_t value) { _audioChannels = value; }

    @property ubyte[] data() { return _data; }
    @property void data(ubyte[] value) { _data = value; }

    @property bool loaded() const { return _loaded; }
    @property bool hasAudio() const { return _hasAudio; }
    @property bool hasVideo() const { return _hasVideo; }

    /**
     * Detect video format from file extension
     */
    VideoFormat detectFormat(string filepath) {
        string ext = extension(filepath).toLower;
        switch (ext) {
            case ".mp4":
                return VideoFormat.mp4;
            case ".avi":
                return VideoFormat.avi;
            case ".mov":
                return VideoFormat.mov;
            case ".mkv":
                return VideoFormat.mkv;
            case ".webm":
                return VideoFormat.webm;
            case ".flv":
                return VideoFormat.flv;
            case ".wmv":
                return VideoFormat.wmv;
            case ".m4v":
                return VideoFormat.m4v;
            case ".mpeg":
            case ".mpg":
                return VideoFormat.mpeg;
            case ".ogv":
                return VideoFormat.ogv;
            case ".3gp":
                return VideoFormat._3gp;
            default:
                return VideoFormat.unknown;
        }
    }

    /**
     * Get file size in bytes
     */
    size_t fileSize() @trusted {
        if (_path.empty) return 0;
        try {
            return getSize(_path);
        } catch (Exception e) {
            logError("Failed to get file size: %s", e.msg);
            return 0;
        }
    }

    /**
     * Check if file exists
     */
    bool exists() @trusted {
        if (_path.empty) return false;
        return std.file.exists(_path);
    }

    /**
     * Get aspect ratio
     */
    double aspectRatio() const {
        if (_height == 0) return 0.0;
        return cast(double)_width / cast(double)_height;
    }

    /**
     * Get duration in seconds
     */
    double durationSeconds() const {
        return _duration.total!"msecs" / 1000.0;
    }

    /**
     * Get human-readable duration string
     */
    string durationString() const {
        long totalSeconds = _duration.total!"seconds";
        long hours = totalSeconds / 3600;
        long minutes = (totalSeconds % 3600) / 60;
        long seconds = totalSeconds % 60;
        return fmt("%02d:%02d:%02d", hours, minutes, seconds);
    }

    /**
     * Get bitrate in Kbps
     */
    double bitrateKbps() const {
        return _bitrate / 1000.0;
    }

    /**
     * Get bitrate in Mbps
     */
    double bitrateMbps() const {
        return _bitrate / 1_000_000.0;
    }

    /**
     * Check if video is HD (720p or higher)
     */
    bool isHD() const {
        return _height >= 720;
    }

    /**
     * Check if video is Full HD (1080p)
     */
    bool isFullHD() const {
        return _height >= 1080;
    }

    /**
     * Check if video is 4K
     */
    bool is4K() const {
        return _width >= 3840 && _height >= 2160;
    }

    /**
     * Get video resolution as string
     */
    string resolutionString() const {
        if (is4K()) return "4K";
        if (isFullHD()) return "1080p";
        if (isHD()) return "720p";
        return fmt("%dx%d", _width, _height);
    }

    /**
     * Get video info as string
     */
    override string toString() const {
        return fmt("Video(path=%s, format=%s, resolution=%dx%d, duration=%s, codec=%s)",
            _path, _format, _width, _height, durationString(), _videoCodec);
    }
}

/**
 * Video exception class
 */
class VideoException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
