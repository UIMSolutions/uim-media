/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
import std.stdio;
import std.file;
import uim.media.midi;

void main() {
    writeln("Running MIDI Library Tests...\n");
    
    testBasicCreation();
    testEvents();
    testTracks();
    testFileIO();
    testUtils();
    testMetadata();
    
    writeln("\n✓ All tests passed!");
}

void testBasicCreation() {
    writeln("Test: Basic MIDI file creation");
    
    auto midi = new MIDIFile();
    assert(midi !is null, "MIDI file creation failed");
    assert(midi.trackCount == 0, "New MIDI file should have no tracks");
    assert(midi.format == MIDIFormat.format1, "Default format should be format1");
    assert(midi.division == 480, "Default division should be 480");
    
    writeln("  ✓ Basic creation");
}

void testEvents() {
    writeln("Test: MIDI events");
    
    // Test Note On event
    auto noteOn = new NoteOnEvent(0, 0, 60, 100);
    assert(noteOn.note == 60, "Note should be 60");
    assert(noteOn.velocity == 100, "Velocity should be 100");
    assert(noteOn.channel == 0, "Channel should be 0");
    
    // Test Note Off event
    auto noteOff = new NoteOffEvent(480, 0, 60, 0);
    assert(noteOff.note == 60, "Note should be 60");
    assert(noteOff.deltaTime == 480, "Delta time should be 480");
    
    // Test Control Change event
    auto cc = new ControlChangeEvent(0, 0, 7, 100);
    assert(cc.controller == 7, "Controller should be 7");
    assert(cc.value == 100, "Value should be 100");
    
    // Test Program Change event
    auto pc = new ProgramChangeEvent(0, 0, 0);
    assert(pc.program == 0, "Program should be 0");
    
    // Test Tempo event
    auto tempo = new TempoEvent(0, 500000);
    assert(tempo.microsecondsPerQuarterNote == 500000, "Tempo should be 500000");
    assert(tempo.bpm == 120.0, "BPM should be 120");
    
    writeln("  ✓ Events");
}

void testTracks() {
    writeln("Test: MIDI tracks");
    
    auto track = new MIDITrack();
    assert(track !is null, "Track creation failed");
    assert(track.events.length == 0, "New track should have no events");
    
    // Add events
    track.addEvent(new NoteOnEvent(0, 0, 60, 100));
    track.addEvent(new NoteOffEvent(480, 0, 60, 0));
    assert(track.events.length == 2, "Track should have 2 events");
    
    // Test track duration
    auto duration = track.getDuration();
    assert(duration == 480, "Track duration should be 480");
    
    // Test track name
    track.setName("Test Track");
    assert(track.getName() == "Test Track", "Track name should be 'Test Track'");
    
    // Test transposition
    auto originalNote = (cast(NoteOnEvent)track.events[0]).note;
    track.transpose(12); // Transpose up one octave
    auto newNote = (cast(NoteOnEvent)track.events[0]).note;
    assert(newNote == originalNote + 12, "Note should be transposed");
    
    writeln("  ✓ Tracks");
}

void testFileIO() {
    writeln("Test: File I/O");
    
    // Create a MIDI file
    auto midi = new MIDIFile();
    midi.setTempo(120.0);
    
    auto track = new MIDITrack();
    track.setName("Test Track");
    track.addEvent(new NoteOnEvent(0, 0, 60, 100));
    track.addEvent(new NoteOffEvent(480, 0, 60, 0));
    track.ensureEndOfTrack();
    
    midi.addTrack(track);
    
    // Save to file
    string filename = "test_output.mid";
    midi.saveToFile(filename);
    assert(exists(filename), "MIDI file should be created");
    
    // Read back
    auto loadedMidi = MIDIFile.fromFile(filename);
    assert(loadedMidi !is null, "MIDI file loading failed");
    assert(loadedMidi.trackCount == 1, "Loaded MIDI should have 1 track");
    
    auto loadedTrack = loadedMidi.tracks[0];
    assert(loadedTrack.events.length >= 2, "Loaded track should have at least 2 events");
    
    // Clean up
    remove(filename);
    
    writeln("  ✓ File I/O");
}

void testUtils() {
    writeln("Test: Utility functions");
    
    // Test note to frequency
    auto freq = MIDIUtils.noteToFrequency(69); // A4
    assert(freq > 439 && freq < 441, "A4 should be ~440 Hz");
    
    // Test frequency to note
    auto note = MIDIUtils.frequencyToNote(440.0);
    assert(note == 69, "440 Hz should be note 69 (A4)");
    
    // Test note name
    auto name = MIDIUtils.noteName(60);
    assert(name == "C4", "Note 60 should be C4");
    
    // Test tempo conversion
    auto microseconds = MIDIUtils.tempoToMicroseconds(120.0);
    assert(microseconds == 500000, "120 BPM should be 500000 microseconds");
    
    auto bpm = MIDIUtils.microsecondsToTempo(500000);
    assert(bpm == 120.0, "500000 microseconds should be 120 BPM");
    
    writeln("  ✓ Utils");
}

void testMetadata() {
    writeln("Test: Metadata");
    
    auto metadata = new MIDIMetadata();
    metadata.title = "Test Song";
    metadata.artist = "Test Artist";
    metadata.tempo = 120.0;
    
    assert(metadata.title == "Test Song", "Title should be set");
    assert(metadata.artist == "Test Artist", "Artist should be set");
    assert(metadata.tempo == 120.0, "Tempo should be 120");
    
    // Test time signature
    auto ts = TimeSignature.create(4, 4);
    assert(ts.numerator == 4, "Numerator should be 4");
    assert(ts.denominatorValue == 4, "Denominator should be 4");
    
    // Test key signature
    auto ks = KeySignature.create(0, false);
    assert(ks.sharpsFlats == 0, "Should have no sharps or flats");
    assert(ks.isMinor == false, "Should be major");
    
    writeln("  ✓ Metadata");
}
