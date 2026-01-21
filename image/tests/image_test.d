/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module tests.image_test;

import uim.media.image;
import std.stdio;
import std.path;

unittest {
    writeln("Running image library tests...");

    // Test 1: Image format detection
    {
        auto img = new Image("test.png");
        assert(img.detectFormat("test.png") == ImageFormat.png);
        assert(img.detectFormat("photo.jpg") == ImageFormat.jpeg);
        assert(img.detectFormat("image.jpeg") == ImageFormat.jpeg);
        assert(img.detectFormat("anim.gif") == ImageFormat.gif);
        assert(img.detectFormat("pic.bmp") == ImageFormat.bmp);
        assert(img.detectFormat("photo.webp") == ImageFormat.webp);
        assert(img.detectFormat("unknown.xyz") == ImageFormat.unknown);
        writeln("✓ Image format detection tests passed");
    }

    // Test 2: Image properties
    {
        auto img = new Image("/path/to/image.jpg");
        assert(img.path == "/path/to/image.jpg");
        assert(img.filename == "image.jpg");
        assert(img.format == ImageFormat.jpeg);
        assert(!img.loaded);
        writeln("✓ Image properties tests passed");
    }

    // Test 3: Aspect ratio calculation
    {
        auto img = new Image();
        img.width = 1920;
        img.height = 1080;
        assert(img.aspectRatio > 1.777 && img.aspectRatio < 1.778);
        
        img.width = 1080;
        img.height = 1920;
        assert(img.aspectRatio > 0.562 && img.aspectRatio < 0.563);
        writeln("✓ Aspect ratio tests passed");
    }

    // Test 4: Resize calculations
    {
        size_t newWidth, newHeight;
        
        // Test maintaining aspect ratio - width only
        ImageOperations.calculateResizeDimensions(
            1920, 1080, 800, 0, true, newWidth, newHeight
        );
        assert(newWidth == 800);
        assert(newHeight == 450);
        
        // Test maintaining aspect ratio - height only
        ImageOperations.calculateResizeDimensions(
            1920, 1080, 0, 600, true, newWidth, newHeight
        );
        assert(newWidth == 1066 || newWidth == 1067);
        assert(newHeight == 600);
        
        // Test without maintaining aspect ratio
        ImageOperations.calculateResizeDimensions(
            1920, 1080, 800, 600, false, newWidth, newHeight
        );
        assert(newWidth == 800);
        assert(newHeight == 600);
        
        writeln("✓ Resize calculation tests passed");
    }

    // Test 5: Crop calculations
    {
        size_t x, y;
        
        // Test center crop
        ImageOperations.calculateCropDimensions(
            1920, 1080, 800, 600, "center", x, y
        );
        assert(x == 560);
        assert(y == 240);
        
        // Test top crop
        ImageOperations.calculateCropDimensions(
            1920, 1080, 800, 600, "top", x, y
        );
        assert(x == 560);
        assert(y == 0);
        
        // Test bottom-right crop
        ImageOperations.calculateCropDimensions(
            1920, 1080, 800, 600, "bottomright", x, y
        );
        assert(x == 1120);
        assert(y == 480);
        
        writeln("✓ Crop calculation tests passed");
    }

    // Test 6: EXIF orientation
    {
        assert(ImageOperations.needsRotation(1) == false);
        assert(ImageOperations.needsRotation(3) == true);
        assert(ImageOperations.needsRotation(6) == true);
        assert(ImageOperations.needsRotation(8) == true);
        
        assert(ImageOperations.getRotationAngle(1) == 0);
        assert(ImageOperations.getRotationAngle(3) == 180);
        assert(ImageOperations.getRotationAngle(6) == 90);
        assert(ImageOperations.getRotationAngle(8) == 270);
        
        writeln("✓ EXIF orientation tests passed");
    }

    // Test 7: Metadata
    {
        auto metadata = new ImageMetadata();
        metadata.title = "Test Image";
        metadata.author = "Test Author";
        metadata.copyright = "© 2026";
        metadata.orientation = ExifOrientation.rotate90;
        
        assert(metadata.title == "Test Image");
        assert(metadata.author == "Test Author");
        assert(metadata.orientation == ExifOrientation.rotate90);
        
        // Test custom data
        metadata.setCustomData("camera", "Canon");
        assert(metadata.getCustomData("camera") == "Canon");
        assert(metadata.getCustomData("nonexistent") == "");
        
        // Test EXIF data
        metadata.setExifData("ISO", 400);
        assert(metadata.getExifData("ISO") == 400);
        assert(metadata.getExifData("nonexistent") == 0);
        
        writeln("✓ Metadata tests passed");
    }

    // Test 8: Format-specific classes
    {
        auto png = new PngImage("test.png");
        assert(png.format == ImageFormat.png);
        
        auto jpeg = new JpegImage("test.jpg");
        assert(jpeg.format == ImageFormat.jpeg);
        jpeg.quality = 90;
        assert(jpeg.quality == 90);
        
        auto gif = new GifImage("test.gif");
        assert(gif.format == ImageFormat.gif);
        assert(gif.frameCount == 1);
        
        writeln("✓ Format-specific class tests passed");
    }

    writeln("\n✅ All tests passed!");
}

void main() {
    writeln("=== UIM Media Image Library - Unit Tests ===\n");
}
