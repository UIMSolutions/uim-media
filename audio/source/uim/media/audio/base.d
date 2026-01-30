/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.audio.base;

import uim.media.audio;
@safe:

/**
 * Audio codec enumeration
 */
enum AudioCodec {
    unknown,
    mp3,
    aac,
    vorbis,
    opus,
    flac,
    alac,
    pcm,
    wma,
    ape,
    ac3,
    dts,
    amr
}

/**
 * Audio channel configuration
 */
enum ChannelConfig {
    mono,
    stereo,
    surround_5_1,
    surround_7_1,
    custom
}

/**
 * Audio quality preset
 */
enum AudioQuality {
    low,
    medium,
    high,
    veryhigh,
    lossless
}


/**
 * Audio exception class
 */
class AudioException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
