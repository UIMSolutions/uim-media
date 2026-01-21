/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module tests.audio_test;

import uim.media.audio;
import std.stdio;
import core.time;

unittest {
    writeln("Running audio library tests...");

    // Test 1: Audio format detection
    {
        auto audio = new Audio("test.mp3");
        assert(audio.detectFormat("test.mp3") == AudioFormat.mp3);
        assert(audio.detectFormat("song.wav") == AudioFormat.wav);
        assert(audio.detectFormat("music.flac") == AudioFormat.flac);
        assert(audio.detectFormat("track.ogg") == AudioFormat.ogg);
        assert(audio.detectFormat("audio.m4a") == AudioFormat.m4a);
        assert(audio.detectFormat("sound.aiff") == AudioFormat.aiff);
        assert(audio.detectFormat("unknown.xyz") == AudioFormat.unknown);
        writeln("✓ Audio format detection tests passed");
    }

    // Test 2: Audio properties
    {
        auto audio = new Audio("/path/to/song.mp3");
        assert(audio.path == "/path/to/song.mp3");
        assert(audio.filename == "song.mp3");
        assert(audio.format == AudioFormat.mp3);
        assert(!audio.loaded);
        writeln("✓ Audio properties tests passed");
    }

    // Test 3: Duration calculations
    {
        auto audio = new Audio();
        audio.duration = dur!"seconds"(245); // 4m 5s
        
        assert(audio.durationSeconds() > 244 && audio.durationSeconds() < 246);
        assert(audio.durationString() == "04:05");
        assert(audio.durationMinutes() > 4.08 && audio.durationMinutes() < 4.09);
        
        writeln("✓ Duration calculation tests passed");
    }

    // Test 4: Bitrate conversions
    {
        auto audio = new Audio();
        audio.bitrate = 320_000; // 320 kbps
        
        assert(audio.bitrateKbps() == 320.0);
        
        writeln("✓ Bitrate conversion tests passed");
    }

    // Test 5: Quality detection
    {
        auto audio = new Audio();
        
        // Test high quality MP3
        audio.format = AudioFormat.mp3;
        audio.bitrate = 320_000;
        assert(audio.isHighQuality());
        assert(!audio.isLossless());
        
        // Test lossless FLAC
        audio.format = AudioFormat.flac;
        audio.bitrate = 1000_000;
        assert(audio.isHighQuality());
        assert(audio.isLossless());
        
        // Test low quality
        audio.format = AudioFormat.mp3;
        audio.bitrate = 128_000;
        assert(!audio.isHighQuality());
        
        writeln("✓ Quality detection tests passed");
    }

    // Test 6: Channel detection
    {
        auto audio = new Audio();
        
        audio.channels = 1;
        audio.channelConfig = ChannelConfig.mono;
        assert(audio.isMono());
        assert(!audio.isStereo());
        
        audio.channels = 2;
        audio.channelConfig = ChannelConfig.stereo;
        assert(audio.isStereo());
        assert(!audio.isMono());
        
        writeln("✓ Channel detection tests passed");
    }

    // Test 7: Sample rate
    {
        auto audio = new Audio();
        audio.sampleRate = 44100;
        assert(audio.sampleRateKHz() == 44.1);
        
        audio.sampleRate = 48000;
        assert(audio.sampleRateKHz() == 48.0);
        
        writeln("✓ Sample rate tests passed");
    }

    // Test 8: Codec information
    {
        assert(AudioCodecInfo.getCodecName(AudioCodec.mp3) == "MP3");
        assert(AudioCodecInfo.getCodecName(AudioCodec.flac) == "FLAC");
        assert(AudioCodecInfo.getCodecName(AudioCodec.aac) == "AAC");
        
        assert(AudioCodecInfo.parseCodec("mp3") == AudioCodec.mp3);
        assert(AudioCodecInfo.parseCodec("flac") == AudioCodec.flac);
        assert(AudioCodecInfo.parseCodec("vorbis") == AudioCodec.vorbis);
        
        assert(AudioCodecInfo.isLossless(AudioCodec.flac));
        assert(!AudioCodecInfo.isLossless(AudioCodec.mp3));
        
        assert(AudioCodecInfo.supportsStreaming(AudioCodec.mp3));
        assert(AudioCodecInfo.supportsStreaming(AudioCodec.opus));
        
        assert(AudioCodecInfo.getRecommendedCodec(AudioFormat.mp3) == AudioCodec.mp3);
        assert(AudioCodecInfo.getRecommendedCodec(AudioFormat.flac) == AudioCodec.flac);
        
        writeln("✓ Codec information tests passed");
    }

    // Test 9: Metadata
    {
        auto metadata = new AudioMetadata();
        metadata.title = "Test Song";
        metadata.artist = "Test Artist";
        metadata.album = "Test Album";
        metadata.year = 2026;
        metadata.track = 5;
        metadata.trackTotal = 12;
        metadata.disc = 1;
        metadata.discTotal = 2;
        metadata.bpm = 120;
        
        assert(metadata.title == "Test Song");
        assert(metadata.artist == "Test Artist");
        assert(metadata.year == 2026);
        assert(metadata.trackString() == "5/12");
        assert(metadata.discString() == "1/2");
        assert(metadata.bpm == 120);
        
        // Test custom data
        metadata.setCustomData("label", "Test Label");
        assert(metadata.getCustomData("label") == "Test Label");
        assert(metadata.getCustomData("nonexistent") == "");
        
        writeln("✓ Metadata tests passed");
    }

    // Test 10: ID3 tags
    {
        assert(ID3Tags.getGenreByIndex(0) == "Blues");
        assert(ID3Tags.getGenreByIndex(17) == "Rock");
        assert(ID3Tags.getGenreByIndex(8) == "Jazz");
        
        assert(ID3Tags.getGenreIndex("Rock") == 17);
        assert(ID3Tags.getGenreIndex("Jazz") == 8);
        assert(ID3Tags.getGenreIndex("Unknown") == -1);
        
        writeln("✓ ID3 tag tests passed");
    }

    // Test 11: Format-specific classes
    {
        auto mp3 = new Mp3Audio("test.mp3");
        assert(mp3.format == AudioFormat.mp3);
        assert(mp3.codec == AudioCodec.mp3);
        
        auto wav = new WavAudio("test.wav");
        assert(wav.format == AudioFormat.wav);
        assert(wav.codec == AudioCodec.pcm);
        
        auto flac = new FlacAudio("test.flac");
        assert(flac.format == AudioFormat.flac);
        assert(flac.codec == AudioCodec.flac);
        
        auto ogg = new OggAudio("test.ogg");
        assert(ogg.format == AudioFormat.ogg);
        assert(ogg.codec == AudioCodec.vorbis);
        
        writeln("✓ Format-specific class tests passed");
    }

    writeln("\n✅ All tests passed!");
}

void main() {
    writeln("=== UIM Media Audio Library - Unit Tests ===\n");
}
