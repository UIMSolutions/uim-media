module uim.media.audio.classes.audio;

import uim.media.audio;
@safe:

/**
 * Base audio class representing an audio file
 */
class Audio {
    protected {
        string _path;
        string _filename;
        AudioFormat _format;
        AudioCodec _codec;
        size_t _sampleRate;
        size_t _bitrate;
        size_t _channels;
        size_t _bitDepth;
        Duration _duration;
        bool _vbr; // Variable bitrate
        ubyte[] _data;
        bool _loaded;
        ChannelConfig _channelConfig;
    }

    /**
     * Constructor
     */
    this() {
        _loaded = false;
        _channels = 2;
        _sampleRate = 44100;
        _bitDepth = 16;
        _channelConfig = ChannelConfig.stereo;
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

    @property AudioFormat format() const { return _format; }
    @property void format(AudioFormat value) { _format = value; }

    @property AudioCodec codec() const { return _codec; }
    @property void codec(AudioCodec value) { _codec = value; }

    @property size_t sampleRate() const { return _sampleRate; }
    @property void sampleRate(size_t value) { _sampleRate = value; }

    @property size_t bitrate() const { return _bitrate; }
    @property void bitrate(size_t value) { _bitrate = value; }

    @property size_t channels() const { return _channels; }
    @property void channels(size_t value) { _channels = value; }

    @property size_t bitDepth() const { return _bitDepth; }
    @property void bitDepth(size_t value) { _bitDepth = value; }

    @property Duration duration() const { return _duration; }
    @property void duration(Duration value) { _duration = value; }

    @property bool vbr() const { return _vbr; }
    @property void vbr(bool value) { _vbr = value; }

    @property ubyte[] data() { return _data; }
    @property void data(ubyte[] value) { _data = value; }

    @property bool loaded() const { return _loaded; }

    @property ChannelConfig channelConfig() const { return _channelConfig; }
    @property void channelConfig(ChannelConfig value) { _channelConfig = value; }

    /**
     * Detect audio format from file extension
     */
    AudioFormat detectFormat(string filepath) {
        string ext = extension(filepath).toLower;
        switch (ext) {
            case ".mp3":
                return AudioFormat.mp3;
            case ".wav":
            case ".wave":
                return AudioFormat.wav;
            case ".flac":
                return AudioFormat.flac;
            case ".ogg":
            case ".oga":
                return AudioFormat.ogg;
            case ".aac":
                return AudioFormat.aac;
            case ".m4a":
            case ".m4b":
            case ".m4p":
                return AudioFormat.m4a;
            case ".wma":
                return AudioFormat.wma;
            case ".opus":
                return AudioFormat.opus;
            case ".ape":
                return AudioFormat.ape;
            case ".aiff":
            case ".aif":
                return AudioFormat.aiff;
            case ".au":
            case ".snd":
                return AudioFormat.au;
            case ".mid":
            case ".midi":
                return AudioFormat.midi;
            default:
                return AudioFormat.unknown;
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
     * Get duration in seconds
     */
    double durationSeconds() const {
        return _duration.total!"msecs" / 1000.0;
    }

    /**
     * Get duration in minutes
     */
    double durationMinutes() const {
        return durationSeconds() / 60.0;
    }

    /**
     * Get human-readable duration string (MM:SS)
     */
    string durationString() const {
        long totalSeconds = _duration.total!"seconds";
        long minutes = totalSeconds / 60;
        long seconds = totalSeconds % 60;
        return fmt("%02d:%02d", minutes, seconds);
    }

    /**
     * Get bitrate in Kbps
     */
    double bitrateKbps() const {
        return _bitrate / 1000.0;
    }

    /**
     * Check if audio is high quality (>= 320 kbps or lossless)
     */
    bool isHighQuality() const {
        return _bitrate >= 320_000 || isLossless();
    }

    /**
     * Check if audio is lossless format
     */
    bool isLossless() const {
        return _format == AudioFormat.flac || 
               _format == AudioFormat.alac || 
               _format == AudioFormat.ape ||
               _format == AudioFormat.wav ||
               _format == AudioFormat.aiff;
    }

    /**
     * Check if audio is stereo
     */
    bool isStereo() const {
        return _channels == 2;
    }

    /**
     * Check if audio is mono
     */
    bool isMono() const {
        return _channels == 1;
    }

    /**
     * Get sample rate in kHz
     */
    double sampleRateKHz() const {
        return _sampleRate / 1000.0;
    }

    /**
     * Get channel configuration string
     */
    string channelConfigString() const {
        final switch (_channelConfig) {
            case ChannelConfig.mono: return "Mono";
            case ChannelConfig.stereo: return "Stereo";
            case ChannelConfig.surround_5_1: return "5.1 Surround";
            case ChannelConfig.surround_7_1: return "7.1 Surround";
            case ChannelConfig.custom: return fmt("%d channels", _channels);
        }
    }

    /**
     * Get audio info as string
     */
    override string toString() const {
        return fmt("Audio(path=%s, format=%s, codec=%s, bitrate=%d kbps, duration=%s)",
            _path, _format, _codec, _bitrate / 1000, durationString());
    }
}
