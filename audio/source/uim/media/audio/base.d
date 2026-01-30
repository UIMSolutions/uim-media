/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.audio.base;

import uim.media.audio;
@safe:

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


