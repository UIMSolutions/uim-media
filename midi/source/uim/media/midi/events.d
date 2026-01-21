/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.midi.events;

import uim.media.midi.base;
import std.conv;
import std.exception;
import std.algorithm;
import std.array;

@safe:

/**
 * Base class for all MIDI events
 */
abstract class MIDIEvent : MIDIData {
    uint deltaTime;  /// Time delta from previous event in ticks
    
    this(uint deltaTime = 0) @safe {
        this.deltaTime = deltaTime;
    }
    
    /// Get the event type
    abstract MIDIEventType getEventType() const @safe;
    
    /// Serialize event to bytes
    abstract ubyte[] toBytes() const @safe;
    
    override bool validate() @safe {
        return true;
    }
}

/**
 * Base class for channel events
 */
abstract class ChannelEvent : MIDIEvent {
    ubyte channel;  /// MIDI channel (0-15)
    
    this(uint deltaTime, ubyte channel) @safe {
        enforce(channel < 16, "MIDI channel must be 0-15");
        super(deltaTime);
        this.channel = channel;
    }
}

/**
 * Note On event
 */
class NoteOnEvent : ChannelEvent {
    ubyte note;      /// MIDI note number (0-127)
    ubyte velocity;  /// Note velocity (0-127)
    
    this(uint deltaTime, ubyte channel, ubyte note, ubyte velocity) @safe {
        enforce(note < 128, "MIDI note must be 0-127");
        enforce(velocity < 128, "MIDI velocity must be 0-127");
        super(deltaTime, channel);
        this.note = note;
        this.velocity = velocity;
    }
    
    override MIDIEventType getEventType() const @safe {
        return MIDIEventType.noteOn;
    }
    
    override ubyte[] toBytes() const @safe {
        return [cast(ubyte)(0x90 | channel), note, velocity];
    }
    
    override size_t getSize() const @safe {
        return 3;
    }
}

/**
 * Note Off event
 */
class NoteOffEvent : ChannelEvent {
    ubyte note;      /// MIDI note number (0-127)
    ubyte velocity;  /// Note off velocity (0-127)
    
    this(uint deltaTime, ubyte channel, ubyte note, ubyte velocity = 64) @safe {
        enforce(note < 128, "MIDI note must be 0-127");
        enforce(velocity < 128, "MIDI velocity must be 0-127");
        super(deltaTime, channel);
        this.note = note;
        this.velocity = velocity;
    }
    
    override MIDIEventType getEventType() const @safe {
        return MIDIEventType.noteOff;
    }
    
    override ubyte[] toBytes() const @safe {
        return [cast(ubyte)(0x80 | channel), note, velocity];
    }
    
    override size_t getSize() const @safe {
        return 3;
    }
}

/**
 * Control Change event
 */
class ControlChangeEvent : ChannelEvent {
    ubyte controller;  /// Controller number (0-127)
    ubyte value;       /// Controller value (0-127)
    
    this(uint deltaTime, ubyte channel, ubyte controller, ubyte value) @safe {
        enforce(controller < 128, "MIDI controller must be 0-127");
        enforce(value < 128, "MIDI value must be 0-127");
        super(deltaTime, channel);
        this.controller = controller;
        this.value = value;
    }
    
    override MIDIEventType getEventType() const @safe {
        return MIDIEventType.controlChange;
    }
    
    override ubyte[] toBytes() const @safe {
        return [cast(ubyte)(0xB0 | channel), controller, value];
    }
    
    override size_t getSize() const @safe {
        return 3;
    }
}

/**
 * Program Change event
 */
class ProgramChangeEvent : ChannelEvent {
    ubyte program;  /// Program number (0-127)
    
    this(uint deltaTime, ubyte channel, ubyte program) @safe {
        enforce(program < 128, "MIDI program must be 0-127");
        super(deltaTime, channel);
        this.program = program;
    }
    
    override MIDIEventType getEventType() const @safe {
        return MIDIEventType.programChange;
    }
    
    override ubyte[] toBytes() const @safe {
        return [cast(ubyte)(0xC0 | channel), program];
    }
    
    override size_t getSize() const @safe {
        return 2;
    }
}

/**
 * Pitch Bend event
 */
class PitchBendEvent : ChannelEvent {
    ushort value;  /// Pitch bend value (0-16383, 8192 = center)
    
    this(uint deltaTime, ubyte channel, ushort value) @safe {
        enforce(value <= 16383, "MIDI pitch bend must be 0-16383");
        super(deltaTime, channel);
        this.value = value;
    }
    
    override MIDIEventType getEventType() const @safe {
        return MIDIEventType.pitchBend;
    }
    
    override ubyte[] toBytes() const @safe {
        ubyte lsb = cast(ubyte)(value & 0x7F);
        ubyte msb = cast(ubyte)((value >> 7) & 0x7F);
        return [cast(ubyte)(0xE0 | channel), lsb, msb];
    }
    
    override size_t getSize() const @safe {
        return 3;
    }
}

/**
 * Channel Pressure (Aftertouch) event
 */
class ChannelPressureEvent : ChannelEvent {
    ubyte pressure;  /// Pressure value (0-127)
    
    this(uint deltaTime, ubyte channel, ubyte pressure) @safe {
        enforce(pressure < 128, "MIDI pressure must be 0-127");
        super(deltaTime, channel);
        this.pressure = pressure;
    }
    
    override MIDIEventType getEventType() const @safe {
        return MIDIEventType.channelPressure;
    }
    
    override ubyte[] toBytes() const @safe {
        return [cast(ubyte)(0xD0 | channel), pressure];
    }
    
    override size_t getSize() const @safe {
        return 2;
    }
}

/**
 * Polyphonic Key Pressure event
 */
class PolyKeyPressureEvent : ChannelEvent {
    ubyte note;      /// MIDI note number (0-127)
    ubyte pressure;  /// Pressure value (0-127)
    
    this(uint deltaTime, ubyte channel, ubyte note, ubyte pressure) @safe {
        enforce(note < 128, "MIDI note must be 0-127");
        enforce(pressure < 128, "MIDI pressure must be 0-127");
        super(deltaTime, channel);
        this.note = note;
        this.pressure = pressure;
    }
    
    override MIDIEventType getEventType() const @safe {
        return MIDIEventType.polyKeyPressure;
    }
    
    override ubyte[] toBytes() const @safe {
        return [cast(ubyte)(0xA0 | channel), note, pressure];
    }
    
    override size_t getSize() const @safe {
        return 3;
    }
}

/**
 * Base class for Meta events
 */
abstract class MetaEvent : MIDIEvent {
    this(uint deltaTime) @safe {
        super(deltaTime);
    }
    
    override MIDIEventType getEventType() const @safe {
        return MIDIEventType.meta;
    }
    
    /// Get the meta event type
    abstract MIDIMetaEventType getMetaType() const @safe;
}

/**
 * Tempo Meta event
 */
class TempoEvent : MetaEvent {
    uint microsecondsPerQuarterNote;  /// Tempo in microseconds per quarter note
    
    this(uint deltaTime, uint microsecondsPerQuarterNote) @safe {
        super(deltaTime);
        this.microsecondsPerQuarterNote = microsecondsPerQuarterNote;
    }
    
    /// Get tempo in BPM
    @property double bpm() const @safe {
        return MIDIUtils.microsecondsToTempo(microsecondsPerQuarterNote);
    }
    
    /// Set tempo in BPM
    @property void bpm(double value) @safe {
        microsecondsPerQuarterNote = MIDIUtils.tempoToMicroseconds(value);
    }
    
    override MIDIMetaEventType getMetaType() const @safe {
        return MIDIMetaEventType.tempo;
    }
    
    override ubyte[] toBytes() const @safe {
        ubyte[] result = [0xFF, 0x51, 0x03];
        result ~= cast(ubyte)((microsecondsPerQuarterNote >> 16) & 0xFF);
        result ~= cast(ubyte)((microsecondsPerQuarterNote >> 8) & 0xFF);
        result ~= cast(ubyte)(microsecondsPerQuarterNote & 0xFF);
        return result;
    }
    
    override size_t getSize() const @safe {
        return 6;
    }
}

/**
 * Time Signature Meta event
 */
class TimeSignatureEvent : MetaEvent {
    TimeSignature timeSignature;
    
    this(uint deltaTime, TimeSignature ts) @safe {
        super(deltaTime);
        this.timeSignature = ts;
    }
    
    override MIDIMetaEventType getMetaType() const @safe {
        return MIDIMetaEventType.timeSignature;
    }
    
    override ubyte[] toBytes() const @safe {
        return [
            0xFF, 0x58, 0x04,
            timeSignature.numerator,
            timeSignature.denominator,
            timeSignature.clocksPerClick,
            timeSignature.thirtySecondNotesPerQuarter
        ];
    }
    
    override size_t getSize() const @safe {
        return 7;
    }
}

/**
 * Key Signature Meta event
 */
class KeySignatureEvent : MetaEvent {
    KeySignature keySignature;
    
    this(uint deltaTime, KeySignature ks) @safe {
        super(deltaTime);
        this.keySignature = ks;
    }
    
    override MIDIMetaEventType getMetaType() const @safe {
        return MIDIMetaEventType.keySignature;
    }
    
    override ubyte[] toBytes() const @safe {
        return [
            0xFF, 0x59, 0x02,
            cast(ubyte)keySignature.sharpsFlats,
            cast(ubyte)(keySignature.isMinor ? 1 : 0)
        ];
    }
    
    override size_t getSize() const @safe {
        return 5;
    }
}

/**
 * Text Meta event
 */
class TextEvent : MetaEvent {
    string text;
    MIDIMetaEventType textType;
    
    this(uint deltaTime, string text, MIDIMetaEventType textType = MIDIMetaEventType.text) @safe {
        super(deltaTime);
        this.text = text;
        this.textType = textType;
    }
    
    override MIDIMetaEventType getMetaType() const @safe {
        return textType;
    }
    
    override ubyte[] toBytes() const @safe {
        ubyte[] result = [0xFF, cast(ubyte)textType];
        ubyte[] textBytes = cast(ubyte[])text.dup;
        result ~= encodeVariableLength(textBytes.length);
        result ~= textBytes;
        return result;
    }
    
    override size_t getSize() const @safe {
        return 2 + variableLengthSize(text.length) + text.length;
    }
    
    private static ubyte[] encodeVariableLength(size_t value) @trusted {
        ubyte[] result;
        ubyte[] buffer;
        
        buffer ~= cast(ubyte)(value & 0x7F);
        value >>= 7;
        
        while (value > 0) {
            buffer ~= cast(ubyte)((value & 0x7F) | 0x80);
            value >>= 7;
        }
        
        foreach_reverse (b; buffer) {
            result ~= b;
        }
        
        return result;
    }
    
    private static size_t variableLengthSize(size_t value) @safe {
        size_t size = 1;
        value >>= 7;
        while (value > 0) {
            size++;
            value >>= 7;
        }
        return size;
    }
}

/**
 * Track Name Meta event
 */
class TrackNameEvent : TextEvent {
    this(uint deltaTime, string name) @safe {
        super(deltaTime, name, MIDIMetaEventType.trackName);
    }
}

/**
 * Copyright Meta event
 */
class CopyrightEvent : TextEvent {
    this(uint deltaTime, string copyright) @safe {
        super(deltaTime, copyright, MIDIMetaEventType.copyright);
    }
}

/**
 * End of Track Meta event
 */
class EndOfTrackEvent : MetaEvent {
    this(uint deltaTime = 0) @safe {
        super(deltaTime);
    }
    
    override MIDIMetaEventType getMetaType() const @safe {
        return MIDIMetaEventType.endOfTrack;
    }
    
    override ubyte[] toBytes() const @safe {
        return [0xFF, 0x2F, 0x00];
    }
    
    override size_t getSize() const @safe {
        return 3;
    }
}

/**
 * System Exclusive (SysEx) event
 */
class SysExEvent : MIDIEvent {
    ubyte[] data;
    
    this(uint deltaTime, ubyte[] data) @safe {
        super(deltaTime);
        this.data = data.dup;
    }
    
    override MIDIEventType getEventType() const @safe {
        return MIDIEventType.sysEx;
    }
    
    override ubyte[] toBytes() const @safe {
        ubyte[] result = [0xF0];
        result ~= TextEvent.encodeVariableLength(data.length);
        result ~= data;
        return result;
    }
    
    override size_t getSize() const @safe {
        return 1 + TextEvent.variableLengthSize(data.length) + data.length;
    }
}
