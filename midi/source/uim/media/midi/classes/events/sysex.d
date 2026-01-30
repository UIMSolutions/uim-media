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
