/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.midi.enumerations.divisiontype;

import uim.media.midi;
@safe:

/**
 * MIDI timing division types
 */
enum TimeDivisionType {
    ticksPerQuarterNote,  /// Metrical timing
    framesPerSecond       /// Time-code-based timing
}
