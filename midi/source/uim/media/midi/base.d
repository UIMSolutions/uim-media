/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.midi.base;

import uim.media.midi;
@safe:

/**
 * MIDI controller numbers
 */
enum MIDIController : ubyte {
    bankSelectMSB = 0,
    modulationWheel = 1,
    breathController = 2,
    footController = 4,
    portamentoTime = 5,
    dataEntryMSB = 6,
    channelVolume = 7,
    balance = 8,
    pan = 10,
    expressionController = 11,
    effectControl1 = 12,
    effectControl2 = 13,
    generalPurpose1 = 16,
    generalPurpose2 = 17,
    generalPurpose3 = 18,
    generalPurpose4 = 19,
    bankSelectLSB = 32,
    modulationWheelLSB = 33,
    sustainPedal = 64,
    portamento = 65,
    sostenuto = 66,
    softPedal = 67,
    legatoFootswitch = 68,
    hold2 = 69,
    soundController1 = 70,
    soundController2 = 71,
    soundController3 = 72,
    soundController4 = 73,
    soundController5 = 74,
    soundController6 = 75,
    soundController7 = 76,
    soundController8 = 77,
    soundController9 = 78,
    soundController10 = 79,
    generalPurpose5 = 80,
    generalPurpose6 = 81,
    generalPurpose7 = 82,
    generalPurpose8 = 83,
    portamentoControl = 84,
    effects1Depth = 91,
    effects2Depth = 92,
    effects3Depth = 93,
    effects4Depth = 94,
    effects5Depth = 95,
    dataIncrement = 96,
    dataDecrement = 97,
    nrpnLSB = 98,
    nrpnMSB = 99,
    rpnLSB = 100,
    rpnMSB = 101,
    allSoundOff = 120,
    resetAllControllers = 121,
    localControl = 122,
    allNotesOff = 123,
    omniModeOff = 124,
    omniModeOn = 125,
    monoModeOn = 126,
    polyModeOn = 127
}

/**
 * MIDI time signature structure
 */
struct TimeSignature {
    ubyte numerator;      /// Beats per measure
    ubyte denominator;    /// Note value (2 = quarter note, 3 = eighth note, etc.)
    ubyte clocksPerClick; /// MIDI clocks per metronome click
    ubyte thirtySecondNotesPerQuarter; /// Number of 32nd notes per quarter note (usually 8)
    
    /// Create standard time signature
    static TimeSignature create(ubyte numerator, ubyte denominator) @safe {
        import std.math : log2;
        TimeSignature ts;
        ts.numerator = numerator;
        ts.denominator = cast(ubyte)log2(denominator);
        ts.clocksPerClick = 24;
        ts.thirtySecondNotesPerQuarter = 8;
        return ts;
    }
    
    /// Get denominator as note value
    @property uint denominatorValue() const @safe {
        return 1 << denominator;
    }
}

/**
 * MIDI key signature structure
 */
struct KeySignature {
    byte sharpsFlats;  /// -7 to 7 (negative = flats, positive = sharps)
    bool isMinor;      /// true = minor, false = major
    
    /// Create key signature
    static KeySignature create(byte sharpsFlats, bool isMinor) @safe {
        KeySignature ks;
        ks.sharpsFlats = sharpsFlats;
        ks.isMinor = isMinor;
        return ks;
    }
}

/**
 * Base class for MIDI data
 */
abstract class MIDIData {
    /// Validate MIDI data structure
    abstract bool validate() @safe;
    
    /// Get data size in bytes
    abstract size_t getSize() const @safe;
}


/**
 * Utility functions for MIDI
 */
struct MIDIUtils {
    /**
     * Convert MIDI note number to frequency in Hz
     */
    static double noteToFrequency(ubyte note) @safe {
        import std.math : pow;
        return 440.0 * pow(2.0, (note - 69) / 12.0);
    }
    
    /**
     * Convert frequency to MIDI note number
     */
    static ubyte frequencyToNote(double frequency) @safe {
        import std.math : log2, round;
        return cast(ubyte)(round(69 + 12 * log2(frequency / 440.0)));
    }
    
    /**
     * Get note name from MIDI note number
     */
    static string noteName(ubyte note) @safe {
        immutable string[] noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"];
        int octave = (note / 12) - 1;
        int noteIndex = note % 12;
        return noteNames[noteIndex] ~ to!string(octave);
    }
    
    /**
     * Convert microseconds per quarter note to BPM
     */
    static double microsecondsToTempo(uint microseconds) @safe {
        return 60_000_000.0 / microseconds;
    }
    
    /**
     * Convert BPM to microseconds per quarter note
     */
    static uint tempoToMicroseconds(double bpm) @safe {
        return cast(uint)(60_000_000.0 / bpm);
    }
}
