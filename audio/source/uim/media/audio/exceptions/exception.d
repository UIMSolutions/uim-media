module uim.media.audio.exceptions;

import uim.media.audio;
@safe:

/**
 * Audio exception class
 */
class AudioException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
