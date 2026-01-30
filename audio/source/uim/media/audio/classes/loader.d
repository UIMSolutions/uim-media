module uim.media.audio.classes.loader;

import uim.media.audio;
@safe:

/**
 * Audio loader factory
 */
class AudioLoader {
    /**
     * Load an audio file
     */
    static Audio load(string filepath) @trusted {
        enforce(exists(filepath), new AudioException("File not found: " ~ filepath));

        auto audio = createAudioFromPath(filepath);
        audio.path = filepath;

        try {
            // Read file data (for header parsing and ID3 tags)
            // For large audio files, we read first chunk for header + last chunk for ID3v1
            size_t headerSize = 65536; // 64KB should be enough for headers
            size_t fileSize = getSize(filepath);

            auto file = File(filepath, "rb");

            // Read header
            size_t readSize = fileSize < headerSize ? fileSize : headerSize;
            ubyte[] headerData = new ubyte[readSize];
            headerData = file.rawRead(headerData);

            // Try to read header based on format
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
                    logWarn("Unsupported audio format for header reading: %s", audio.format);
            }

            // For MP3, try to read ID3v1 tag from end of file
            if (audio.format == AudioFormat.mp3 && fileSize >= 128) {
                file.seek(fileSize - 128);
                ubyte[] id3Data = new ubyte[128];
                id3Data = file.rawRead(id3Data);

                auto metadata = new AudioMetadata();
                if (ID3Tags.parseID3v1(id3Data, metadata)) {
                    // Store metadata in custom data for now
                    // In a full implementation, you'd have a metadata field in Audio class
                    logInfo("ID3v1 tag found: %s - %s", metadata.artist, metadata.title);
                }
            }

            file.close();

            if (!success && audio.format != AudioFormat.unknown) {
                logWarn("Failed to read audio header: %s", filepath);
            }

        } catch (Exception e) {
            throw new AudioException("Failed to load audio: " ~ e.msg);
        }

        return audio;
    }

    /**
     * Create appropriate audio object based on file extension
     */
    private static Audio createAudioFromPath(string filepath) {
        Audio audio = new Audio();
        auto format = audio.detectFormat(filepath);

        switch (format) {
            case AudioFormat.mp3:
                return new Mp3Audio(filepath);
            case AudioFormat.wav:
                return new WavAudio(filepath);
            case AudioFormat.flac:
                return new FlacAudio(filepath);
            case AudioFormat.ogg:
                return new OggAudio(filepath);
            default:
                auto genericAudio = new Audio(filepath);
                genericAudio.format = format;
                return genericAudio;
        }
    }

    /**
     * Get audio info without loading full file
     */
    static Audio probe(string filepath) @trusted {
        return load(filepath);
    }
}