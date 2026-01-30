module uim.media.midi.classes.metadata;

import uim.media.midi;
@safe:

/**
 * MIDI file metadata
 */
class MIDIMetadata {
    string title;
    string artist;
    string album;
    string copyright;
    string comment;
    string composer;
    string lyricist;
    string[] instruments;
    double tempo = 120.0;  // Default tempo in BPM
    TimeSignature timeSignature;
    KeySignature keySignature;
    uint durationTicks;
    
    this() @safe {
        timeSignature = TimeSignature.create(4, 4);  // 4/4 time
        keySignature = KeySignature.create(0, false); // C major
    }
    
    /**
     * Get duration in seconds
     */
    double getDurationSeconds(uint ticksPerQuarterNote) const @safe {
        if (tempo <= 0 || ticksPerQuarterNote == 0) return 0.0;
        
        // Calculate seconds per tick
        double secondsPerBeat = 60.0 / tempo;
        double secondsPerTick = secondsPerBeat / ticksPerQuarterNote;
        
        return durationTicks * secondsPerTick;
    }
    
    /**
     * Get formatted duration as MM:SS
     */
    string getFormattedDuration(uint ticksPerQuarterNote) const @safe {
        auto totalSeconds = cast(uint)getDurationSeconds(ticksPerQuarterNote);
        auto minutes = totalSeconds / 60;
        auto seconds = totalSeconds % 60;
        return format("%02d:%02d", minutes, seconds);
    }
    
    /**
     * Get time signature as string (e.g., "4/4")
     */
    string getTimeSignatureString() const @safe {
        return format("%d/%d", timeSignature.numerator, timeSignature.denominatorValue);
    }
    
    /**
     * Get key signature as string (e.g., "C major", "F# minor")
     */
    string getKeySignatureString() const @safe {
        immutable string[] majorKeys = [
            "C", "G", "D", "A", "E", "B", "F#", "C#",
            "F", "Bb", "Eb", "Ab", "Db", "Gb", "Cb"
        ];
        
        immutable string[] minorKeys = [
            "A", "E", "B", "F#", "C#", "G#", "D#", "A#",
            "D", "G", "C", "F", "Bb", "Eb", "Ab"
        ];
        
        int index = timeSignature.numerator >= 0 ? timeSignature.numerator : 7 + (-timeSignature.numerator);
        
        if (keySignature.isMinor) {
            return minorKeys[index] ~ " minor";
        } else {
            return majorKeys[index] ~ " major";
        }
    }
    
    /**
     * Convert metadata to a readable string
     */
    override string toString() const @safe {
        string result = "MIDI Metadata:\n";
        
        if (title.length > 0) result ~= "  Title: " ~ title ~ "\n";
        if (artist.length > 0) result ~= "  Artist: " ~ artist ~ "\n";
        if (album.length > 0) result ~= "  Album: " ~ album ~ "\n";
        if (composer.length > 0) result ~= "  Composer: " ~ composer ~ "\n";
        if (lyricist.length > 0) result ~= "  Lyricist: " ~ lyricist ~ "\n";
        if (copyright.length > 0) result ~= "  Copyright: " ~ copyright ~ "\n";
        if (comment.length > 0) result ~= "  Comment: " ~ comment ~ "\n";
        
        result ~= format("  Tempo: %.1f BPM\n", tempo);
        result ~= "  Time Signature: " ~ getTimeSignatureString() ~ "\n";
        result ~= "  Key Signature: " ~ getKeySignatureString() ~ "\n";
        
        if (instruments.length > 0) {
            result ~= "  Instruments: " ~ join(instruments, ", ") ~ "\n";
        }
        
        return result;
    }
    
    private static string format(Args...)(string fmt, Args args) @trusted {
        import std.format : fmt_format = format;
        return fmt_format(fmt, args);
    }
    
    private static string join(string[] arr, string separator) @trusted {
        import std.array : join_array = join;
        return join_array(arr, separator);
    }
}
