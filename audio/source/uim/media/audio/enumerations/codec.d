/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.audio.enumerations.codec;

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
