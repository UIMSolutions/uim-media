/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.audio.metadata;

import uim.media.audio.base;
import std.datetime;
import std.conv;
import std.string;
import std.format : fmt = format;
import vibe.core.log;

@safe:

/**
 * Metadata reader interface
 */
interface IMetadataReader {
    AudioMetadata read(Audio audio);
}

/**
 * Metadata writer interface
 */
interface IMetadataWriter {
    void write(Audio audio, AudioMetadata metadata);
}
