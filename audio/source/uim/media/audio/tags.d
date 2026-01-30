/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.audio.tags;

import uim.media.audio.base;
import uim.media.audio.metadata;
import std.algorithm;
import std.string;

@safe:

/**
 * ID3 tag version enumeration
 */
enum ID3Version {
    none,
    v1,
    v1_1,
    v2_2,
    v2_3,
    v2_4
}


/**
 * Common audio tag fields
 */
struct TagField {
    string name;
    string value;
}
