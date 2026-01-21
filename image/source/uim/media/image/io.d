/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.image.io;

import uim.media.image.base;
import uim.media.image.formats;
import std.exception;
import std.file;
import std.path;
import std.string;
import vibe.core.file;
import vibe.core.log;

@safe:

/**
 * Image loader factory
 */
class ImageLoader {
    /**
     * Load an image from file
     */
    static Image load(string filepath) @trusted {
        enforce(exists(filepath), new ImageException("File not found: " ~ filepath));

        auto img = createImageFromPath(filepath);
        img.path = filepath;

        try {
            // Read file data
            ubyte[] fileData = cast(ubyte[])read(filepath);
            img.data = fileData;

            // Try to read header based on format
            bool success = false;
            
            switch (img.format) {
                case ImageFormat.png:
                    auto pngImg = cast(PngImage)img;
                    if (pngImg) success = pngImg.readHeader(fileData);
                    break;
                case ImageFormat.jpeg:
                    auto jpegImg = cast(JpegImage)img;
                    if (jpegImg) success = jpegImg.readHeader(fileData);
                    break;
                case ImageFormat.gif:
                    auto gifImg = cast(GifImage)img;
                    if (gifImg) success = gifImg.readHeader(fileData);
                    break;
                default:
                    logWarn("Unsupported image format for header reading: %s", img.format);
            }

            if (!success && img.format != ImageFormat.unknown) {
                logWarn("Failed to read image header: %s", filepath);
            }

        } catch (Exception e) {
            throw new ImageException("Failed to load image: " ~ e.msg);
        }

        return img;
    }

    /**
     * Create appropriate image object based on file extension
     */
    private static Image createImageFromPath(string filepath) {
        Image img = new Image();
        auto format = img.detectFormat(filepath);
        
        switch (format) {
            case ImageFormat.png:
                return new PngImage(filepath);
            case ImageFormat.jpeg:
                return new JpegImage(filepath);
            case ImageFormat.gif:
                return new GifImage(filepath);
            default:
                auto genericImg = new Image(filepath);
                genericImg.format = format;
                return genericImg;
        }
    }

    /**
     * Save image to file
     */
    static void save(Image img, string filepath) @trusted {
        enforce(img !is null, new ImageException("Image is null"));
        enforce(!img.data.empty, new ImageException("Image data is empty"));

        try {
            write(filepath, img.data);
            img.path = filepath;
            logInfo("Image saved: %s", filepath);
        } catch (Exception e) {
            throw new ImageException("Failed to save image: " ~ e.msg);
        }
    }
}

/**
 * Async image loader using vibe.d
 */
class AsyncImageLoader {
    /**
     * Load image asynchronously
     */
    static Image load(string filepath) @trusted {
        enforce(existsFile(filepath), new ImageException("File not found: " ~ filepath));

        auto img = ImageLoader.createImageFromPath(filepath);
        img.path = filepath;

        try {
            // Read file using vibe.d async operations
            auto file = openFile(filepath);
            scope(exit) file.close();

            auto fileData = new ubyte[file.size];
            file.read(fileData);
            img.data = fileData;

            // Process header
            bool success = false;
            switch (img.format) {
                case ImageFormat.png:
                    auto pngImg = cast(PngImage)img;
                    if (pngImg) success = pngImg.readHeader(fileData);
                    break;
                case ImageFormat.jpeg:
                    auto jpegImg = cast(JpegImage)img;
                    if (jpegImg) success = jpegImg.readHeader(fileData);
                    break;
                case ImageFormat.gif:
                    auto gifImg = cast(GifImage)img;
                    if (gifImg) success = gifImg.readHeader(fileData);
                    break;
                default:
                    break;
            }

        } catch (Exception e) {
            throw new ImageException("Failed to load image: " ~ e.msg);
        }

        return img;
    }

    /**
     * Save image asynchronously
     */
    static void save(Image img, string filepath) @trusted {
        enforce(img !is null, new ImageException("Image is null"));
        enforce(!img.data.empty, new ImageException("Image data is empty"));

        try {
            auto file = openFile(filepath, FileMode.createTrunc);
            scope(exit) file.close();
            
            file.write(img.data);
            img.path = filepath;
            logInfo("Image saved: %s", filepath);
        } catch (Exception e) {
            throw new ImageException("Failed to save image: " ~ e.msg);
        }
    }
}
