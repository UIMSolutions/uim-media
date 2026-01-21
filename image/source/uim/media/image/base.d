/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.image.base;

import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.file;
import std.path;
import std.string;
import std.format : fmt = format;
import vibe.core.file;
import vibe.core.log;

@safe:

/**
 * Image format enumeration
 */
enum ImageFormat {
    unknown,
    png,
    jpeg,
    gif,
    bmp,
    tiff,
    webp,
    svg
}

/**
 * Color mode enumeration
 */
enum ColorMode {
    grayscale,
    rgb,
    rgba,
    cmyk
}

/**
 * Base image class representing an image file
 */
class Image {
    protected {
        string _path;
        string _filename;
        ImageFormat _format;
        size_t _width;
        size_t _height;
        ColorMode _colorMode;
        ubyte[] _data;
        bool _loaded;
    }

    /**
     * Constructor
     */
    this() {
        _loaded = false;
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

    @property ImageFormat format() const { return _format; }
    @property void format(ImageFormat value) { _format = value; }

    @property size_t width() const { return _width; }
    @property void width(size_t value) { _width = value; }

    @property size_t height() const { return _height; }
    @property void height(size_t value) { _height = value; }

    @property ColorMode colorMode() const { return _colorMode; }
    @property void colorMode(ColorMode value) { _colorMode = value; }

    @property ubyte[] data() { return _data; }
    @property void data(ubyte[] value) { _data = value; }

    @property bool loaded() const { return _loaded; }

    /**
     * Detect image format from file extension
     */
    ImageFormat detectFormat(string filepath) {
        string ext = extension(filepath).toLower;
        switch (ext) {
            case ".png":
                return ImageFormat.png;
            case ".jpg":
            case ".jpeg":
                return ImageFormat.jpeg;
            case ".gif":
                return ImageFormat.gif;
            case ".bmp":
                return ImageFormat.bmp;
            case ".tiff":
            case ".tif":
                return ImageFormat.tiff;
            case ".webp":
                return ImageFormat.webp;
            case ".svg":
                return ImageFormat.svg;
            default:
                return ImageFormat.unknown;
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
     * Get image info as string
     */
    override string toString() const {
        return fmt("Image(path=%s, format=%s, size=%dx%d, colorMode=%s)",
            _path, _format, _width, _height, _colorMode);
    }
}

/**
 * Image exception class
 */
class ImageException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
