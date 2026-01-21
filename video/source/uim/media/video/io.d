/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.video.io;

import uim.media.video.base;
import uim.media.video.formats;
import std.exception;
import std.file;
import std.path;
import std.string;
import vibe.core.file;
import vibe.core.log;

@safe:

/**
 * Video loader factory
 */
class VideoLoader {
    /**
     * Load a video from file
     */
    static Video load(string filepath) @trusted {
        enforce(exists(filepath), new VideoException("File not found: " ~ filepath));

        auto video = createVideoFromPath(filepath);
        video.path = filepath;

        try {
            // Read file data (for header parsing)
            // For large video files, we only read the first chunk for header info
            size_t headerSize = 65536; // 64KB should be enough for headers
            size_t fileSize = getSize(filepath);
            size_t readSize = fileSize < headerSize ? fileSize : headerSize;
            
            auto file = File(filepath, "rb");
            ubyte[] headerData = new ubyte[readSize];
            headerData = file.rawRead(headerData);
            file.close();

            video.data = headerData; // Store header data only

            // Try to read header based on format
            bool success = false;
            
            switch (video.format) {
                case VideoFormat.mp4:
                case VideoFormat.m4v:
                    auto mp4Video = cast(Mp4Video)video;
                    if (mp4Video) success = mp4Video.readHeader(headerData);
                    break;
                case VideoFormat.avi:
                    auto aviVideo = cast(AviVideo)video;
                    if (aviVideo) success = aviVideo.readHeader(headerData);
                    break;
                case VideoFormat.mkv:
                    auto mkvVideo = cast(MkvVideo)video;
                    if (mkvVideo) success = mkvVideo.readHeader(headerData);
                    break;
                case VideoFormat.webm:
                    auto webmVideo = cast(WebmVideo)video;
                    if (webmVideo) success = webmVideo.readHeader(headerData);
                    break;
                default:
                    logWarn("Unsupported video format for header reading: %s", video.format);
            }

            if (!success && video.format != VideoFormat.unknown) {
                logWarn("Failed to read video header: %s", filepath);
            }

        } catch (Exception e) {
            throw new VideoException("Failed to load video: " ~ e.msg);
        }

        return video;
    }

    /**
     * Create appropriate video object based on file extension
     */
    private static Video createVideoFromPath(string filepath) {
        Video video = new Video();
        auto format = video.detectFormat(filepath);
        
        switch (format) {
            case VideoFormat.mp4:
            case VideoFormat.m4v:
                return new Mp4Video(filepath);
            case VideoFormat.avi:
                return new AviVideo(filepath);
            case VideoFormat.mkv:
                return new MkvVideo(filepath);
            case VideoFormat.webm:
                return new WebmVideo(filepath);
            default:
                auto genericVideo = new Video(filepath);
                genericVideo.format = format;
                return genericVideo;
        }
    }

    /**
     * Get video info without loading full file
     */
    static Video probe(string filepath) @trusted {
        return load(filepath);
    }
}

/**
 * Async video loader using vibe.d
 */
class AsyncVideoLoader {
    /**
     * Load video asynchronously
     */
    static Video load(string filepath) @trusted {
        enforce(existsFile(filepath), new VideoException("File not found: " ~ filepath));

        auto video = VideoLoader.createVideoFromPath(filepath);
        video.path = filepath;

        try {
            // Read header using vibe.d async operations
            auto file = openFile(filepath);
            scope(exit) file.close();

            size_t headerSize = 65536;
            size_t readSize = file.size < headerSize ? cast(size_t)file.size : headerSize;
            
            auto headerData = new ubyte[readSize];
            file.read(headerData);
            video.data = headerData;

            // Process header
            bool success = false;
            switch (video.format) {
                case VideoFormat.mp4:
                case VideoFormat.m4v:
                    auto mp4Video = cast(Mp4Video)video;
                    if (mp4Video) success = mp4Video.readHeader(headerData);
                    break;
                case VideoFormat.avi:
                    auto aviVideo = cast(AviVideo)video;
                    if (aviVideo) success = aviVideo.readHeader(headerData);
                    break;
                case VideoFormat.mkv:
                    auto mkvVideo = cast(MkvVideo)video;
                    if (mkvVideo) success = mkvVideo.readHeader(headerData);
                    break;
                case VideoFormat.webm:
                    auto webmVideo = cast(WebmVideo)video;
                    if (webmVideo) success = webmVideo.readHeader(headerData);
                    break;
                default:
                    break;
            }

        } catch (Exception e) {
            throw new VideoException("Failed to load video: " ~ e.msg);
        }

        return video;
    }

    /**
     * Probe video asynchronously
     */
    static Video probe(string filepath) @trusted {
        return load(filepath);
    }
}
