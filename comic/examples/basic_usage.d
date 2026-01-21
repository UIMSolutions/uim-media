/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
import std.stdio;
import std.file;
import uim.media.comic;

void main() {
    writeln("=== UIM Comic Library - Basic Usage Examples ===\n");
    
    // Example 1: Create a comic book
    example1_createComic();
    
    // Example 2: Work with metadata
    example2_metadata();
    
    // Example 3: Reading and navigation
    example3_reading();
    
    // Example 4: Page management
    example4_pages();
    
    writeln("\nAll examples completed successfully!");
}

/// Create a comic book archive
void example1_createComic() {
    writeln("Example 1: Creating a comic book");
    writeln("---------------------------------");
    
    auto comic = new ComicBook();
    
    // Set metadata
    comic.metadata.title = "The Amazing Adventures";
    comic.metadata.series = "Amazing Adventures";
    comic.metadata.number = 1;
    comic.metadata.writer = "John Writer";
    comic.metadata.penciller = "Jane Artist";
    comic.metadata.publisher = "Comic House Publishing";
    comic.metadata.year = 2025;
    comic.metadata.genre = "Superhero";
    comic.metadata.languageISO = "en";
    comic.metadata.summary = "An exciting tale of heroes and villains...";
    
    // Create some dummy image data (in real use, load actual images)
    ubyte[] dummyImage = [
        137, 80, 78, 71, 13, 10, 26, 10,  // PNG signature
        0, 0, 0, 13, 73, 72, 68, 82,      // IHDR chunk
        0, 0, 1, 0, 0, 0, 1, 0,           // 256x256
        8, 2, 0, 0, 0                      // etc.
    ];
    
    // Add pages
    comic.addPage(dummyImage, "cover.png", PageType.frontCover);
    comic.addPage(dummyImage, "page01.png", PageType.story);
    comic.addPage(dummyImage, "page02.png", PageType.story);
    comic.addPage(dummyImage, "page03.png", PageType.story);
    comic.addPage(dummyImage, "back.png", PageType.backCover);
    
    writeln("Created comic:");
    writeln("  Title: ", comic.metadata.getFullTitle());
    writeln("  Writer: ", comic.metadata.writer);
    writeln("  Publisher: ", comic.metadata.publisher);
    writeln("  Pages: ", comic.pageCount);
    writeln();
    
    // Note: Saving disabled in example to avoid creating files
    // comic.saveToCBZ("amazing_adventures_01.cbz");
}

/// Working with metadata
void example2_metadata() {
    writeln("Example 2: Working with metadata");
    writeln("--------------------------------");
    
    auto metadata = new ComicMetadata();
    
    // Basic information
    metadata.title = "Spider-Man: The Clone Saga";
    metadata.series = "Spider-Man";
    metadata.number = 149;
    metadata.volume = 1;
    metadata.count = 200;
    
    // Creators
    metadata.addCreator(Creator.writer("Stan Lee"));
    metadata.addCreator(Creator.penciller("Steve Ditko"));
    metadata.addCreator(Creator.inker("Steve Ditko"));
    metadata.addCreator(Creator.colorist("John Color"));
    metadata.addCreator(Creator.letterer("Sam Letters"));
    
    // Publishing info
    metadata.publisher = "Marvel Comics";
    metadata.imprint = "Marvel";
    metadata.genre = "Superhero, Action";
    metadata.year = 1975;
    metadata.month = 6;
    
    // Additional info
    metadata.ageRating = AgeRating.teen;
    metadata.manga = Manga.no;
    metadata.languageISO = "en";
    metadata.summary = "The continuation of the Clone Saga storyline...";
    metadata.characters = "Spider-Man, Mary Jane Watson, Green Goblin";
    
    // Display metadata
    writeln(metadata.toString());
    
    // Export to ComicInfo.xml
    writeln("ComicInfo.xml preview:");
    auto xml = metadata.toXML();
    auto lines = xml.split("\n");
    foreach (i, line; lines) {
        if (i < 10) writeln(line);  // Show first 10 lines
    }
    writeln("  ... (truncated)");
    writeln();
}

/// Reading and navigation
void example3_reading() {
    writeln("Example 3: Reading and navigation");
    writeln("---------------------------------");
    
    auto comic = new ComicBook();
    comic.metadata.title = "Test Comic";
    
    // Add some pages
    ubyte[] dummy = [1, 2, 3, 4, 5];
    for (int i = 0; i < 10; i++) {
        comic.addPage(dummy, format("page%02d.jpg", i+1), PageType.story);
    }
    
    // Create reader
    auto reader = ComicReader.create(comic);
    
    writeln("Starting to read: ", comic.metadata.title);
    writeln("Total pages: ", comic.pageCount);
    writeln("Current page: ", reader.currentPageIndex + 1);
    writeln();
    
    // Navigate through pages
    writeln("Navigation:");
    for (int i = 0; i < 5; i++) {
        auto page = reader.getCurrentPage();
        writeln("  Reading page ", page.pageNumber + 1, ": ", page.filename);
        writeln("    Progress: ", format("%.1f%%", reader.getProgress()));
        writeln("    Pages remaining: ", reader.getPagesRemaining());
        reader.nextPage();
    }
    
    // Jump to specific page
    writeln("\nJumping to page 8...");
    reader.gotoPage(7);
    writeln("  Current page: ", reader.currentPageIndex + 1);
    writeln("  Progress: ", format("%.1f%%", reader.getProgress()));
    
    // Go to last page
    writeln("\nGoing to last page...");
    reader.gotoLastPage();
    writeln("  Current page: ", reader.currentPageIndex + 1);
    writeln("  Is finished: ", reader.isFinished());
    writeln();
}

/// Page management
void example4_pages() {
    writeln("Example 4: Page management");
    writeln("--------------------------");
    
    auto comic = new ComicBook();
    
    // Create pages with different types
    ubyte[] dummy = [1, 2, 3];
    
    auto coverPage = new ComicPage("cover.jpg");
    coverPage.type = PageType.frontCover;
    coverPage.loadImageData(dummy);
    coverPage.width = 1200;
    coverPage.height = 1800;
    comic.pages ~= coverPage;
    
    auto storyPage1 = new ComicPage("page01.jpg");
    storyPage1.type = PageType.story;
    storyPage1.loadImageData(dummy);
    storyPage1.width = 1200;
    storyPage1.height = 1800;
    comic.pages ~= storyPage1;
    
    auto adPage = new ComicPage("ad01.jpg");
    adPage.type = PageType.advertisement;
    adPage.loadImageData(dummy);
    comic.pages ~= adPage;
    
    auto backPage = new ComicPage("back.jpg");
    backPage.type = PageType.backCover;
    backPage.loadImageData(dummy);
    comic.pages ~= backPage;
    
    // Display page information
    writeln("Comic pages:");
    foreach (page; comic.pages) {
        writeln("  ", page.toString().strip());
    }
    
    // Sort pages by filename
    comic.sortPages();
    writeln("\nAfter sorting:");
    foreach (page; comic.pages) {
        writeln("  Page ", page.pageNumber + 1, ": ", page.filename);
    }
    
    // Utility functions
    writeln("\nUtility functions:");
    writeln("  Format detection for 'comic.cbz': ", 
            ComicUtils.formatDescription(ComicUtils.detectFormat("comic.cbz")));
    writeln("  Image format for 'page.jpg': ", 
            ComicUtils.detectImageFormat("page.jpg"));
    writeln("  File size formatting: ", ComicUtils.formatFileSize(1048576));
    
    // Natural sorting demo
    string[] files = ["page10.jpg", "page2.jpg", "page1.jpg", "page20.jpg"];
    writeln("\nBefore natural sort: ", files);
    files = ComicUtils.sortNaturally(files);
    writeln("After natural sort: ", files);
    writeln();
}
