/**
 * Exception thrown for MIDI-related errors
 */
class MIDIException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__) @safe {
        super(msg, file, line);
    }
}
