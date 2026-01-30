module uim.media.audio.classes.tags;

import uim.media.audio;
@safe:

/**
 * ID3 tag utilities and helpers
 */
class ID3Tags {
    /**
     * Standard ID3v1 genres
     */
    static immutable string[] genres = [
        "Blues", "Classic Rock", "Country", "Dance", "Disco",
        "Funk", "Grunge", "Hip-Hop", "Jazz", "Metal",
        "New Age", "Oldies", "Other", "Pop", "R&B",
        "Rap", "Reggae", "Rock", "Techno", "Industrial",
        "Alternative", "Ska", "Death Metal", "Pranks", "Soundtrack",
        "Euro-Techno", "Ambient", "Trip-Hop", "Vocal", "Jazz+Funk",
        "Fusion", "Trance", "Classical", "Instrumental", "Acid",
        "House", "Game", "Sound Clip", "Gospel", "Noise",
        "AlternRock", "Bass", "Soul", "Punk", "Space",
        "Meditative", "Instrumental Pop", "Instrumental Rock", "Ethnic", "Gothic",
        "Darkwave", "Techno-Industrial", "Electronic", "Pop-Folk", "Eurodance",
        "Dream", "Southern Rock", "Comedy", "Cult", "Gangsta",
        "Top 40", "Christian Rap", "Pop/Funk", "Jungle", "Native American",
        "Cabaret", "New Wave", "Psychadelic", "Rave", "Showtunes",
        "Trailer", "Lo-Fi", "Tribal", "Acid Punk", "Acid Jazz",
        "Polka", "Retro", "Musical", "Rock & Roll", "Hard Rock"
    ];

    /**
     * Get genre name by ID3v1 index
     */
    static string getGenreByIndex(size_t index) {
        if (index < genres.length) {
            return genres[index];
        }
        return "Unknown";
    }

    /**
     * Get genre index by name
     */
    static int getGenreIndex(string genreName) {
        foreach (i, genre; genres) {
            if (genre.toLower == genreName.toLower) {
                return cast(int)i;
            }
        }
        return -1;
    }

    /**
     * Parse ID3v1 tag from data
     */
    static bool parseID3v1(ubyte[] data, ref AudioMetadata metadata) @trusted {
        if (data.length < 128) return false;

        // Check for TAG identifier at position -128 from end
        size_t tagPos = data.length - 128;
        if (data[tagPos .. tagPos + 3] != cast(ubyte[])"TAG") {
            return false;
        }

        // Read title (30 bytes)
        metadata.title = stripNullChars(cast(string)data[tagPos + 3 .. tagPos + 33].dup);

        // Read artist (30 bytes)
        metadata.artist = stripNullChars(cast(string)data[tagPos + 33 .. tagPos + 63].dup);

        // Read album (30 bytes)
        metadata.album = stripNullChars(cast(string)data[tagPos + 63 .. tagPos + 93].dup);

        // Read year (4 bytes)
        string yearStr = stripNullChars(cast(string)data[tagPos + 93 .. tagPos + 97].dup);
        if (yearStr.length > 0) {
            try {
                import std.conv : to;
                metadata.year = to!uint(yearStr);
            } catch (Exception) {}
        }

        // Read comment (28 or 30 bytes) and track number
        // ID3v1.1 uses byte 125 (comment[28]) as 0 and byte 126 as track number
        if (data[tagPos + 125] == 0 && data[tagPos + 126] != 0) {
            // ID3v1.1
            metadata.comment = stripNullChars(cast(string)data[tagPos + 97 .. tagPos + 125].dup);
            metadata.track = data[tagPos + 126];
        } else {
            // ID3v1
            metadata.comment = stripNullChars(cast(string)data[tagPos + 97 .. tagPos + 127].dup);
        }

        // Read genre (1 byte)
        ubyte genreIndex = data[tagPos + 127];
        if (genreIndex < genres.length) {
            metadata.genre = genres[genreIndex];
        }

        return true;
    }

    /**
     * Strip null characters and whitespace from string
     */
    private static string stripNullChars(string str) pure {
        import std.algorithm : filter;
        import std.array : array;
        return str.filter!(c => c != '\0').array.strip;
    }
}
