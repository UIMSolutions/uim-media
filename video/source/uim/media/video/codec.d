/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.video.codec;

import uim.media.video.base;
import std.algorithm;
import std.string;

@safe:

/**
 * Codec information and utilities
 */
class CodecInfo {
    /**
     * Get codec name as string
     */
    static string getVideoCodecName(VideoCodec codec) pure {
        final switch (codec) {
            case VideoCodec.unknown: return "Unknown";
            case VideoCodec.h264: return "H.264/AVC";
            case VideoCodec.h265: return "H.265/HEVC";
            case VideoCodec.vp8: return "VP8";
            case VideoCodec.vp9: return "VP9";
            case VideoCodec.av1: return "AV1";
            case VideoCodec.mpeg4: return "MPEG-4";
            case VideoCodec.mpeg2: return "MPEG-2";
            case VideoCodec.theora: return "Theora";
            case VideoCodec.xvid: return "Xvid";
            case VideoCodec.divx: return "DivX";
        }
    }

    /**
     * Get audio codec name as string
     */
    static string getAudioCodecName(AudioCodec codec) pure {
        final switch (codec) {
            case AudioCodec.unknown: return "Unknown";
            case AudioCodec.aac: return "AAC";
            case AudioCodec.mp3: return "MP3";
            case AudioCodec.opus: return "Opus";
            case AudioCodec.vorbis: return "Vorbis";
            case AudioCodec.flac: return "FLAC";
            case AudioCodec.pcm: return "PCM";
            case AudioCodec.ac3: return "AC-3";
            case AudioCodec.dts: return "DTS";
        }
    }

    /**
     * Parse video codec from string
     */
    static VideoCodec parseVideoCodec(string codecString) {
        string lower = codecString.toLower.strip;
        
        if (lower.canFind("h264") || lower.canFind("avc") || lower.canFind("x264")) {
            return VideoCodec.h264;
        } else if (lower.canFind("h265") || lower.canFind("hevc") || lower.canFind("x265")) {
            return VideoCodec.h265;
        } else if (lower.canFind("vp8")) {
            return VideoCodec.vp8;
        } else if (lower.canFind("vp9")) {
            return VideoCodec.vp9;
        } else if (lower.canFind("av1")) {
            return VideoCodec.av1;
        } else if (lower.canFind("mpeg4")) {
            return VideoCodec.mpeg4;
        } else if (lower.canFind("mpeg2")) {
            return VideoCodec.mpeg2;
        } else if (lower.canFind("theora")) {
            return VideoCodec.theora;
        } else if (lower.canFind("xvid")) {
            return VideoCodec.xvid;
        } else if (lower.canFind("divx")) {
            return VideoCodec.divx;
        }
        
        return VideoCodec.unknown;
    }

    /**
     * Parse audio codec from string
     */
    static AudioCodec parseAudioCodec(string codecString) {
        string lower = codecString.toLower.strip;
        
        if (lower.canFind("aac")) {
            return AudioCodec.aac;
        } else if (lower.canFind("mp3")) {
            return AudioCodec.mp3;
        } else if (lower.canFind("opus")) {
            return AudioCodec.opus;
        } else if (lower.canFind("vorbis")) {
            return AudioCodec.vorbis;
        } else if (lower.canFind("flac")) {
            return AudioCodec.flac;
        } else if (lower.canFind("pcm")) {
            return AudioCodec.pcm;
        } else if (lower.canFind("ac3")) {
            return AudioCodec.ac3;
        } else if (lower.canFind("dts")) {
            return AudioCodec.dts;
        }
        
        return AudioCodec.unknown;
    }

    /**
     * Check if codec supports hardware acceleration
     */
    static bool supportsHardwareAcceleration(VideoCodec codec) pure {
        return codec == VideoCodec.h264 || 
               codec == VideoCodec.h265 || 
               codec == VideoCodec.vp8 || 
               codec == VideoCodec.vp9 ||
               codec == VideoCodec.av1;
    }

    /**
     * Get recommended video codec for format
     */
    static VideoCodec getRecommendedCodec(VideoFormat format) pure {
        final switch (format) {
            case VideoFormat.unknown: return VideoCodec.unknown;
            case VideoFormat.mp4: return VideoCodec.h264;
            case VideoFormat.avi: return VideoCodec.mpeg4;
            case VideoFormat.mov: return VideoCodec.h264;
            case VideoFormat.mkv: return VideoCodec.h264;
            case VideoFormat.webm: return VideoCodec.vp9;
            case VideoFormat.flv: return VideoCodec.h264;
            case VideoFormat.wmv: return VideoCodec.mpeg4;
            case VideoFormat.m4v: return VideoCodec.h264;
            case VideoFormat.mpeg: return VideoCodec.mpeg2;
            case VideoFormat.mpg: return VideoCodec.mpeg2;
            case VideoFormat.ogv: return VideoCodec.theora;
            case VideoFormat._3gp: return VideoCodec.h264;
        }
    }
}
