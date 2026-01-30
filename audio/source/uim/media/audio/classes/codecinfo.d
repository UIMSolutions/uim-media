module uim.media.audio.classes.codecinfo;

import uim.media.audio;
@safe:

/**
 * Audio codec information and utilities
 */
class AudioCodecInfo {
    /**
     * Get codec name as string
     */
    static string getCodecName(AudioCodec codec) pure {
        final switch (codec) {
            case AudioCodec.unknown: return "Unknown";
            case AudioCodec.mp3: return "MP3";
            case AudioCodec.aac: return "AAC";
            case AudioCodec.vorbis: return "Vorbis";
            case AudioCodec.opus: return "Opus";
            case AudioCodec.flac: return "FLAC";
            case AudioCodec.alac: return "ALAC";
            case AudioCodec.pcm: return "PCM";
            case AudioCodec.wma: return "WMA";
            case AudioCodec.ape: return "APE";
            case AudioCodec.ac3: return "AC-3";
            case AudioCodec.dts: return "DTS";
            case AudioCodec.amr: return "AMR";
        }
    }

    /**
     * Parse codec from string
     */
    static AudioCodec parseCodec(string codecString) {
        string lower = codecString.toLower.strip;

        if (lower.canFind("mp3") || lower.canFind("mpeg")) {
            return AudioCodec.mp3;
        } else if (lower.canFind("aac")) {
            return AudioCodec.aac;
        } else if (lower.canFind("vorbis")) {
            return AudioCodec.vorbis;
        } else if (lower.canFind("opus")) {
            return AudioCodec.opus;
        } else if (lower.canFind("flac")) {
            return AudioCodec.flac;
        } else if (lower.canFind("alac")) {
            return AudioCodec.alac;
        } else if (lower.canFind("pcm") || lower.canFind("wav")) {
            return AudioCodec.pcm;
        } else if (lower.canFind("wma")) {
            return AudioCodec.wma;
        } else if (lower.canFind("ape")) {
            return AudioCodec.ape;
        } else if (lower.canFind("ac3")) {
            return AudioCodec.ac3;
        } else if (lower.canFind("dts")) {
            return AudioCodec.dts;
        } else if (lower.canFind("amr")) {
            return AudioCodec.amr;
        }

        return AudioCodec.unknown;
    }

    /**
     * Check if codec is lossless
     */
    static bool isLossless(AudioCodec codec) pure {
        return codec == AudioCodec.flac || 
               codec == AudioCodec.alac || 
               codec == AudioCodec.ape ||
               codec == AudioCodec.pcm;
    }

    /**
     * Check if codec supports streaming
     */
    static bool supportsStreaming(AudioCodec codec) pure {
        return codec == AudioCodec.mp3 || 
               codec == AudioCodec.aac || 
               codec == AudioCodec.opus ||
               codec == AudioCodec.vorbis;
    }

    /**
     * Get recommended codec for format
     */
    static AudioCodec getRecommendedCodec(AudioFormat format) pure {
        final switch (format) {
            case AudioFormat.unknown: return AudioCodec.unknown;
            case AudioFormat.mp3: return AudioCodec.mp3;
            case AudioFormat.wav: return AudioCodec.pcm;
            case AudioFormat.flac: return AudioCodec.flac;
            case AudioFormat.ogg: return AudioCodec.vorbis;
            case AudioFormat.aac: return AudioCodec.aac;
            case AudioFormat.m4a: return AudioCodec.aac;
            case AudioFormat.wma: return AudioCodec.wma;
            case AudioFormat.opus: return AudioCodec.opus;
            case AudioFormat.ape: return AudioCodec.ape;
            case AudioFormat.alac: return AudioCodec.alac;
            case AudioFormat.aiff: return AudioCodec.pcm;
            case AudioFormat.au: return AudioCodec.pcm;
            case AudioFormat.mid: return AudioCodec.unknown;
            case AudioFormat.midi: return AudioCodec.unknown;
        }
    }

    /**
     * Get typical bitrate range for codec in kbps
     */
    static uint[2] getTypicalBitrateRange(AudioCodec codec) pure {
        final switch (codec) {
            case AudioCodec.unknown: return [0, 0];
            case AudioCodec.mp3: return [128, 320];
            case AudioCodec.aac: return [96, 256];
            case AudioCodec.vorbis: return [96, 320];
            case AudioCodec.opus: return [64, 510];
            case AudioCodec.flac: return [400, 1400];
            case AudioCodec.alac: return [400, 1400];
            case AudioCodec.pcm: return [1411, 2822];
            case AudioCodec.wma: return [128, 320];
            case AudioCodec.ape: return [400, 1200];
            case AudioCodec.ac3: return [192, 640];
            case AudioCodec.dts: return [754, 1536];
            case AudioCodec.amr: return [5, 13];
        }
    }
}