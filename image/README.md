# UIM Media - Image Library

A comprehensive D language library for working with image files, built with uim-framework and vibe.d.

## Features

- **Multiple Format Support**: PNG, JPEG, GIF, BMP, TIFF, WebP, SVG
- **Image Operations**: Resize, crop, rotate with aspect ratio preservation
- **Metadata Handling**: EXIF data reading and manipulation
- **Async I/O**: Asynchronous file operations using vibe.d
- **Type-Safe**: Strongly typed enumerations for formats, color modes, and operations
- **Framework Integration**: Seamless integration with uim-framework

## Installation

Add to your `dub.sdl`:

```sdl
dependency "uim-media-image" version="~>1.0.0"
```

## Usage

### Basic Image Loading

```d
import uim.media.image;

// Load an image
auto img = ImageLoader.load("photo.jpg");
writeln("Dimensions: ", img.width, "x", img.height);
writeln("Format: ", img.format);
writeln("Aspect Ratio: ", img.aspectRatio);
```

### Async Loading with vibe.d

```d
import uim.media.image;

// Load asynchronously
auto img = AsyncImageLoader.load("photo.png");
writeln("Image loaded: ", img.filename);
```

### Format-Specific Operations

```d
import uim.media.image;

// Work with PNG
auto png = new PngImage("image.png");
if (png.readHeader(fileData)) {
    writeln("Bit depth: ", png.bitDepth);
    writeln("Color type: ", png.colorType);
}

// Work with JPEG
auto jpeg = new JpegImage("photo.jpg");
jpeg.quality = 90;
writeln("Progressive: ", jpeg.progressive);

// Work with GIF
auto gif = new GifImage("animation.gif");
if (gif.animated) {
    writeln("Animated GIF with ", gif.frameCount, " frames");
}
```

### Image Operations

```d
import uim.media.image;

// Calculate resize dimensions
size_t newWidth, newHeight;
ImageOperations.calculateResizeDimensions(
    1920, 1080,  // Original dimensions
    800, 0,      // Target width (height auto-calculated)
    true,        // Maintain aspect ratio
    newWidth, newHeight
);

// Calculate crop position
size_t x, y;
ImageOperations.calculateCropDimensions(
    1920, 1080,  // Original dimensions
    800, 600,    // Crop dimensions
    "center",    // Position
    x, y
);
```

### Metadata Management

```d
import uim.media.image;

auto metadata = new ImageMetadata();
metadata.title = "My Photo";
metadata.author = "John Doe";
metadata.copyright = "© 2026";
metadata.orientation = ExifOrientation.rotate90;

// Custom metadata
metadata.setCustomData("camera", "Canon EOS");
metadata.setExifData("ISO", 400);

writeln(metadata.getCustomData("camera"));
```

### Saving Images

```d
import uim.media.image;

auto img = ImageLoader.load("input.jpg");
// Process image...
ImageLoader.save(img, "output.jpg");

// Async save
AsyncImageLoader.save(img, "output.png");
```

## API Overview

### Classes

- **Image**: Base image class with common properties
- **PngImage**: PNG-specific functionality
- **JpegImage**: JPEG-specific functionality with quality control
- **GifImage**: GIF-specific functionality with animation support
- **ImageLoader**: Synchronous image I/O operations
- **AsyncImageLoader**: Asynchronous image I/O using vibe.d
- **ImageOperations**: Image transformation utilities
- **ImageMetadata**: EXIF and custom metadata container

### Enumerations

- **ImageFormat**: Image file formats (png, jpeg, gif, etc.)
- **ColorMode**: Color modes (grayscale, rgb, rgba, cmyk)
- **ExifOrientation**: EXIF orientation values

### Structures

- **ResizeOptions**: Options for resize operations
- **CropOptions**: Options for crop operations

## Requirements

- D compiler (DMD, LDC, or GDC)
- uim-framework ~>26.1.2
- vibe-d ~>0.10.3
- dlib ~>1.3.2

## License

Apache License 2.0

## Author

Ozan Nurettin Süel (aka UIManufaktur)

Copyright © 2018-2026
