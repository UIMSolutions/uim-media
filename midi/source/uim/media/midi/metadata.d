/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.midi.metadata;

import uim.media.midi.base;
import std.datetime;
import std.conv;

@safe:


/**
 * MIDI statistics
 */
struct MIDIStatistics {
    uint totalNotes;
    uint totalTracks;
    uint totalEvents;
    ubyte minNote = 127;
    ubyte maxNote = 0;
    double averageVelocity = 0.0;
    uint[] notesPerChannel;
    
    this(int dummy) @safe {
        notesPerChannel = new uint[16];
    }
    
    /**
     * Get note range as string
     */
    string getNoteRange() const @safe {
        if (totalNotes == 0) return "No notes";
        return format("%s - %s", MIDIUtils.noteName(minNote), MIDIUtils.noteName(maxNote));
    }
    
    /**
     * Convert statistics to readable string
     */
    string toString() const @safe {
        string result = "MIDI Statistics:\n";
        result ~= format("  Total Tracks: %d\n", totalTracks);
        result ~= format("  Total Events: %d\n", totalEvents);
        result ~= format("  Total Notes: %d\n", totalNotes);
        
        if (totalNotes > 0) {
            result ~= format("  Note Range: %s\n", getNoteRange());
            result ~= format("  Average Velocity: %.1f\n", averageVelocity);
            
            result ~= "  Notes per Channel:\n";
            foreach (i, count; notesPerChannel) {
                if (count > 0) {
                    result ~= format("    Channel %d: %d notes\n", i, count);
                }
            }
        }
        
        return result;
    }
    
    private static string format(Args...)(string fmt, Args args) @trusted {
        import std.format : fmt_format = format;
        return fmt_format(fmt, args);
    }
}
