# UIM Media - Audio Library

A comprehensive D language library for working with audio files, built with uim-framework and vibe.d.

## Features

- **Multiple Format Support**: MP3, WAV, FLAC, OGG Vorbis, AAC, M4A, WMA, Opus, APE, AIFF, and more
- **Audio Codec Detection**: MP3, AAC, Vorbis, Opus, FLAC, ALAC, PCM, WMA, etc.
- **Metadata Handling**: ID3 tags, album art, artist, album, track info, lyrics
- **Quality Detection**: Bitrate analysis, lossless format detection
- **Async I/O**: Asynchronous file operations using vibe.d
- **Type-Safe**: Strongly typed enumerations for formats, codecs, and channel configurations
- **Framework Integration**: Seamless integration with uim-framework

## Installation

Add to your `dub.sdl`:

```sdl
dependency "uim-media-audio" version="~>1.0.0"
```

## Usage

### Basic Audio Loading

```d
import uim.media.audio;

// Load an audio file
auto audio = AudioLoader.load("song.mp3");
writeln("Title: ", audio.filename);
writeln("Format: ", audio.format);
writeln("Codec: ", audio.codec);
writeln("Duration: ", audio.durationString());
writeln("Bitrate: ", audio.bitrateKbps(), " kbps");
writeln("Sample Rate: ", audio.sampleRateKHz(), " kHz");
writeln("Channels: ", audio.channelConfigString());
writeln("Is Lossless: ", audio.isLossless());
writeln("Is High Quality: ", audio.isHighQuality());
```

### Async Loading with vibe.d

```d
import uim.media.audio;

// Load asynchronously
auto audio = AsyncAudioLoader.load("track.flac");
writeln("Loaded: ", audio.filename);
writeln("File size: ", audio.fileSize / (1024 * 1024), " MB");
```

### Format-Specific Operations

```d
import uim.media.audio;

// Work with MP3
auto mp3 = new Mp3Audio("song.mp3");
writeln("MPEG Version: ", mp3.mpegVersion);
writeln("Layer: ", mp3.layer);

// Work with WAV
auto wav = new WavAudio("audio.wav");
writeln("Audio Format: ", wav.audioFormat);
writeln("Byte Rate: ", wav.byteRate);

// Work with FLAC
auto flac = new FlacAudio("music.flac");
writeln("Total Samples: ", flac.totalSamples);
writeln("Duration: ", flac.durationString());

// Work with OGG
auto ogg = new OggAudio("track.ogg");
writeln("Bitrate Nominal: ", ogg.bitrateNominal);
writeln("VBR: ", ogg.vbr);
```

### Audio Quality Checks

```d
import uim.media.audio;

auto audio = AudioLoader.load("song.mp3");

writeln("Format: ", audio.format);
writeln("Sample Rate: ", audio.sampleRate, " Hz");
writeln("Bit Depth: ", audio.bitDepth, " bits");
writeln("Channels: ", audio.channels);
writeln("Is Stereo: ", audio.isStereo());
writeln("Is Mono: ", audio.isMono());
writeln("Is Lossless: ", audio.isLossless());
writeln("Is High Quality: ", audio.isHighQuality());
writeln("VBR: ", audio.vbr);
```

### Codec Information

```d
import uim.media.audio;

// Get codec names
writeln(AudioCodecInfo.getCodecName(AudioCodec.mp3));     // "MP3"
writeln(AudioCodecInfo.getCodecName(AudioCodec.flac));    // "FLAC"

// Parse codec from string
auto codec = AudioCodecInfo.parseCodec("aac");
writeln("Parsed: ", codec);

// Check codec properties
writeln("Is Lossless: ", AudioCodecInfo.isLossless(AudioCodec.flac));
writeln("Supports Streaming: ", AudioCodecInfo.supportsStreaming(AudioCodec.opus));

// Get recommended codec for format
auto recommendedCodec = AudioCodecInfo.getRecommendedCodec(AudioFormat.mp3);
writeln("Recommended: ", AudioCodecInfo.getCodecName(recommendedCodec));

// Get typical bitrate range
auto range = AudioCodecInfo.getTypicalBitrateRange(AudioCodec.mp3);
writeln("MP3 bitrate range: ", range[0], "-", range[1], " kbps");
```

### Metadata Handling

```d
import uim.media.audio;

auto metadata = new AudioMetadata();

// Set basic metadata
metadata.title = "Epic Song";
metadata.artist = "Famous Band";
metadata.album = "Greatest Hits";
metadata.albumArtist = "Famous Band";
metadata.genre = "Rock";
metadata.year = 2026;
metadata.track = 5;
metadata.trackTotal = 12;
metadata.disc = 1;
metadata.discTotal = 2;
metadata.bpm = 120;
metadata.copyright = "© 2026";

// Add custom metadata
metadata.setCustomData("label", "Big Record Label");
metadata.setCustomData("producer", "Famous Producer");

// Read metadata
writeln("Title: ", metadata.title);
writeln("Artist: ", metadata.artist);
writeln("Album: ", metadata.album);
writeln("Track: ", metadata.trackString());  // "5/12"
writeln("Disc: ", metadata.discString());    // "1/2"
writeln("BPM: ", metadata.bpm);
writeln("Label: ", metadata.getCustomData("label"));

writeln("\n", metadata.toString());
```

### ID3 Tags

```d
import uim.media.audio;

// Get genre by index
writeln(ID3Tags.getGenreByIndex(17));  // "Rock"

// Get genre index
int idx = ID3Tags.getGenreIndex("Jazz");
writeln("Jazz index: ", idx);

// All available genres
foreach (i, genre; ID3Tags.genres[0 .. 10]) {
    writeln(i, ": ", genre);
}
```

### Probe Audio Information

```d
import uim.media.audio;

// Quick probe without loading full file
auto audio = AudioLoader.probe("large_file.flac");
writeln("Duration: ", audio.durationMinutes(), " minutes");
writeln("Size: ", audio.fileSize / (1024 * 1024), " MB");
writeln("Quality: ", audio.isLossless() ? "Lossless" : "Lossy");
```

## API Overview

### Classes

- **Audio**: Base audio class with common properties
- **Mp3Audio**: MP3-specific functionality with MPEG layer support
- **WavAudio**: WAV-specific functionality with PCM support
- **FlacAudio**: FLAC-specific functionality with lossless encoding
- **OggAudio**: OGG Vorbis-specific functionality with VBR detection
- **AudioLoader**: Synchronous audio I/O operations
- **AsyncAudioLoader**: Asynchronous audio I/O using vibe.d
- **AudioMetadata**: Audio metadata container with ID3-like structure
- **AudioCodecInfo**: Codec information and utilities
- **ID3Tags**: ID3 tag parsing and genre utilities

### Enumerations

- **AudioFormat**: Audio file formats (mp3, wav, flac, ogg, etc.)
- **AudioCodec**: Audio codecs (mp3, aac, vorbis, opus, flac, etc.)
- **ChannelConfig**: Channel configurations (mono, stereo, 5.1, 7.1)
- **AudioQuality**: Quality presets (low, medium, high, veryhigh, lossless)
- **ID3Version**: ID3 tag versions (v1, v1.1, v2.2, v2.3, v2.4)

### Key Features

- **Lossless Detection**: Automatically identifies FLAC, ALAC, APE, WAV, AIFF
- **Quality Analysis**: Bitrate checking, high-quality detection (≥320 kbps)
- **Duration Formatting**: Automatic conversion to seconds, minutes, MM:SS format
- **Channel Detection**: Mono, stereo, surround sound identification
- **VBR Support**: Variable bitrate detection for compatible formats
- **ID3v1 Parsing**: Basic ID3v1 tag reading for MP3 files

## Requirements

- D compiler (DMD, LDC, or GDC)
- uim-framework ~>26.1.2
- vibe-d ~>0.10.3

## License

Apache License 2.0

## Author

Ozan Nurettin Süel (aka UIManufaktur)

Copyright © 2018-2026
