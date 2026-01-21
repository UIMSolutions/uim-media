/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.image.operations;

import uim.media.image.base;
import std.algorithm;
import std.math;
import vibe.core.log;

@safe:

/**
 * Image operations and transformations
 */
class ImageOperations {
    /**
     * Calculate new dimensions for resize operation maintaining aspect ratio
     */
    static void calculateResizeDimensions(
        size_t originalWidth, size_t originalHeight,
        size_t targetWidth, size_t targetHeight,
        bool maintainAspectRatio,
        out size_t newWidth, out size_t newHeight
    ) {
        if (!maintainAspectRatio) {
            newWidth = targetWidth;
            newHeight = targetHeight;
            return;
        }

        double aspectRatio = cast(double)originalWidth / cast(double)originalHeight;

        if (targetWidth > 0 && targetHeight == 0) {
            // Only width specified
            newWidth = targetWidth;
            newHeight = cast(size_t)(targetWidth / aspectRatio);
        } else if (targetHeight > 0 && targetWidth == 0) {
            // Only height specified
            newHeight = targetHeight;
            newWidth = cast(size_t)(targetHeight * aspectRatio);
        } else {
            // Both specified - fit within bounds
            double targetAspect = cast(double)targetWidth / cast(double)targetHeight;
            
            if (aspectRatio > targetAspect) {
                // Width is limiting factor
                newWidth = targetWidth;
                newHeight = cast(size_t)(targetWidth / aspectRatio);
            } else {
                // Height is limiting factor
                newHeight = targetHeight;
                newWidth = cast(size_t)(targetHeight * aspectRatio);
            }
        }
    }

    /**
     * Calculate crop dimensions
     */
    static void calculateCropDimensions(
        size_t originalWidth, size_t originalHeight,
        size_t cropWidth, size_t cropHeight,
        string position,
        out size_t x, out size_t y
    ) {
        x = 0;
        y = 0;

        if (cropWidth >= originalWidth && cropHeight >= originalHeight) {
            return;
        }

        switch (position.toLower) {
            case "center":
                x = (originalWidth - cropWidth) / 2;
                y = (originalHeight - cropHeight) / 2;
                break;
            case "top":
                x = (originalWidth - cropWidth) / 2;
                y = 0;
                break;
            case "bottom":
                x = (originalWidth - cropWidth) / 2;
                y = originalHeight - cropHeight;
                break;
            case "left":
                x = 0;
                y = (originalHeight - cropHeight) / 2;
                break;
            case "right":
                x = originalWidth - cropWidth;
                y = (originalHeight - cropHeight) / 2;
                break;
            case "topleft":
                x = 0;
                y = 0;
                break;
            case "topright":
                x = originalWidth - cropWidth;
                y = 0;
                break;
            case "bottomleft":
                x = 0;
                y = originalHeight - cropHeight;
                break;
            case "bottomright":
                x = originalWidth - cropWidth;
                y = originalHeight - cropHeight;
                break;
            default:
                // Center by default
                x = (originalWidth - cropWidth) / 2;
                y = (originalHeight - cropHeight) / 2;
        }

        // Ensure crop doesn't exceed boundaries
        x = min(x, originalWidth - cropWidth);
        y = min(y, originalHeight - cropHeight);
    }

    /**
     * Check if image needs orientation correction based on EXIF
     */
    static bool needsRotation(int orientation) pure nothrow {
        return orientation > 1 && orientation <= 8;
    }

    /**
     * Get rotation angle from EXIF orientation
     */
    static int getRotationAngle(int orientation) pure nothrow {
        switch (orientation) {
            case 3: return 180;
            case 6: return 90;
            case 8: return 270;
            default: return 0;
        }
    }
}

/**
 * Image resize options
 */
struct ResizeOptions {
    size_t width = 0;
    size_t height = 0;
    bool maintainAspectRatio = true;
    string filter = "lanczos";
}

/**
 * Image crop options
 */
struct CropOptions {
    size_t width;
    size_t height;
    size_t x = 0;
    size_t y = 0;
    string position = "center";
}
