/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module examples.basic_usage;

import uim.media.audio;
import std.stdio;

void main() {
    writeln("=== UIM Media Audio Library - Basic Usage Examples ===\n");

    // Example 1: Load and inspect an audio file
    exampleLoadAudio();

    // Example 2: Format-specific operations
    exampleFormatSpecific();

    // Example 3: Codec information
    exampleCodecInfo();

    // Example 4: Metadata handling
    exampleMetadata();

    // Example 5: ID3 tags and genres
    exampleID3Tags();

    // Example 6: Audio quality checks
    exampleQualityChecks();
}

void exampleLoadAudio() {
    writeln("--- Example 1: Load and Inspect Audio ---");
    
    try {
        // Create an audio object
        auto audio = new Audio("/path/to/song.mp3");
        
        writeln("File: ", audio.filename);
        writeln("Exists: ", audio.exists);
        writeln("Format: ", audio.format);
        writeln("Path: ", audio.path);
        
        // If you want to actually load the data
        // auto loadedAudio = AudioLoader.load("/path/to/actual/song.mp3");
        // writeln("Duration: ", loadedAudio.durationString());
        // writeln("Bitrate: ", loadedAudio.bitrateKbps(), " kbps");
        // writeln("Sample Rate: ", loadedAudio.sampleRateKHz(), " kHz");
        // writeln("Channels: ", loadedAudio.channelConfigString());
        
    } catch (Exception e) {
        writeln("Error: ", e.msg);
    }
    
    writeln();
}

void exampleFormatSpecific() {
    writeln("--- Example 2: Format-Specific Operations ---");
    
    // MP3 example
    auto mp3 = new Mp3Audio("song.mp3");
    writeln("MP3 Format: ", mp3.format);
    writeln("MP3 Codec: ", mp3.codec);
    
    // WAV example
    auto wav = new WavAudio("audio.wav");
    writeln("WAV Format: ", wav.format);
    writeln("WAV Codec: ", wav.codec);
    
    // FLAC example
    auto flac = new FlacAudio("music.flac");
    writeln("FLAC Format: ", flac.format);
    writeln("FLAC Codec: ", flac.codec);
    writeln("Is Lossless: ", flac.isLossless());
    
    // OGG example
    auto ogg = new OggAudio("track.ogg");
    writeln("OGG Format: ", ogg.format);
    writeln("OGG Codec: ", ogg.codec);
    
    writeln();
}

void exampleCodecInfo() {
    writeln("--- Example 3: Codec Information ---");
    
    // Get codec names
    writeln("MP3: ", AudioCodecInfo.getCodecName(AudioCodec.mp3));
    writeln("AAC: ", AudioCodecInfo.getCodecName(AudioCodec.aac));
    writeln("FLAC: ", AudioCodecInfo.getCodecName(AudioCodec.flac));
    writeln("Opus: ", AudioCodecInfo.getCodecName(AudioCodec.opus));
    
    // Parse codec from string
    auto codec1 = AudioCodecInfo.parseCodec("mp3");
    writeln("Parsed 'mp3': ", codec1);
    
    auto codec2 = AudioCodecInfo.parseCodec("vorbis");
    writeln("Parsed 'vorbis': ", codec2);
    
    // Check codec properties
    writeln("FLAC is lossless: ", AudioCodecInfo.isLossless(AudioCodec.flac));
    writeln("MP3 supports streaming: ", AudioCodecInfo.supportsStreaming(AudioCodec.mp3));
    
    // Get recommended codec
    writeln("Recommended for MP3: ", AudioCodecInfo.getRecommendedCodec(AudioFormat.mp3));
    writeln("Recommended for OGG: ", AudioCodecInfo.getRecommendedCodec(AudioFormat.ogg));
    
    // Get bitrate range
    auto range = AudioCodecInfo.getTypicalBitrateRange(AudioCodec.mp3);
    writeln("MP3 bitrate range: ", range[0], "-", range[1], " kbps");
    
    writeln();
}

void exampleMetadata() {
    writeln("--- Example 4: Metadata Handling ---");
    
    auto metadata = new AudioMetadata();
    
    // Set basic metadata
    metadata.title = "Amazing Song";
    metadata.artist = "Great Artist";
    metadata.album = "Best Album";
    metadata.albumArtist = "Great Artist";
    metadata.genre = "Rock";
    metadata.year = 2026;
    metadata.track = 3;
    metadata.trackTotal = 10;
    metadata.disc = 1;
    metadata.discTotal = 1;
    metadata.bpm = 120;
    metadata.composer = "Talented Composer";
    metadata.copyright = "© 2026 Great Artist";
    
    // Add custom metadata
    metadata.setCustomData("label", "Big Record Label");
    metadata.setCustomData("producer", "Famous Producer");
    metadata.setCustomData("engineer", "Sound Engineer");
    
    // Read metadata
    writeln("Title: ", metadata.title);
    writeln("Artist: ", metadata.artist);
    writeln("Album: ", metadata.album);
    writeln("Genre: ", metadata.genre);
    writeln("Year: ", metadata.year);
    writeln("Track: ", metadata.trackString());
    writeln("Disc: ", metadata.discString());
    writeln("BPM: ", metadata.bpm);
    writeln("Composer: ", metadata.composer);
    writeln("Label: ", metadata.getCustomData("label"));
    writeln("Producer: ", metadata.getCustomData("producer"));
    
    writeln("\n", metadata.toString());
    
    writeln();
}

void exampleID3Tags() {
    writeln("--- Example 5: ID3 Tags and Genres ---");
    
    // Get genre by index
    writeln("Genre 0: ", ID3Tags.getGenreByIndex(0));    // Blues
    writeln("Genre 17: ", ID3Tags.getGenreByIndex(17));  // Rock
    writeln("Genre 8: ", ID3Tags.getGenreByIndex(8));    // Jazz
    
    // Get genre index
    writeln("\nRock index: ", ID3Tags.getGenreIndex("Rock"));
    writeln("Jazz index: ", ID3Tags.getGenreIndex("Jazz"));
    writeln("Pop index: ", ID3Tags.getGenreIndex("Pop"));
    
    // Show first 20 genres
    writeln("\nFirst 20 ID3v1 Genres:");
    foreach (i; 0 .. 20) {
        writeln("  ", i, ": ", ID3Tags.getGenreByIndex(i));
    }
    
    writeln();
}

void exampleQualityChecks() {
    writeln("--- Example 6: Audio Quality Checks ---");
    
    auto audio = new Audio();
    
    // Test MP3 quality
    audio.format = AudioFormat.mp3;
    audio.codec = AudioCodec.mp3;
    audio.bitrate = 320_000;
    audio.sampleRate = 44100;
    audio.channels = 2;
    audio.bitDepth = 16;
    
    writeln("MP3 320 kbps:");
    writeln("  Bitrate: ", audio.bitrateKbps(), " kbps");
    writeln("  Sample Rate: ", audio.sampleRateKHz(), " kHz");
    writeln("  Channels: ", audio.channelConfigString());
    writeln("  Is High Quality: ", audio.isHighQuality());
    writeln("  Is Lossless: ", audio.isLossless());
    writeln("  Is Stereo: ", audio.isStereo());
    
    // Test FLAC quality
    audio.format = AudioFormat.flac;
    audio.codec = AudioCodec.flac;
    audio.bitrate = 1000_000;
    audio.sampleRate = 96000;
    audio.bitDepth = 24;
    
    writeln("\nFLAC 24-bit/96kHz:");
    writeln("  Bitrate: ", audio.bitrateKbps(), " kbps");
    writeln("  Sample Rate: ", audio.sampleRateKHz(), " kHz");
    writeln("  Bit Depth: ", audio.bitDepth, " bits");
    writeln("  Is High Quality: ", audio.isHighQuality());
    writeln("  Is Lossless: ", audio.isLossless());
    
    writeln();
}
