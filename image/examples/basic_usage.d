/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module examples.basic_usage;

import uim.media.image;
import std.stdio;

void main() {
    writeln("=== UIM Media Image Library - Basic Usage Examples ===\n");

    // Example 1: Load and inspect an image
    exampleLoadImage();

    // Example 2: Format-specific operations
    exampleFormatSpecific();

    // Example 3: Image operations
    exampleOperations();

    // Example 4: Metadata handling
    exampleMetadata();
}

void exampleLoadImage() {
    writeln("--- Example 1: Load and Inspect Image ---");
    
    try {
        // Create an image object
        auto img = new Image("/path/to/image.jpg");
        
        writeln("File: ", img.filename);
        writeln("Exists: ", img.exists);
        writeln("Format: ", img.format);
        writeln("Path: ", img.path);
        
        // If you want to actually load the data
        // auto loadedImg = ImageLoader.load("/path/to/actual/image.jpg");
        // writeln("Dimensions: ", loadedImg.width, "x", loadedImg.height);
        // writeln("Aspect Ratio: ", loadedImg.aspectRatio);
        // writeln("Color Mode: ", loadedImg.colorMode);
        
    } catch (Exception e) {
        writeln("Error: ", e.msg);
    }
    
    writeln();
}

void exampleFormatSpecific() {
    writeln("--- Example 2: Format-Specific Operations ---");
    
    // PNG example
    auto png = new PngImage("image.png");
    writeln("PNG Format: ", png.format);
    
    // JPEG example with quality setting
    auto jpeg = new JpegImage("photo.jpg");
    jpeg.quality = 85;
    writeln("JPEG Quality: ", jpeg.quality);
    
    // GIF example
    auto gif = new GifImage("animation.gif");
    writeln("GIF Animated: ", gif.animated);
    writeln("Frame Count: ", gif.frameCount);
    
    writeln();
}

void exampleOperations() {
    writeln("--- Example 3: Image Operations ---");
    
    // Calculate resize dimensions
    size_t newWidth, newHeight;
    ImageOperations.calculateResizeDimensions(
        1920, 1080,  // Original dimensions
        800, 0,      // Target dimensions (0 means auto-calculate)
        true,        // Maintain aspect ratio
        newWidth, newHeight
    );
    writeln("Resize 1920x1080 to width=800: ", newWidth, "x", newHeight);
    
    // Calculate crop position
    size_t x, y;
    ImageOperations.calculateCropDimensions(
        1920, 1080,  // Original dimensions
        800, 600,    // Crop dimensions
        "center",    // Position
        x, y
    );
    writeln("Crop position for centered 800x600: x=", x, ", y=", y);
    
    // Check rotation needs
    writeln("Needs rotation (orientation=6): ", ImageOperations.needsRotation(6));
    writeln("Rotation angle: ", ImageOperations.getRotationAngle(6), " degrees");
    
    writeln();
}

void exampleMetadata() {
    writeln("--- Example 4: Metadata Handling ---");
    
    auto metadata = new ImageMetadata();
    
    // Set basic metadata
    metadata.title = "Sunset Photo";
    metadata.author = "John Doe";
    metadata.copyright = "© 2026 John Doe";
    metadata.description = "Beautiful sunset over the ocean";
    
    // Set EXIF orientation
    metadata.orientation = ExifOrientation.rotate90;
    
    // Add custom metadata
    metadata.setCustomData("camera", "Canon EOS R5");
    metadata.setCustomData("lens", "RF 24-70mm f/2.8");
    
    // Set EXIF data
    metadata.setExifData("ISO", 400);
    metadata.setExifData("ShutterSpeed", 125);
    metadata.setExifData("Aperture", 28);
    
    // Read metadata
    writeln("Title: ", metadata.title);
    writeln("Author: ", metadata.author);
    writeln("Copyright: ", metadata.copyright);
    writeln("Orientation: ", metadata.orientation);
    writeln("Camera: ", metadata.getCustomData("camera"));
    writeln("ISO: ", metadata.getExifData("ISO"));
    writeln("\n", metadata.toString());
    
    writeln();
}
