/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.midi.classes.tracks;

import uim.media.midi;

@safe:

/**
 * MIDI track containing a sequence of events
 */
class MIDITrack : MIDIData {
    MIDIEvent[] events;
    
    this() @safe {
        events = [];
    }
    
    /**
     * Add an event to the track
     */
    void addEvent(MIDIEvent event) @safe {
        enforce(event !is null, "Cannot add null event");
        events ~= event;
    }
    
    /**
     * Add multiple events to the track
     */
    void addEvents(MIDIEvent[] newEvents) @safe {
        foreach (event; newEvents) {
            addEvent(event);
        }
    }
    
    /**
     * Remove an event from the track
     */
    void removeEvent(MIDIEvent event) @trusted {
        events = events.filter!(e => e !is event).array;
    }
    
    /**
     * Clear all events from the track
     */
    void clear() @safe {
        events = [];
    }
    
    /**
     * Get events of a specific type
     */
    T[] getEvents(T : MIDIEvent)() @trusted {
        T[] result;
        foreach (event; events) {
            auto typedEvent = cast(T)event;
            if (typedEvent !is null) {
                result ~= typedEvent;
            }
        }
        return result;
    }
    
    /**
     * Get all note events (on and off)
     */
    MIDIEvent[] getNoteEvents() @trusted {
        return events.filter!(e => 
            cast(NoteOnEvent)e !is null || cast(NoteOffEvent)e !is null
        ).array;
    }
    
    /**
     * Get track duration in ticks
     */
    uint getDuration() @safe {
        if (events.length == 0) return 0;
        
        uint totalTicks = 0;
        foreach (event; events) {
            totalTicks += event.deltaTime;
        }
        return totalTicks;
    }
    
    /**
     * Sort events by their absolute time
     */
    void sortEvents() @trusted {
        // Calculate absolute times
        struct EventWithTime {
            MIDIEvent event;
            uint absoluteTime;
        }
        
        EventWithTime[] eventsWithTime;
        uint currentTime = 0;
        
        foreach (event; events) {
            currentTime += event.deltaTime;
            eventsWithTime ~= EventWithTime(event, currentTime);
        }
        
        // Sort by absolute time
        eventsWithTime.sort!((a, b) => a.absoluteTime < b.absoluteTime);
        
        // Recalculate delta times
        events = [];
        uint prevTime = 0;
        foreach (ewt; eventsWithTime) {
            ewt.event.deltaTime = ewt.absoluteTime - prevTime;
            events ~= ewt.event;
            prevTime = ewt.absoluteTime;
        }
    }
    
    /**
     * Get track name if available
     */
    string getName() @trusted {
        auto nameEvents = getEvents!TrackNameEvent();
        return nameEvents.length > 0 ? nameEvents[0].text : "";
    }
    
    /**
     * Set track name
     */
    void setName(string name) @safe {
        // Remove existing track name events
        events = events.filter!(e => cast(TrackNameEvent)e is null).array;
        
        // Add new track name at the beginning (delta time 0)
        auto nameEvent = new TrackNameEvent(0, name);
        events = [nameEvent] ~ events;
    }
    
    /**
     * Ensure track ends with End of Track event
     */
    void ensureEndOfTrack() @trusted {
        // Check if last event is End of Track
        if (events.length == 0 || cast(EndOfTrackEvent)events[$-1] is null) {
            addEvent(new EndOfTrackEvent(0));
        }
    }
    
    /**
     * Transpose all note events by semitones
     */
    void transpose(int semitones) @trusted {
        foreach (event; events) {
            if (auto noteOn = cast(NoteOnEvent)event) {
                int newNote = noteOn.note + semitones;
                if (newNote >= 0 && newNote < 128) {
                    noteOn.note = cast(ubyte)newNote;
                }
            } else if (auto noteOff = cast(NoteOffEvent)event) {
                int newNote = noteOff.note + semitones;
                if (newNote >= 0 && newNote < 128) {
                    noteOff.note = cast(ubyte)newNote;
                }
            }
        }
    }
    
    /**
     * Scale velocity of all note events by a factor
     */
    void scaleVelocity(double factor) @trusted {
        foreach (event; events) {
            if (auto noteOn = cast(NoteOnEvent)event) {
                int newVelocity = cast(int)(noteOn.velocity * factor);
                noteOn.velocity = cast(ubyte)clamp(newVelocity, 0, 127);
            }
        }
    }
    
    /**
     * Scale timing of all events by a factor
     */
    void scaleTiming(double factor) @safe {
        foreach (event; events) {
            event.deltaTime = cast(uint)(event.deltaTime * factor);
        }
    }
    
    override bool validate() @safe {
        // Check that all events are valid
        foreach (event; events) {
            if (!event.validate()) {
                return false;
            }
        }
        return true;
    }
    
    override size_t getSize() const @safe {
        size_t total = 0;
        foreach (event; events) {
            // Add variable length delta time size (estimate)
            total += estimateVariableLengthSize(event.deltaTime);
            // Add event data size
            total += event.getSize();
        }
        return total;
    }
    
    private static size_t estimateVariableLengthSize(uint value) @safe {
        if (value < 128) return 1;
        if (value < 16384) return 2;
        if (value < 2097152) return 3;
        return 4;
    }
    
    private static T clamp(T)(T value, T min, T max) @safe {
        if (value < min) return min;
        if (value > max) return max;
        return value;
    }
}
