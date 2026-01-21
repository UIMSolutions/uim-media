/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module examples.basic_usage;

import uim.media.video;
import std.stdio;

void main() {
    writeln("=== UIM Media Video Library - Basic Usage Examples ===\n");

    // Example 1: Load and inspect a video
    exampleLoadVideo();

    // Example 2: Format-specific operations
    exampleFormatSpecific();

    // Example 3: Codec information
    exampleCodecInfo();

    // Example 4: Metadata handling
    exampleMetadata();

    // Example 5: Stream information
    exampleStreams();

    // Example 6: Video quality checks
    exampleQualityChecks();
}

void exampleLoadVideo() {
    writeln("--- Example 1: Load and Inspect Video ---");
    
    try {
        // Create a video object
        auto video = new Video("/path/to/video.mp4");
        
        writeln("File: ", video.filename);
        writeln("Exists: ", video.exists);
        writeln("Format: ", video.format);
        writeln("Path: ", video.path);
        
        // If you want to actually load the data
        // auto loadedVideo = VideoLoader.load("/path/to/actual/video.mp4");
        // writeln("Resolution: ", loadedVideo.width, "x", loadedVideo.height);
        // writeln("Duration: ", loadedVideo.durationString());
        // writeln("Bitrate: ", loadedVideo.bitrateMbps(), " Mbps");
        // writeln("Frame Rate: ", loadedVideo.frameRate, " fps");
        // writeln("Aspect Ratio: ", loadedVideo.aspectRatio());
        
    } catch (Exception e) {
        writeln("Error: ", e.msg);
    }
    
    writeln();
}

void exampleFormatSpecific() {
    writeln("--- Example 2: Format-Specific Operations ---");
    
    // MP4 example
    auto mp4 = new Mp4Video("movie.mp4");
    writeln("MP4 Format: ", mp4.format);
    
    // AVI example
    auto avi = new AviVideo("video.avi");
    writeln("AVI Format: ", avi.format);
    
    // MKV example
    auto mkv = new MkvVideo("video.mkv");
    writeln("MKV Format: ", mkv.format);
    
    // WebM example
    auto webm = new WebmVideo("video.webm");
    writeln("WebM Format: ", webm.format);
    writeln("WebM Video Codec: ", webm.videoCodec);
    writeln("WebM Audio Codec: ", webm.audioCodec);
    
    writeln();
}

void exampleCodecInfo() {
    writeln("--- Example 3: Codec Information ---");
    
    // Get codec names
    writeln("H.264: ", CodecInfo.getVideoCodecName(VideoCodec.h264));
    writeln("VP9: ", CodecInfo.getVideoCodecName(VideoCodec.vp9));
    writeln("AAC: ", CodecInfo.getAudioCodecName(AudioCodec.aac));
    writeln("Opus: ", CodecInfo.getAudioCodecName(AudioCodec.opus));
    
    // Parse codec from string
    auto vcodec = CodecInfo.parseVideoCodec("x264");
    writeln("Parsed 'x264': ", vcodec);
    
    auto acodec = CodecInfo.parseAudioCodec("aac");
    writeln("Parsed 'aac': ", acodec);
    
    // Check hardware acceleration
    writeln("H.264 HW Accel: ", CodecInfo.supportsHardwareAcceleration(VideoCodec.h264));
    writeln("H.265 HW Accel: ", CodecInfo.supportsHardwareAcceleration(VideoCodec.h265));
    
    // Get recommended codec
    writeln("Recommended for MP4: ", CodecInfo.getRecommendedCodec(VideoFormat.mp4));
    writeln("Recommended for WebM: ", CodecInfo.getRecommendedCodec(VideoFormat.webm));
    
    writeln();
}

void exampleMetadata() {
    writeln("--- Example 4: Metadata Handling ---");
    
    auto metadata = new VideoMetadata();
    
    // Set basic metadata
    metadata.title = "Epic Movie";
    metadata.artist = "Famous Director";
    metadata.genre = "Action";
    metadata.year = 2026;
    metadata.copyright = "© 2026 Big Studio";
    metadata.description = "An action-packed adventure";
    
    // Add tags
    metadata.addTag("action");
    metadata.addTag("adventure");
    metadata.addTag("4k");
    metadata.addTag("hdr");
    
    // Add custom metadata
    metadata.setCustomData("studio", "Big Studio Inc.");
    metadata.setCustomData("budget", "$150M");
    metadata.setCustomData("runtime", "120 minutes");
    
    // Read metadata
    writeln("Title: ", metadata.title);
    writeln("Artist: ", metadata.artist);
    writeln("Genre: ", metadata.genre);
    writeln("Year: ", metadata.year);
    writeln("Tags: ", metadata.tags);
    writeln("Studio: ", metadata.getCustomData("studio"));
    writeln("Budget: ", metadata.getCustomData("budget"));
    
    // Check tag
    writeln("Has '4k' tag: ", metadata.hasTag("4k"));
    
    writeln("\n", metadata.toString());
    
    writeln();
}

void exampleStreams() {
    writeln("--- Example 5: Stream Information ---");
    
    // Video stream
    auto vstream = new VideoStream();
    vstream.index = 0;
    vstream.codec = VideoCodec.h264;
    vstream.width = 1920;
    vstream.height = 1080;
    vstream.frameRate = 30.0;
    vstream.bitrate = 5_000_000;
    vstream.language = "eng";
    vstream.isDefault = true;
    
    writeln("Video: ", vstream.toString());
    
    // Audio stream
    auto astream = new AudioStream();
    astream.index = 1;
    astream.codec = AudioCodec.aac;
    astream.sampleRate = 48000;
    astream.channels = 2;
    astream.bitrate = 192_000;
    astream.language = "eng";
    astream.isDefault = true;
    
    writeln("Audio: ", astream.toString());
    
    // Subtitle stream
    auto sstream = new SubtitleStream();
    sstream.index = 2;
    sstream.format = "srt";
    sstream.language = "eng";
    sstream.isDefault = true;
    sstream.forced = false;
    
    writeln("Subtitle: ", sstream.toString());
    
    writeln();
}

void exampleQualityChecks() {
    writeln("--- Example 6: Video Quality Checks ---");
    
    auto video = new Video();
    
    // Test different resolutions
    video.width = 1920;
    video.height = 1080;
    writeln("1080p - Is HD: ", video.isHD());
    writeln("1080p - Is Full HD: ", video.isFullHD());
    writeln("1080p - Is 4K: ", video.is4K());
    writeln("1080p - Resolution: ", video.resolutionString());
    
    video.width = 3840;
    video.height = 2160;
    writeln("\n4K - Is HD: ", video.isHD());
    writeln("4K - Is Full HD: ", video.isFullHD());
    writeln("4K - Is 4K: ", video.is4K());
    writeln("4K - Resolution: ", video.resolutionString());
    writeln("4K - Aspect Ratio: ", video.aspectRatio());
    
    writeln();
}
