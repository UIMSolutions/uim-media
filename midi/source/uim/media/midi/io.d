/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.midi.io;

import uim.media.midi.base;
import uim.media.midi.events;
import uim.media.midi.tracks;
import uim.media.midi.metadata;
import std.algorithm;
import std.array;
import std.conv;
import std.exception;
import std.file;
import std.stdio;
import std.string;

@safe:

/**
 * Main MIDI file class
 */
class MIDIFile : MIDIData {
    MIDIFormat format;
    ushort division;  /// Ticks per quarter note (if bit 15 is 0)
    MIDITrack[] tracks;
    MIDIMetadata metadata;
    
    this() @safe {
        format = MIDIFormat.format1;
        division = 480;  // Common default
        tracks = [];
        metadata = new MIDIMetadata();
    }
    
    /**
     * Add a track to the MIDI file
     */
    void addTrack(MIDITrack track) @safe {
        enforce(track !is null, "Cannot add null track");
        tracks ~= track;
    }
    
    /**
     * Remove a track from the MIDI file
     */
    void removeTrack(MIDITrack track) @trusted {
        tracks = tracks.filter!(t => t !is track).array;
    }
    
    /**
     * Get number of tracks
     */
    @property size_t trackCount() const @safe {
        return tracks.length;
    }
    
    /**
     * Load MIDI file from disk
     */
    static MIDIFile fromFile(string filename) @trusted {
        auto data = cast(ubyte[])read(filename);
        return fromBytes(data);
    }
    
    /**
     * Parse MIDI file from bytes
     */
    static MIDIFile fromBytes(ubyte[] data) @trusted {
        auto reader = MIDIReader(data);
        return reader.parse();
    }
    
    /**
     * Save MIDI file to disk
     */
    void saveToFile(string filename) @trusted {
        auto data = toBytes();
        write(filename, data);
    }
    
    /**
     * Convert MIDI file to bytes
     */
    ubyte[] toBytes() @trusted {
        auto writer = MIDIWriter();
        return writer.write(this);
    }
    
    /**
     * Get tempo from first track
     */
    double getTempo() @trusted {
        foreach (track; tracks) {
            auto tempoEvents = track.getEvents!TempoEvent();
            if (tempoEvents.length > 0) {
                return tempoEvents[0].bpm;
            }
        }
        return 120.0; // Default tempo
    }
    
    /**
     * Set tempo in first track
     */
    void setTempo(double bpm) @trusted {
        if (tracks.length == 0) {
            addTrack(new MIDITrack());
        }
        
        // Remove existing tempo events from first track
        auto firstTrack = tracks[0];
        firstTrack.events = firstTrack.events.filter!(e => cast(TempoEvent)e is null).array;
        
        // Add new tempo event at the beginning
        auto tempoEvent = new TempoEvent(0, MIDIUtils.tempoToMicroseconds(bpm));
        firstTrack.events = [tempoEvent] ~ firstTrack.events;
    }
    
    override bool validate() @safe {
        // Validate format
        if (format < MIDIFormat.format0 || format > MIDIFormat.format2) {
            return false;
        }
        
        // Format 0 should have only 1 track
        if (format == MIDIFormat.format0 && tracks.length != 1) {
            return false;
        }
        
        // Validate all tracks
        foreach (track; tracks) {
            if (!track.validate()) {
                return false;
            }
        }
        
        return true;
    }
    
    override size_t getSize() const @safe {
        size_t total = 14; // Header chunk size
        foreach (track; tracks) {
            total += 8; // Track chunk header
            total += track.getSize();
        }
        return total;
    }
}

/**
 * MIDI file reader
 */
private struct MIDIReader {
    ubyte[] data;
    size_t position;
    
    this(ubyte[] data) @safe {
        this.data = data;
        this.position = 0;
    }
    
    MIDIFile parse() @trusted {
        auto file = new MIDIFile();
        
        // Read header chunk
        readHeaderChunk(file);
        
        // Read track chunks
        while (position < data.length) {
            readTrackChunk(file);
        }
        
        return file;
    }
    
    private void readHeaderChunk(MIDIFile file) @trusted {
        // Read "MThd"
        enforce(readString(4) == "MThd", "Invalid MIDI file: Missing MThd header");
        
        // Read header length (should be 6)
        auto headerLength = readUInt32();
        enforce(headerLength == 6, "Invalid MIDI file: Header length must be 6");
        
        // Read format
        file.format = cast(MIDIFormat)readUInt16();
        
        // Read track count
        auto trackCount = readUInt16();
        
        // Read division
        file.division = readUInt16();
    }
    
    private void readTrackChunk(MIDIFile file) @trusted {
        // Read "MTrk"
        enforce(readString(4) == "MTrk", "Invalid MIDI file: Missing MTrk header");
        
        // Read track length
        auto trackLength = readUInt32();
        auto trackEnd = position + trackLength;
        
        auto track = new MIDITrack();
        ubyte runningStatus = 0;
        
        // Read events until end of track
        while (position < trackEnd) {
            auto deltaTime = readVariableLength();
            auto event = readEvent(deltaTime, runningStatus);
            
            if (event !is null) {
                track.addEvent(event);
                
                // Update running status
                if (cast(ChannelEvent)event !is null) {
                    runningStatus = cast(ubyte)event.getEventType();
                }
            }
        }
        
        file.addTrack(track);
    }
    
    private MIDIEvent readEvent(uint deltaTime, ref ubyte runningStatus) @trusted {
        auto statusByte = peekByte();
        
        // Check for running status
        if ((statusByte & 0x80) == 0) {
            statusByte = runningStatus;
        } else {
            readByte();
        }
        
        ubyte eventType = cast(ubyte)(statusByte & 0xF0);
        ubyte channel = cast(ubyte)(statusByte & 0x0F);
        
        // Channel events
        if (eventType == MIDIEventType.noteOff) {
            auto note = readByte();
            auto velocity = readByte();
            return new NoteOffEvent(deltaTime, channel, note, velocity);
        }
        else if (eventType == MIDIEventType.noteOn) {
            auto note = readByte();
            auto velocity = readByte();
            // Note: velocity 0 is equivalent to note off
            if (velocity == 0) {
                return new NoteOffEvent(deltaTime, channel, note, 0);
            }
            return new NoteOnEvent(deltaTime, channel, note, velocity);
        }
        else if (eventType == MIDIEventType.controlChange) {
            auto controller = readByte();
            auto value = readByte();
            return new ControlChangeEvent(deltaTime, channel, controller, value);
        }
        else if (eventType == MIDIEventType.programChange) {
            auto program = readByte();
            return new ProgramChangeEvent(deltaTime, channel, program);
        }
        else if (eventType == MIDIEventType.pitchBend) {
            auto lsb = readByte();
            auto msb = readByte();
            ushort value = cast(ushort)((msb << 7) | lsb);
            return new PitchBendEvent(deltaTime, channel, value);
        }
        else if (statusByte == 0xFF) {
            // Meta event
            return readMetaEvent(deltaTime);
        }
        
        // Unknown event, skip it
        return null;
    }
    
    private MIDIEvent readMetaEvent(uint deltaTime) @trusted {
        auto metaType = cast(MIDIMetaEventType)readByte();
        auto length = readVariableLength();
        
        if (metaType == MIDIMetaEventType.tempo) {
            auto b1 = readByte();
            auto b2 = readByte();
            auto b3 = readByte();
            uint microseconds = (b1 << 16) | (b2 << 8) | b3;
            return new TempoEvent(deltaTime, microseconds);
        }
        else if (metaType == MIDIMetaEventType.timeSignature) {
            auto numerator = readByte();
            auto denominator = readByte();
            auto clocksPerClick = readByte();
            auto thirtySeconds = readByte();
            auto ts = TimeSignature(numerator, denominator, clocksPerClick, thirtySeconds);
            return new TimeSignatureEvent(deltaTime, ts);
        }
        else if (metaType == MIDIMetaEventType.keySignature) {
            auto sharpsFlats = cast(byte)readByte();
            auto isMinor = readByte() != 0;
            auto ks = KeySignature(sharpsFlats, isMinor);
            return new KeySignatureEvent(deltaTime, ks);
        }
        else if (metaType == MIDIMetaEventType.endOfTrack) {
            return new EndOfTrackEvent(deltaTime);
        }
        else if (metaType >= MIDIMetaEventType.text && metaType <= MIDIMetaEventType.cuePoint) {
            auto text = readString(length);
            return new TextEvent(deltaTime, text, metaType);
        }
        else {
            // Skip unknown meta event
            position += length;
            return null;
        }
    }
    
    private ubyte readByte() @trusted {
        enforce(position < data.length, "Unexpected end of MIDI file");
        return data[position++];
    }
    
    private ubyte peekByte() @trusted {
        enforce(position < data.length, "Unexpected end of MIDI file");
        return data[position];
    }
    
    private ushort readUInt16() @trusted {
        auto b1 = readByte();
        auto b2 = readByte();
        return cast(ushort)((b1 << 8) | b2);
    }
    
    private uint readUInt32() @trusted {
        auto b1 = readByte();
        auto b2 = readByte();
        auto b3 = readByte();
        auto b4 = readByte();
        return (b1 << 24) | (b2 << 16) | (b3 << 8) | b4;
    }
    
    private uint readVariableLength() @trusted {
        uint value = 0;
        ubyte b;
        
        do {
            b = readByte();
            value = (value << 7) | (b & 0x7F);
        } while ((b & 0x80) != 0);
        
        return value;
    }
    
    private string readString(size_t length) @trusted {
        enforce(position + length <= data.length, "Unexpected end of MIDI file");
        auto str = cast(string)data[position .. position + length];
        position += length;
        return str;
    }
}

/**
 * MIDI file writer
 */
private struct MIDIWriter {
    ubyte[] data;
    
    ubyte[] write(MIDIFile file) @trusted {
        data = [];
        
        // Write header chunk
        writeHeaderChunk(file);
        
        // Write track chunks
        foreach (track; file.tracks) {
            writeTrackChunk(track);
        }
        
        return data;
    }
    
    private void writeHeaderChunk(MIDIFile file) @trusted {
        // Write "MThd"
        writeString("MThd");
        
        // Write header length (6)
        writeUInt32(6);
        
        // Write format
        writeUInt16(cast(ushort)file.format);
        
        // Write track count
        writeUInt16(cast(ushort)file.tracks.length);
        
        // Write division
        writeUInt16(file.division);
    }
    
    private void writeTrackChunk(MIDITrack track) @trusted {
        // Write "MTrk"
        writeString("MTrk");
        
        // Prepare track data
        ubyte[] trackData;
        ubyte lastStatus = 0;
        
        foreach (event; track.events) {
            // Write delta time
            trackData ~= encodeVariableLength(event.deltaTime);
            
            // Write event data
            auto eventBytes = event.toBytes();
            
            // Apply running status (skip status byte if same as previous)
            if (eventBytes.length > 0 && (eventBytes[0] & 0x80) != 0) {
                if (eventBytes[0] == lastStatus && (eventBytes[0] & 0xF0) != 0xF0) {
                    trackData ~= eventBytes[1..$];
                } else {
                    trackData ~= eventBytes;
                    lastStatus = eventBytes[0];
                }
            } else {
                trackData ~= eventBytes;
            }
        }
        
        // Write track length
        writeUInt32(cast(uint)trackData.length);
        
        // Write track data
        data ~= trackData;
    }
    
    private void writeByte(ubyte b) @safe {
        data ~= b;
    }
    
    private void writeUInt16(ushort value) @safe {
        data ~= cast(ubyte)((value >> 8) & 0xFF);
        data ~= cast(ubyte)(value & 0xFF);
    }
    
    private void writeUInt32(uint value) @safe {
        data ~= cast(ubyte)((value >> 24) & 0xFF);
        data ~= cast(ubyte)((value >> 16) & 0xFF);
        data ~= cast(ubyte)((value >> 8) & 0xFF);
        data ~= cast(ubyte)(value & 0xFF);
    }
    
    private void writeString(string s) @safe {
        data ~= cast(ubyte[])s;
    }
    
    private static ubyte[] encodeVariableLength(uint value) @safe {
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
}
