# UIM Media - Video Library

A comprehensive D language library for working with video files, built with uim-framework and vibe.d.

## Features

- **Multiple Format Support**: MP4, AVI, MKV, WebM, MOV, FLV, WMV, MPEG, and more
- **Video/Audio Codec Detection**: H.264, H.265, VP8, VP9, AV1, AAC, MP3, Opus, etc.
- **Metadata Handling**: Read and manipulate video metadata, tags, and custom fields
- **Stream Information**: Access video, audio, and subtitle stream details
- **Async I/O**: Asynchronous file operations using vibe.d
- **Type-Safe**: Strongly typed enumerations for formats, codecs, and quality settings
- **Framework Integration**: Seamless integration with uim-framework

## Installation

Add to your `dub.sdl`:

```sdl
dependency "uim-media-video" version="~>1.0.0"
```

## Usage

### Basic Video Loading

```d
import uim.media.video;

// Load a video
auto video = VideoLoader.load("movie.mp4");
writeln("Resolution: ", video.width, "x", video.height);
writeln("Duration: ", video.durationString());
writeln("Format: ", video.format);
writeln("Codec: ", video.videoCodec);
writeln("Bitrate: ", video.bitrateMbps(), " Mbps");
writeln("Frame Rate: ", video.frameRate, " fps");
writeln("Quality: ", video.resolutionString());
```

### Async Loading with vibe.d

```d
import uim.media.video;

// Load asynchronously
auto video = AsyncVideoLoader.load("video.mkv");
writeln("Loaded: ", video.filename);
writeln("File size: ", video.fileSize / (1024 * 1024), " MB");
```

### Format-Specific Operations

```d
import uim.media.video;

// Work with MP4
auto mp4 = new Mp4Video("movie.mp4");
writeln("Brand: ", mp4.brand);

// Work with AVI
auto avi = new AviVideo("video.avi");
writeln("Total frames: ", avi.totalFrames);

// Work with MKV
auto mkv = new MkvVideo("video.mkv");
writeln("Doc type: ", mkv.docType);

// Work with WebM
auto webm = new WebmVideo("video.webm");
writeln("Codec: ", webm.videoCodec); // Typically VP8/VP9
```

### Video Quality Checks

```d
import uim.media.video;

auto video = VideoLoader.load("video.mp4");

writeln("Is HD: ", video.isHD());
writeln("Is Full HD: ", video.isFullHD());
writeln("Is 4K: ", video.is4K());
writeln("Aspect Ratio: ", video.aspectRatio());
writeln("Has Audio: ", video.hasAudio);
```

### Codec Information

```d
import uim.media.video;

// Get codec names
writeln(CodecInfo.getVideoCodecName(VideoCodec.h264));  // "H.264/AVC"
writeln(CodecInfo.getAudioCodecName(AudioCodec.aac));   // "AAC"

// Parse codec from string
auto vcodec = CodecInfo.parseVideoCodec("x264");
auto acodec = CodecInfo.parseAudioCodec("mp3");

// Check hardware acceleration support
bool hwAccel = CodecInfo.supportsHardwareAcceleration(VideoCodec.h265);

// Get recommended codec for format
auto recommendedCodec = CodecInfo.getRecommendedCodec(VideoFormat.mp4);
```

### Metadata Management

```d
import uim.media.video;

auto metadata = new VideoMetadata();
metadata.title = "My Movie";
metadata.artist = "Director Name";
metadata.genre = "Action";
metadata.year = 2026;
metadata.copyright = "© 2026";
metadata.description = "An epic action movie";

// Add tags
metadata.addTag("action");
metadata.addTag("adventure");
metadata.addTag("4k");

// Custom metadata
metadata.setCustomData("studio", "Big Studio");
metadata.setCustomData("budget", "$100M");

writeln("Title: ", metadata.title);
writeln("Genre: ", metadata.genre);
writeln("Tags: ", metadata.tags);
writeln("Studio: ", metadata.getCustomData("studio"));
```

### Stream Information

```d
import uim.media.video;

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

// Audio stream
auto astream = new AudioStream();
astream.index = 1;
astream.codec = AudioCodec.aac;
astream.sampleRate = 48000;
astream.channels = 2;
astream.bitrate = 192_000;
astream.language = "eng";

// Subtitle stream
auto sstream = new SubtitleStream();
sstream.index = 2;
sstream.format = "srt";
sstream.language = "eng";
sstream.isDefault = true;
sstream.forced = false;

writeln(vstream.toString());
writeln(astream.toString());
writeln(sstream.toString());
```

### Probe Video Information

```d
import uim.media.video;

// Quick probe without loading full file
auto video = VideoLoader.probe("large_video.mp4");
writeln("Duration: ", video.durationString());
writeln("Size: ", video.fileSize / (1024 * 1024), " MB");
writeln("Resolution: ", video.resolutionString());
```

## API Overview

### Classes

- **Video**: Base video class with common properties
- **Mp4Video**: MP4/M4V-specific functionality
- **AviVideo**: AVI-specific functionality
- **MkvVideo**: Matroska (MKV)-specific functionality
- **WebmVideo**: WebM-specific functionality
- **VideoLoader**: Synchronous video I/O operations
- **AsyncVideoLoader**: Asynchronous video I/O using vibe.d
- **VideoMetadata**: Video metadata container with tags
- **CodecInfo**: Codec information and utilities
- **VideoStream**: Video stream information
- **AudioStream**: Audio stream information
- **SubtitleStream**: Subtitle stream information

### Enumerations

- **VideoFormat**: Video file formats (mp4, avi, mkv, webm, etc.)
- **VideoCodec**: Video codecs (h264, h265, vp8, vp9, av1, etc.)
- **AudioCodec**: Audio codecs (aac, mp3, opus, vorbis, etc.)
- **VideoQuality**: Quality presets (low, medium, high, veryhigh, lossless)
- **StreamType**: Stream types (video, audio, subtitle, data)

## Requirements

- D compiler (DMD, LDC, or GDC)
- uim-framework ~>26.1.2
- vibe-d ~>0.10.3

## License

Apache License 2.0

## Author

Ozan Nurettin Süel (aka UIManufaktur)

Copyright © 2018-2026
