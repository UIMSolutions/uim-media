/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.video.metadata;

import uim.media.video.base;
import std.datetime;
import std.conv;
import std.string;
import std.format : fmt = format;
import vibe.core.log;

@safe:

/**
 * Video metadata container
 */
class VideoMetadata {
    private {
        string _title;
        string _description;
        string _artist;
        string _album;
        string _genre;
        string _copyright;
        string _comment;
        uint _year;
        uint _track;
        SysTime _createdDate;
        SysTime _modifiedDate;
        string[string] _customData;
        string[] _tags;
    }

    this() {}

    // Properties
    @property string title() const { return _title; }
    @property void title(string value) { _title = value; }

    @property string description() const { return _description; }
    @property void description(string value) { _description = value; }

    @property string artist() const { return _artist; }
    @property void artist(string value) { _artist = value; }

    @property string album() const { return _album; }
    @property void album(string value) { _album = value; }

    @property string genre() const { return _genre; }
    @property void genre(string value) { _genre = value; }

    @property string copyright() const { return _copyright; }
    @property void copyright(string value) { _copyright = value; }

    @property string comment() const { return _comment; }
    @property void comment(string value) { _comment = value; }

    @property uint year() const { return _year; }
    @property void year(uint value) { _year = value; }

    @property uint track() const { return _track; }
    @property void track(uint value) { _track = value; }

    @property SysTime createdDate() const { return _createdDate; }
    @property void createdDate(SysTime value) { _createdDate = value; }

    @property SysTime modifiedDate() const { return _modifiedDate; }
    @property void modifiedDate(SysTime value) { _modifiedDate = value; }

    @property string[] tags() const { return _tags.dup; }
    @property void tags(string[] value) { _tags = value; }

    /**
     * Add a tag
     */
    void addTag(string tag) {
        _tags ~= tag;
    }

    /**
     * Remove a tag
     */
    void removeTag(string tag) {
        import std.algorithm : remove;
        import std.array : array;
        _tags = _tags.remove!(a => a == tag).array;
    }

    /**
     * Check if tag exists
     */
    bool hasTag(string tag) const {
        import std.algorithm : canFind;
        return _tags.canFind(tag);
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
     * Convert metadata to string representation
     */
    override string toString() const {
        return fmt("VideoMetadata(title=%s, artist=%s, year=%d)",
            _title, _artist, _year);
    }
}

/**
 * Metadata reader interface
 */
interface IMetadataReader {
    VideoMetadata read(Video video);
}

/**
 * Metadata writer interface
 */
interface IMetadataWriter {
    void write(Video video, VideoMetadata metadata);
}
