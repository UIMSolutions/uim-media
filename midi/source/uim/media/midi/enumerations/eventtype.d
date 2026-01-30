/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.midi.enumerations.eventtype;

import uim.media.midi;
@safe:

/**
 * MIDI event types
 */
enum MIDIEventType : ubyte {
    // Channel voice messages
    noteOff = 0x80,
    noteOn = 0x90,
    polyKeyPressure = 0xA0,
    controlChange = 0xB0,
    programChange = 0xC0,
    channelPressure = 0xD0,
    pitchBend = 0xE0,
    
    // System common messages
    sysEx = 0xF0,
    timeCodeQuarterFrame = 0xF1,
    songPositionPointer = 0xF2,
    songSelect = 0xF3,
    tuneRequest = 0xF6,
    endOfSysEx = 0xF7,
    
    // System real-time messages
    timingClock = 0xF8,
    start = 0xFA,
    continue_ = 0xFB,
    stop = 0xFC,
    activeSensing = 0xFE,
    systemReset = 0xFF,
    
    // Meta event
    meta = 0xFF
}
