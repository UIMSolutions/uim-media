/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.midi.enumerations.metaeventtype;

import uim.media.midi;
@safe:

/**
 * MIDI meta event types
 */
enum MIDIMetaEventType : ubyte {
    sequenceNumber = 0x00,
    text = 0x01,
    copyright = 0x02,
    trackName = 0x03,
    instrumentName = 0x04,
    lyric = 0x05,
    marker = 0x06,
    cuePoint = 0x07,
    channelPrefix = 0x20,
    endOfTrack = 0x2F,
    tempo = 0x51,
    smpteOffset = 0x54,
    timeSignature = 0x58,
    keySignature = 0x59,
    sequencerSpecific = 0x7F
}
