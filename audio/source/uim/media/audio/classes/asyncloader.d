module uim.media.audio.classes.asyncloader;

import uim.media.audio;
@safe:

/**
 * Async audio loader using vibe.d
 */
class AsyncAudioLoader {
    /**
     * Load audio asynchronously
     */
    static Audio load(string filepath) @trusted {
        enforce(existsFile(filepath), new AudioException("File not found: " ~ filepath));

        auto audio = AudioLoader.createAudioFromPath(filepath);
        audio.path = filepath;

        try {
            // Read header using vibe.d async operations
            auto file = openFile(filepath);
            scope(exit) file.close();

            size_t headerSize = 65536;
            size_t readSize = file.size < headerSize ? cast(size_t)file.size : headerSize;
            
            auto headerData = new ubyte[readSize];
            file.read(headerData);

            // Process header
            bool success = false;
            switch (audio.format) {
                case AudioFormat.mp3:
                    auto mp3Audio = cast(Mp3Audio)audio;
                    if (mp3Audio) success = mp3Audio.readHeader(headerData);
                    break;
                case AudioFormat.wav:
                    auto wavAudio = cast(WavAudio)audio;
                    if (wavAudio) success = wavAudio.readHeader(headerData);
                    break;
                case AudioFormat.flac:
                    auto flacAudio = cast(FlacAudio)audio;
                    if (flacAudio) success = flacAudio.readHeader(headerData);
                    break;
                case AudioFormat.ogg:
                    auto oggAudio = cast(OggAudio)audio;
                    if (oggAudio) success = oggAudio.readHeader(headerData);
                    break;
                default:
                    break;
            }

        } catch (Exception e) {
            throw new AudioException("Failed to load audio: " ~ e.msg);
        }

        return audio;
    }

    /**
     * Probe audio asynchronously
     */
    static Audio probe(string filepath) @trusted {
        return load(filepath);
    }
}
