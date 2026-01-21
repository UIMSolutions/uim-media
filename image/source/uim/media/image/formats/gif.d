/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.image.formats.gif;

import uim.media.image.base;
import std.exception;
import std.file;
import vibe.core.log;

@safe:

/**
 * GIF image format handler
 */
class GifImage : Image {
    private {
        bool _animated;
        size_t _frameCount;
    }

    this() {
        super();
        this.format = ImageFormat.gif;
        _animated = false;
        _frameCount = 1;
    }

    this(string path) {
        super(path);
        this.format = ImageFormat.gif;
        _animated = false;
        _frameCount = 1;
    }

    /**
     * Read GIF header and extract basic information
     */
    bool readHeader(ubyte[] data) @trusted {
        if (data.length < 13) return false;

        // Check for GIF signature: "GIF87a" or "GIF89a"
        if (data[0 .. 3] != cast(ubyte[])"GIF") {
            return false;
        }

        // Check version
        if (data[3 .. 6] != cast(ubyte[])"87a" && data[3 .. 6] != cast(ubyte[])"89a") {
            return false;
        }

        // Read width (2 bytes, little-endian)
        _width = data[6] | (data[7] << 8);

        // Read height (2 bytes, little-endian)
        _height = data[8] | (data[9] << 8);

        // For GIF, color mode is typically indexed color, we'll report as RGB
        _colorMode = ColorMode.rgb;

        // Check for animation (simple check for multiple images)
        // This is a basic implementation
        _animated = (data[3 .. 6] == cast(ubyte[])"89a");

        return true;
    }

    @property bool animated() const { return _animated; }
    @property size_t frameCount() const { return _frameCount; }
}
