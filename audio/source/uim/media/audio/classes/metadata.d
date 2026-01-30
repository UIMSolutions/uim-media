module uim.media.audio.classes.metadata;

import uim.media.audio;
@safe:
/**
 * Audio metadata container (ID3-like structure)
 */
class AudioMetadata {
    private {
        string _title;
        string _artist;
        string _album;
        string _albumArtist;
        string _composer;
        string _genre;
        string _comment;
        uint _year;
        uint _track;
        uint _trackTotal;
        uint _disc;
        uint _discTotal;
        string _publisher;
        string _isrc; // International Standard Recording Code
        string _copyright;
        uint _bpm; // Beats per minute
        string _lyrics;
        SysTime _releaseDate;
        SysTime _encodedDate;
        string[string] _customData;
        ubyte[] _albumArt;
        string _albumArtMimeType;
    }

    this() {}

    // Properties
    @property string title() const { return _title; }
    @property void title(string value) { _title = value; }

    @property string artist() const { return _artist; }
    @property void artist(string value) { _artist = value; }

    @property string album() const { return _album; }
    @property void album(string value) { _album = value; }

    @property string albumArtist() const { return _albumArtist; }
    @property void albumArtist(string value) { _albumArtist = value; }

    @property string composer() const { return _composer; }
    @property void composer(string value) { _composer = value; }

    @property string genre() const { return _genre; }
    @property void genre(string value) { _genre = value; }

    @property string comment() const { return _comment; }
    @property void comment(string value) { _comment = value; }

    @property uint year() const { return _year; }
    @property void year(uint value) { _year = value; }

    @property uint track() const { return _track; }
    @property void track(uint value) { _track = value; }

    @property uint trackTotal() const { return _trackTotal; }
    @property void trackTotal(uint value) { _trackTotal = value; }

    @property uint disc() const { return _disc; }
    @property void disc(uint value) { _disc = value; }

    @property uint discTotal() const { return _discTotal; }
    @property void discTotal(uint value) { _discTotal = value; }

    @property string publisher() const { return _publisher; }
    @property void publisher(string value) { _publisher = value; }

    @property string isrc() const { return _isrc; }
    @property void isrc(string value) { _isrc = value; }

    @property string copyright() const { return _copyright; }
    @property void copyright(string value) { _copyright = value; }

    @property uint bpm() const { return _bpm; }
    @property void bpm(uint value) { _bpm = value; }

    @property string lyrics() const { return _lyrics; }
    @property void lyrics(string value) { _lyrics = value; }

    @property SysTime releaseDate() const { return _releaseDate; }
    @property void releaseDate(SysTime value) { _releaseDate = value; }

    @property SysTime encodedDate() const { return _encodedDate; }
    @property void encodedDate(SysTime value) { _encodedDate = value; }

    @property ubyte[] albumArt() { return _albumArt; }
    @property void albumArt(ubyte[] value) { _albumArt = value; }

    @property string albumArtMimeType() const { return _albumArtMimeType; }
    @property void albumArtMimeType(string value) { _albumArtMimeType = value; }

    /**
     * Get track number string (e.g., "5/12")
     */
    string trackString() const {
        if (_trackTotal > 0) {
            return fmt("%d/%d", _track, _trackTotal);
        }
        return fmt("%d", _track);
    }

    /**
     * Get disc number string (e.g., "1/2")
     */
    string discString() const {
        if (_discTotal > 0) {
            return fmt("%d/%d", _disc, _discTotal);
        }
        return fmt("%d", _disc);
    }

    /**
     * Get custom metadata
     */
    string getCustomData(string key) const {
        auto ptr = key in _customData;
        return ptr ? *ptr : "";
    }

    /**
     * Set custom metadata
     */
    void setCustomData(string key, string value) {
        _customData[key] = value;
    }

    /**
     * Get all custom data
     */
    @property const(string[string]) customData() const { return _customData; }

    /**
     * Check if album art is present
     */
    bool hasAlbumArt() const {
        return _albumArt.length > 0;
    }

    /**
     * Convert metadata to string representation
     */
    override string toString() const {
        return fmt("AudioMetadata(title=%s, artist=%s, album=%s, year=%d, track=%s)",
            _title, _artist, _album, _year, trackString());
    }
}