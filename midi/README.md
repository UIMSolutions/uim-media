# UIM Media - MIDI Library

A comprehensive D language library for working with MIDI files.

## Features

- **MIDI File I/O**: Read and write MIDI files (Format 0, 1, and 2)
- **Event Handling**: Support for all MIDI event types
  - Note On/Off events
  - Control Change events
  - Program Change events
  - Pitch Bend events
  - System Exclusive (SysEx) events
  - Meta events (tempo, time signature, key signature, etc.)
- **Track Management**: Multi-track MIDI file support
- **Timing**: Accurate timing with ticks per quarter note (TPPQN)
- **Metadata**: Extract and modify MIDI metadata (title, copyright, tempo, etc.)

## Installation

Add to your `dub.sdl`:
```sdl
dependency "uim-media-midi" version="~>1.0.0"
```

Or to your `dub.json`:
```json
"dependencies": {
    "uim-media-midi": "~>1.0.0"
}
```

## Quick Start

```d
import uim.media.midi;

// Read a MIDI file
auto midiFile = MIDIFile.fromFile("song.mid");

// Access tracks
foreach (track; midiFile.tracks) {
    writeln("Track has ", track.events.length, " events");
}

// Get tempo
auto tempo = midiFile.tempo;
writeln("Tempo: ", tempo, " BPM");

// Create a new MIDI file
auto newMidi = new MIDIFile();
newMidi.format = MIDIFormat.format1;
newMidi.division = 480; // ticks per quarter note

// Add a track
auto track = new MIDITrack();
track.addEvent(new NoteOnEvent(0, 0, 60, 100)); // Middle C
track.addEvent(new NoteOffEvent(480, 0, 60, 0));
newMidi.addTrack(track);

// Write to file
newMidi.saveToFile("output.mid");
```

## Documentation

See the examples directory for more usage examples.

## License

Apache 2.0 - Copyright © 2018-2026 Ozan Nurettin Süel
