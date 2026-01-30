/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.comic.classes.metadata;

import uim.media.comic;
@safe:

/**
 * Comic book metadata (ComicInfo.xml standard)
 */
class ComicMetadata : ComicData {
    // Core metadata
    string title;
    string series;
    uint number;                    /// Issue number
    uint count;                     /// Total issues in series
    uint volume;                    /// Volume number
    string alternateNumber;         /// Alternate issue number
    string alternateSeries;         /// Alternate series name
    
    // Summary and description
    string summary;
    string notes;
    
    // Creators
    string writer;
    string penciller;
    string inker;
    string colorist;
    string letterer;
    string coverArtist;
    string editor;
    Creator[] creators;             /// Detailed creator information
    
    // Publishing
    string publisher;
    string imprint;
    string genre;
    string[] tags;
    string web;                     /// Web link
    string format;                  /// Format description
    
    // Classification
    AgeRating ageRating;
    Manga manga;
    string languageISO;             /// ISO language code
    
    // Dates
    uint year;
    uint month;
    uint day;
    
    // Technical
    uint pageCount;
    string blackAndWhite;           /// "Yes", "No", or "Unknown"
    
    // Series tracking
    string storyArc;
    string seriesGroup;
    uint arcNumber;
    
    // Additional
    string characters;
    string teams;
    string locations;
    string scanInformation;
    
    // Custom fields
    string[string] customFields;
    
    this() @safe {
        creators = [];
        tags = [];
        customFields = null;
        ageRating = AgeRating.unknown;
        manga = Manga.unknown;
    }
    
    /**
     * Add a creator
     */
    void addCreator(Creator creator) @safe {
        creators ~= creator;
        
        // Also update individual fields for compatibility
        switch (creator.role) {
            case "Writer":
                if (writer.length == 0) writer = creator.name;
                else writer ~= ", " ~ creator.name;
                break;
            case "Penciller":
                if (penciller.length == 0) penciller = creator.name;
                else penciller ~= ", " ~ creator.name;
                break;
            case "Inker":
                if (inker.length == 0) inker = creator.name;
                else inker ~= ", " ~ creator.name;
                break;
            case "Colorist":
                if (colorist.length == 0) colorist = creator.name;
                else colorist ~= ", " ~ creator.name;
                break;
            case "Letterer":
                if (letterer.length == 0) letterer = creator.name;
                else letterer ~= ", " ~ creator.name;
                break;
            case "CoverArtist":
                if (coverArtist.length == 0) coverArtist = creator.name;
                else coverArtist ~= ", " ~ creator.name;
                break;
            case "Editor":
                if (editor.length == 0) editor = creator.name;
                else editor ~= ", " ~ creator.name;
                break;
            default:
                break;
        }
    }
    
    /**
     * Get full title including issue number
     */
    string getFullTitle() const @safe {
        if (series.length > 0 && number > 0) {
            return format("%s #%d", series, number);
        } else if (title.length > 0) {
            return title;
        } else if (series.length > 0) {
            return series;
        }
        return "Untitled";
    }
    
    /**
     * Get publication date as string
     */
    string getPublicationDate() const @safe {
        if (year > 0) {
            if (month > 0 && day > 0) {
                return format("%04d-%02d-%02d", year, month, day);
            } else if (month > 0) {
                return format("%04d-%02d", year, month);
            } else {
                return to!string(year);
            }
        }
        return "";
    }
    
    /**
     * Set publication date from string
     */
    void setPublicationDate(string dateStr) @trusted {
        try {
            auto parts = dateStr.split("-");
            if (parts.length >= 1) year = to!uint(parts[0]);
            if (parts.length >= 2) month = to!uint(parts[1]);
            if (parts.length >= 3) day = to!uint(parts[2]);
        } catch (Exception e) {
            // Keep existing values if parsing fails
        }
    }
    
    /**
     * Check if metadata is complete
     */
    bool isComplete() const @safe {
        return title.length > 0 || series.length > 0;
    }
    
    override bool validate() @safe {
        // Basic validation
        if (title.length == 0 && series.length == 0) return false;
        
        // Validate date if present
        if (month > 12) return false;
        if (day > 31) return false;
        
        return true;
    }
    
    override size_t getSize() const @safe {
        size_t total = 0;
        total += title.length;
        total += series.length;
        total += summary.length;
        total += writer.length;
        total += publisher.length;
        
        foreach (creator; creators) {
            total += creator.name.length;
        }
        
        return total;
    }
    
    /**
     * Convert to ComicInfo.xml format
     */
    string toXML() const @trusted {
        string xml = "<?xml version=\"1.0\"?>\n";
        xml ~= "<ComicInfo>\n";
        
        if (title.length > 0) xml ~= format("  <Title>%s</Title>\n", escapeXML(title));
        if (series.length > 0) xml ~= format("  <Series>%s</Series>\n", escapeXML(series));
        if (number > 0) xml ~= format("  <Number>%d</Number>\n", number);
        if (count > 0) xml ~= format("  <Count>%d</Count>\n", count);
        if (volume > 0) xml ~= format("  <Volume>%d</Volume>\n", volume);
        if (alternateNumber.length > 0) xml ~= format("  <AlternateNumber>%s</AlternateNumber>\n", escapeXML(alternateNumber));
        if (alternateSeries.length > 0) xml ~= format("  <AlternateSeries>%s</AlternateSeries>\n", escapeXML(alternateSeries));
        
        if (summary.length > 0) xml ~= format("  <Summary>%s</Summary>\n", escapeXML(summary));
        if (notes.length > 0) xml ~= format("  <Notes>%s</Notes>\n", escapeXML(notes));
        
        if (writer.length > 0) xml ~= format("  <Writer>%s</Writer>\n", escapeXML(writer));
        if (penciller.length > 0) xml ~= format("  <Penciller>%s</Penciller>\n", escapeXML(penciller));
        if (inker.length > 0) xml ~= format("  <Inker>%s</Inker>\n", escapeXML(inker));
        if (colorist.length > 0) xml ~= format("  <Colorist>%s</Colorist>\n", escapeXML(colorist));
        if (letterer.length > 0) xml ~= format("  <Letterer>%s</Letterer>\n", escapeXML(letterer));
        if (coverArtist.length > 0) xml ~= format("  <CoverArtist>%s</CoverArtist>\n", escapeXML(coverArtist));
        if (editor.length > 0) xml ~= format("  <Editor>%s</Editor>\n", escapeXML(editor));
        
        if (publisher.length > 0) xml ~= format("  <Publisher>%s</Publisher>\n", escapeXML(publisher));
        if (imprint.length > 0) xml ~= format("  <Imprint>%s</Imprint>\n", escapeXML(imprint));
        if (genre.length > 0) xml ~= format("  <Genre>%s</Genre>\n", escapeXML(genre));
        if (web.length > 0) xml ~= format("  <Web>%s</Web>\n", escapeXML(web));
        if (format.length > 0) xml ~= format("  <Format>%s</Format>\n", escapeXML(format));
        
        if (year > 0) xml ~= format("  <Year>%d</Year>\n", year);
        if (month > 0) xml ~= format("  <Month>%d</Month>\n", month);
        if (day > 0) xml ~= format("  <Day>%d</Day>\n", day);
        
        if (pageCount > 0) xml ~= format("  <PageCount>%d</PageCount>\n", pageCount);
        if (languageISO.length > 0) xml ~= format("  <LanguageISO>%s</LanguageISO>\n", escapeXML(languageISO));
        
        if (ageRating != AgeRating.unknown) {
            xml ~= format("  <AgeRating>%s</AgeRating>\n", ageRatingToString(ageRating));
        }
        
        if (manga != Manga.unknown) {
            xml ~= format("  <Manga>%s</Manga>\n", mangaToString(manga));
        }
        
        if (storyArc.length > 0) xml ~= format("  <StoryArc>%s</StoryArc>\n", escapeXML(storyArc));
        if (seriesGroup.length > 0) xml ~= format("  <SeriesGroup>%s</SeriesGroup>\n", escapeXML(seriesGroup));
        if (characters.length > 0) xml ~= format("  <Characters>%s</Characters>\n", escapeXML(characters));
        if (teams.length > 0) xml ~= format("  <Teams>%s</Teams>\n", escapeXML(teams));
        if (locations.length > 0) xml ~= format("  <Locations>%s</Locations>\n", escapeXML(locations));
        if (scanInformation.length > 0) xml ~= format("  <ScanInformation>%s</ScanInformation>\n", escapeXML(scanInformation));
        
        xml ~= "</ComicInfo>\n";
        return xml;
    }
    
    /**
     * Parse from ComicInfo.xml format
     */
    static ComicMetadata fromXML(string xml) @trusted {
        auto metadata = new ComicMetadata();
        
        // Simple XML parsing (a real implementation would use a proper XML parser)
        metadata.title = extractXMLValue(xml, "Title");
        metadata.series = extractXMLValue(xml, "Series");
        
        auto numberStr = extractXMLValue(xml, "Number");
        if (numberStr.length > 0) {
            try { metadata.number = to!uint(numberStr); } catch (Exception e) {}
        }
        
        metadata.writer = extractXMLValue(xml, "Writer");
        metadata.penciller = extractXMLValue(xml, "Penciller");
        metadata.publisher = extractXMLValue(xml, "Publisher");
        metadata.summary = extractXMLValue(xml, "Summary");
        metadata.languageISO = extractXMLValue(xml, "LanguageISO");
        
        return metadata;
    }
    
    private static string extractXMLValue(string xml, string tag) @trusted {
        import std.regex : regex, matchFirst;
        
        auto pattern = regex("<" ~ tag ~ ">([^<]*)</" ~ tag ~ ">");
        auto match = xml.matchFirst(pattern);
        
        if (!match.empty && match.length > 1) {
            return match[1].strip;
        }
        
        return "";
    }
    
    private static string escapeXML(string text) @safe {
        return text
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&apos;");
    }
    
    private static string ageRatingToString(AgeRating rating) @safe {
        final switch (rating) with (AgeRating) {
            case unknown: return "Unknown";
            case everyone: return "Everyone";
            case everyonePlus10: return "Everyone 10+";
            case teen: return "Teen";
            case teenPlus: return "Teen Plus";
            case mature: return "Mature";
            case mature17Plus: return "Mature 17+";
            case adults18Plus: return "Adults Only 18+";
            case ratingPending: return "Rating Pending";
        }
    }
    
    private static string mangaToString(Manga m) @safe {
        final switch (m) with (Manga) {
            case unknown: return "Unknown";
            case no: return "No";
            case yes: return "Yes";
            case yesCJK: return "YesAndRightToLeft";
        }
    }
    
    /**
     * Convert to string representation
     */
    override string toString() const @safe {
        string result = "Comic Metadata:\n";
        
        result ~= "  Title: " ~ getFullTitle() ~ "\n";
        
        if (writer.length > 0) result ~= "  Writer: " ~ writer ~ "\n";
        if (penciller.length > 0) result ~= "  Penciller: " ~ penciller ~ "\n";
        if (publisher.length > 0) result ~= "  Publisher: " ~ publisher ~ "\n";
        if (year > 0) result ~= "  Year: " ~ to!string(year) ~ "\n";
        if (pageCount > 0) result ~= "  Pages: " ~ to!string(pageCount) ~ "\n";
        if (genre.length > 0) result ~= "  Genre: " ~ genre ~ "\n";
        if (languageISO.length > 0) result ~= "  Language: " ~ languageISO ~ "\n";
        
        if (summary.length > 0) {
            result ~= "  Summary: " ~ (summary.length > 100 ? 
                summary[0..100] ~ "..." : summary) ~ "\n";
        }
        
        return result;
    }
}
