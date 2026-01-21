/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module tests.video_test;

import uim.media.video;
import std.stdio;
import core.time;

unittest {
    writeln("Running video library tests...");

    // Test 1: Video format detection
    {
        auto video = new Video("test.mp4");
        assert(video.detectFormat("test.mp4") == VideoFormat.mp4);
        assert(video.detectFormat("movie.avi") == VideoFormat.avi);
        assert(video.detectFormat("video.mkv") == VideoFormat.mkv);
        assert(video.detectFormat("clip.webm") == VideoFormat.webm);
        assert(video.detectFormat("video.mov") == VideoFormat.mov);
        assert(video.detectFormat("file.flv") == VideoFormat.flv);
        assert(video.detectFormat("movie.m4v") == VideoFormat.m4v);
        assert(video.detectFormat("video.mpeg") == VideoFormat.mpeg);
        assert(video.detectFormat("unknown.xyz") == VideoFormat.unknown);
        writeln("✓ Video format detection tests passed");
    }

    // Test 2: Video properties
    {
        auto video = new Video("/path/to/video.mp4");
        assert(video.path == "/path/to/video.mp4");
        assert(video.filename == "video.mp4");
        assert(video.format == VideoFormat.mp4);
        assert(!video.loaded);
        assert(video.hasVideo);
        writeln("✓ Video properties tests passed");
    }

    // Test 3: Aspect ratio and resolution
    {
        auto video = new Video();
        video.width = 1920;
        video.height = 1080;
        assert(video.aspectRatio > 1.777 && video.aspectRatio < 1.778);
        assert(video.isFullHD());
        assert(video.isHD());
        assert(!video.is4K());
        
        video.width = 3840;
        video.height = 2160;
        assert(video.is4K());
        assert(video.resolutionString() == "4K");
        
        writeln("✓ Aspect ratio and resolution tests passed");
    }

    // Test 4: Duration calculations
    {
        auto video = new Video();
        video.duration = dur!"seconds"(3665); // 1h 1m 5s
        
        assert(video.durationSeconds() > 3664 && video.durationSeconds() < 3666);
        assert(video.durationString() == "01:01:05");
        
        writeln("✓ Duration calculation tests passed");
    }

    // Test 5: Bitrate conversions
    {
        auto video = new Video();
        video.bitrate = 5_000_000; // 5 Mbps
        
        assert(video.bitrateKbps() == 5000.0);
        assert(video.bitrateMbps() == 5.0);
        
        writeln("✓ Bitrate conversion tests passed");
    }

    // Test 6: Codec information
    {
        assert(CodecInfo.getVideoCodecName(VideoCodec.h264) == "H.264/AVC");
        assert(CodecInfo.getVideoCodecName(VideoCodec.h265) == "H.265/HEVC");
        assert(CodecInfo.getAudioCodecName(AudioCodec.aac) == "AAC");
        assert(CodecInfo.getAudioCodecName(AudioCodec.mp3) == "MP3");
        
        assert(CodecInfo.parseVideoCodec("h264") == VideoCodec.h264);
        assert(CodecInfo.parseVideoCodec("x265") == VideoCodec.h265);
        assert(CodecInfo.parseAudioCodec("aac") == AudioCodec.aac);
        
        assert(CodecInfo.supportsHardwareAcceleration(VideoCodec.h264));
        assert(CodecInfo.supportsHardwareAcceleration(VideoCodec.h265));
        assert(!CodecInfo.supportsHardwareAcceleration(VideoCodec.xvid));
        
        assert(CodecInfo.getRecommendedCodec(VideoFormat.mp4) == VideoCodec.h264);
        assert(CodecInfo.getRecommendedCodec(VideoFormat.webm) == VideoCodec.vp9);
        
        writeln("✓ Codec information tests passed");
    }

    // Test 7: Metadata
    {
        auto metadata = new VideoMetadata();
        metadata.title = "Test Video";
        metadata.artist = "Test Artist";
        metadata.genre = "Action";
        metadata.year = 2026;
        
        assert(metadata.title == "Test Video");
        assert(metadata.artist == "Test Artist");
        assert(metadata.year == 2026);
        
        // Test tags
        metadata.addTag("action");
        metadata.addTag("4k");
        assert(metadata.hasTag("action"));
        assert(metadata.hasTag("4k"));
        assert(!metadata.hasTag("comedy"));
        
        metadata.removeTag("action");
        assert(!metadata.hasTag("action"));
        
        // Test custom data
        metadata.setCustomData("studio", "Big Studio");
        assert(metadata.getCustomData("studio") == "Big Studio");
        assert(metadata.getCustomData("nonexistent") == "");
        
        writeln("✓ Metadata tests passed");
    }

    // Test 8: Format-specific classes
    {
        auto mp4 = new Mp4Video("test.mp4");
        assert(mp4.format == VideoFormat.mp4);
        
        auto avi = new AviVideo("test.avi");
        assert(avi.format == VideoFormat.avi);
        
        auto mkv = new MkvVideo("test.mkv");
        assert(mkv.format == VideoFormat.mkv);
        
        auto webm = new WebmVideo("test.webm");
        assert(webm.format == VideoFormat.webm);
        assert(webm.videoCodec == VideoCodec.vp8);
        assert(webm.audioCodec == AudioCodec.vorbis);
        
        writeln("✓ Format-specific class tests passed");
    }

    // Test 9: Stream information
    {
        auto vstream = new VideoStream();
        vstream.index = 0;
        vstream.codec = VideoCodec.h264;
        vstream.width = 1920;
        vstream.height = 1080;
        vstream.frameRate = 30.0;
        vstream.language = "eng";
        
        assert(vstream.index == 0);
        assert(vstream.codec == VideoCodec.h264);
        assert(vstream.width == 1920);
        
        auto astream = new AudioStream();
        astream.index = 1;
        astream.codec = AudioCodec.aac;
        astream.sampleRate = 48000;
        astream.channels = 2;
        
        assert(astream.sampleRate == 48000);
        assert(astream.channels == 2);
        
        auto sstream = new SubtitleStream();
        sstream.index = 2;
        sstream.format = "srt";
        sstream.language = "eng";
        
        assert(sstream.format == "srt");
        assert(sstream.language == "eng");
        
        writeln("✓ Stream information tests passed");
    }

    writeln("\n✅ All tests passed!");
}

void main() {
    writeln("=== UIM Media Video Library - Unit Tests ===\n");
}
