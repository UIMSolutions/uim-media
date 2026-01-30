module uim.media.audio.interfaces.metadatareader;

import uim.media.audio;
@safe:

/**
 * Metadata reader interface
 */
interface IMetadataReader {
    AudioMetadata read(Audio audio);
}
