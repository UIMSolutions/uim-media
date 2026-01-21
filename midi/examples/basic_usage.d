/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
import std.stdio;
import uim.media.midi;

void main() {
    writeln("=== UIM MIDI Library - Basic Usage Examples ===\n");
    
    // Example 1: Create a simple MIDI file
    example1_createSimpleMIDI();
    
    // Example 2: Create a melody
    example2_createMelody();
    
    // Example 3: Multiple tracks
    example3_multipleTracks();
    
    // Example 4: Working with events
    example4_workingWithEvents();
    
    writeln("\nAll examples completed successfully!");
}

/// Create a simple MIDI file with a single note
void example1_createSimpleMIDI() {
    writeln("Example 1: Creating a simple MIDI file");
    writeln("---------------------------------------");
    
    // Create a new MIDI file
    auto midi = new MIDIFile();
    midi.format = MIDIFormat.format1;
    midi.division = 480; // Ticks per quarter note
    
    // Set tempo to 120 BPM
    midi.setTempo(120.0);
    
    // Create a track
    auto track = new MIDITrack();
    track.setName("Piano");
    
    // Add a middle C note (note 60) for one beat
    track.addEvent(new NoteOnEvent(0, 0, 60, 100));    // Channel 0, velocity 100
    track.addEvent(new NoteOffEvent(480, 0, 60, 0));   // After 480 ticks (1 quarter note)
    
    // Add end of track marker
    track.ensureEndOfTrack();
    
    // Add track to MIDI file
    midi.addTrack(track);
    
    // Save to file
    midi.saveToFile("simple.mid");
    writeln("Created: simple.mid");
    writeln("  - 1 track");
    writeln("  - 1 note (Middle C)");
    writeln("  - 120 BPM\n");
}

/// Create a simple melody
void example2_createMelody() {
    writeln("Example 2: Creating a melody");
    writeln("----------------------------");
    
    auto midi = new MIDIFile();
    midi.division = 480;
    midi.setTempo(120.0);
    
    auto track = new MIDITrack();
    track.setName("Melody");
    
    // C major scale: C D E F G A B C
    ubyte[] notes = [60, 62, 64, 65, 67, 69, 71, 72];
    uint deltaTime = 0;
    
    foreach (note; notes) {
        track.addEvent(new NoteOnEvent(deltaTime, 0, note, 100));
        track.addEvent(new NoteOffEvent(240, 0, note, 0));  // Eighth note (half a beat)
        deltaTime = 0;  // No gap between notes
    }
    
    track.ensureEndOfTrack();
    midi.addTrack(track);
    midi.saveToFile("melody.mid");
    
    writeln("Created: melody.mid");
    writeln("  - C major scale");
    writeln("  - 8 notes\n");
}

/// Create a MIDI file with multiple tracks
void example3_multipleTracks() {
    writeln("Example 3: Multiple tracks");
    writeln("--------------------------");
    
    auto midi = new MIDIFile();
    midi.format = MIDIFormat.format1;
    midi.division = 480;
    midi.setTempo(100.0);
    
    // Track 1: Bass line
    auto bassTrack = new MIDITrack();
    bassTrack.setName("Bass");
    bassTrack.addEvent(new ProgramChangeEvent(0, 0, 32)); // Acoustic Bass
    bassTrack.addEvent(new NoteOnEvent(0, 0, 36, 90));    // C2
    bassTrack.addEvent(new NoteOffEvent(960, 0, 36, 0));
    bassTrack.addEvent(new NoteOnEvent(0, 0, 41, 90));    // F2
    bassTrack.addEvent(new NoteOffEvent(960, 0, 41, 0));
    bassTrack.ensureEndOfTrack();
    
    // Track 2: Melody
    auto melodyTrack = new MIDITrack();
    melodyTrack.setName("Melody");
    melodyTrack.addEvent(new ProgramChangeEvent(0, 1, 0)); // Acoustic Grand Piano
    melodyTrack.addEvent(new NoteOnEvent(0, 1, 60, 100));  // C4
    melodyTrack.addEvent(new NoteOffEvent(480, 1, 60, 0));
    melodyTrack.addEvent(new NoteOnEvent(0, 1, 64, 100));  // E4
    melodyTrack.addEvent(new NoteOffEvent(480, 1, 64, 0));
    melodyTrack.addEvent(new NoteOnEvent(0, 1, 67, 100));  // G4
    melodyTrack.addEvent(new NoteOffEvent(960, 1, 67, 0));
    melodyTrack.ensureEndOfTrack();
    
    midi.addTrack(bassTrack);
    midi.addTrack(melodyTrack);
    midi.saveToFile("multitrack.mid");
    
    writeln("Created: multitrack.mid");
    writeln("  - 2 tracks (Bass + Melody)");
    writeln("  - Different instruments");
    writeln("  - 100 BPM\n");
}

/// Demonstrate working with MIDI events
void example4_workingWithEvents() {
    writeln("Example 4: Working with events");
    writeln("-------------------------------");
    
    auto midi = new MIDIFile();
    midi.division = 480;
    
    auto track = new MIDITrack();
    track.setName("Demo Track");
    
    // Add various event types
    track.addEvent(new NoteOnEvent(0, 0, 60, 100));
    track.addEvent(new ControlChangeEvent(240, 0, 
        cast(ubyte)MIDIController.channelVolume, 80));  // Set volume
    track.addEvent(new NoteOffEvent(240, 0, 60, 0));
    
    // Add pitch bend
    track.addEvent(new NoteOnEvent(0, 0, 64, 100));
    track.addEvent(new PitchBendEvent(120, 0, 10000)); // Bend up
    track.addEvent(new PitchBendEvent(120, 0, 8192));  // Center
    track.addEvent(new NoteOffEvent(240, 0, 64, 0));
    
    track.ensureEndOfTrack();
    
    // Get statistics
    writeln("Track statistics:");
    writeln("  - Total events: ", track.events.length);
    writeln("  - Note events: ", track.getNoteEvents().length);
    writeln("  - Duration: ", track.getDuration(), " ticks");
    writeln("  - Track name: ", track.getName());
    
    // Demonstrate utility functions
    writeln("\nUtility functions:");
    writeln("  - Note 60 name: ", MIDIUtils.noteName(60));
    writeln("  - Note 60 frequency: ", MIDIUtils.noteToFrequency(60), " Hz");
    writeln("  - 120 BPM = ", MIDIUtils.tempoToMicroseconds(120.0), " microseconds/quarter");
    
    midi.addTrack(track);
    midi.saveToFile("events_demo.mid");
    writeln("\nCreated: events_demo.mid\n");
}
