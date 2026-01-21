/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.image.metadata;

import uim.media.image.base;
import std.datetime;
import std.conv;
import std.string;
import vibe.core.log;

@safe:

/**
 * EXIF orientation values
 */
enum ExifOrientation {
    normal = 1,
    flipHorizontal = 2,
    rotate180 = 3,
    flipVertical = 4,
    flipHorizontalRotate270 = 5,
    rotate90 = 6,
    flipHorizontalRotate90 = 7,
    rotate270 = 8
}

/**
 * Image metadata container
 */
class ImageMetadata {
    private {
        string _title;
        string _description;
        string _author;
        string _copyright;
        SysTime _createdDate;
        SysTime _modifiedDate;
        int[string] _exifData;
        string[string] _customData;
        ExifOrientation _orientation;
    }

    this() {
        _orientation = ExifOrientation.normal;
    }

    // Properties
    @property string title() const { return _title; }
    @property void title(string value) { _title = value; }

    @property string description() const { return _description; }
    @property void description(string value) { _description = value; }

    @property string author() const { return _author; }
    @property void author(string value) { _author = value; }

    @property string copyright() const { return _copyright; }
    @property void copyright(string value) { _copyright = value; }

    @property SysTime createdDate() const { return _createdDate; }
    @property void createdDate(SysTime value) { _createdDate = value; }

    @property SysTime modifiedDate() const { return _modifiedDate; }
    @property void modifiedDate(SysTime value) { _modifiedDate = value; }

    @property ExifOrientation orientation() const { return _orientation; }
    @property void orientation(ExifOrientation value) { _orientation = value; }

    /**
     * Get EXIF data by tag
     */
    int getExifData(string tag) const {
        auto ptr = tag in _exifData;
        return ptr ? *ptr : 0;
    }

    /**
     * Set EXIF data
     */
    void setExifData(string tag, int value) {
        _exifData[tag] = value;
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
     * Get all EXIF data
     */
    @property const(int[string]) exifData() const { return _exifData; }

    /**
     * Get all custom data
     */
    @property const(string[string]) customData() const { return _customData; }

    /**
     * Convert metadata to string representation
     */
    override string toString() const {
        import std.format : format;
        return format("ImageMetadata(title=%s, author=%s, orientation=%s)",
            _title, _author, _orientation);
    }
}

/**
 * Metadata reader interface
 */
interface IMetadataReader {
    ImageMetadata read(Image img);
}

/**
 * Metadata writer interface
 */
interface IMetadataWriter {
    void write(Image img, ImageMetadata metadata);
}
