/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.image.formats.png;

import uim.media.image.base;
import std.bitmanip;
import std.exception;
import std.file;
import vibe.core.log;

@safe:

/**
 * PNG image format handler
 */
class PngImage : Image {
    private {
        ubyte _bitDepth;
        ubyte _colorType;
        ubyte _compressionMethod;
        ubyte _filterMethod;
        ubyte _interlaceMethod;
    }

    this() {
        super();
        this.format = ImageFormat.png;
    }

    this(string path) {
        super(path);
        this.format = ImageFormat.png;
    }

    /**
     * Read PNG header and extract basic information
     */
    bool readHeader(ubyte[] data) @trusted {
        // PNG signature: 137 80 78 71 13 10 26 10
        if (data.length < 8) return false;
        
        if (data[0] != 137 || data[1] != 80 || data[2] != 78 || data[3] != 71) {
            return false;
        }

        // Look for IHDR chunk (must be first chunk after signature)
        if (data.length < 33) return false;

        // Skip signature (8 bytes) and chunk length (4 bytes)
        size_t pos = 8 + 4;
        
        // Check for IHDR chunk type
        if (data[pos .. pos + 4] != cast(ubyte[])"IHDR") {
            return false;
        }
        pos += 4;

        // Read width (4 bytes, big-endian)
        ubyte[4] widthBytes = data[pos .. pos + 4];
        _width = bigEndianToNative!uint(widthBytes);
        pos += 4;

        // Read height (4 bytes, big-endian)
        ubyte[4] heightBytes = data[pos .. pos + 4];
        _height = bigEndianToNative!uint(heightBytes);
        pos += 4;

        // Read image info
        _bitDepth = data[pos++];
        _colorType = data[pos++];
        _compressionMethod = data[pos++];
        _filterMethod = data[pos++];
        _interlaceMethod = data[pos++];

        // Set color mode based on color type
        switch (_colorType) {
            case 0: // Grayscale
                _colorMode = ColorMode.grayscale;
                break;
            case 2: // RGB
                _colorMode = ColorMode.rgb;
                break;
            case 6: // RGBA
                _colorMode = ColorMode.rgba;
                break;
            default:
                _colorMode = ColorMode.rgb;
        }

        return true;
    }

    @property ubyte bitDepth() const { return _bitDepth; }
    @property ubyte colorType() const { return _colorType; }
}
