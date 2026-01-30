/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.midi.enumerations.format;

import uim.media.midi;
@safe:

/**
 * MIDI file format types
 */
enum MIDIFormat {
    format0 = 0,  /// Single multi-channel track
    format1 = 1,  /// Multiple simultaneous tracks
    format2 = 2   /// Multiple independent tracks
}
