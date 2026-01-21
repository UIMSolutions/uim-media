/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.image.formats.jpeg;

import uim.media.image.base;
import std.bitmanip;
import std.exception;
import std.file;
import vibe.core.log;

@safe:

/**
 * JPEG image format handler
 */
class JpegImage : Image {
    private {
        int _quality;
        bool _progressive;
    }

    this() {
        super();
        this.format = ImageFormat.jpeg;
        _quality = 85;
    }

    this(string path) {
        super(path);
        this.format = ImageFormat.jpeg;
        _quality = 85;
    }

    /**
     * Read JPEG header and extract basic information
     */
    bool readHeader(ubyte[] data) @trusted {
        if (data.length < 11) return false;

        // Check for JPEG magic bytes (FF D8)
        if (data[0] != 0xFF || data[1] != 0xD8) {
            return false;
        }

        size_t pos = 2;
        while (pos < data.length - 1) {
            // Find next marker
            if (data[pos] != 0xFF) {
                pos++;
                continue;
            }

            ubyte marker = data[pos + 1];
            pos += 2;

            // Check for Start of Frame markers (SOF0-SOF15)
            if ((marker >= 0xC0 && marker <= 0xCF) && marker != 0xC4 && marker != 0xC8 && marker != 0xCC) {
                if (pos + 6 >= data.length) return false;

                // Skip length
                pos += 2;

                // Precision
                pos++;

                // Height (2 bytes, big-endian)
                _height = (data[pos] << 8) | data[pos + 1];
                pos += 2;

                // Width (2 bytes, big-endian)
                _width = (data[pos] << 8) | data[pos + 1];
                pos += 2;

                // Number of components
                ubyte components = data[pos];
                
                // Set color mode
                if (components == 1) {
                    _colorMode = ColorMode.grayscale;
                } else if (components == 3) {
                    _colorMode = ColorMode.rgb;
                } else if (components == 4) {
                    _colorMode = ColorMode.cmyk;
                }

                _progressive = (marker == 0xC2);
                return true;
            }

            // Skip this segment
            if (pos + 2 >= data.length) break;
            ushort segmentLength = (data[pos] << 8) | data[pos + 1];
            pos += segmentLength;
        }

        return false;
    }

    @property int quality() const { return _quality; }
    @property void quality(int value) { _quality = value; }

    @property bool progressive() const { return _progressive; }
}
