/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
import std.stdio;
import std.file;
import uim.media.comic;

void main() {
    writeln("Running Comic Library Tests...\n");
    
    testFormatDetection();
    testMetadata();
    testPages();
    testComicCreation();
    testReader();
    testUtils();
    
    writeln("\n✓ All tests passed!");
}

void testFormatDetection() {
    writeln("Test: Format detection");
    
    assert(ComicUtils.detectFormat("comic.cbz") == ComicFormat.cbz);
    assert(ComicUtils.detectFormat("comic.cbr") == ComicFormat.cbr);
    assert(ComicUtils.detectFormat("comic.cb7") == ComicFormat.cb7);
    assert(ComicUtils.detectFormat("comic.cbt") == ComicFormat.cbt);
    assert(ComicUtils.detectFormat("unknown.xyz") == ComicFormat.unknown);
    
    assert(ComicUtils.detectImageFormat("page.jpg") == ImageFormat.jpeg);
    assert(ComicUtils.detectImageFormat("page.png") == ImageFormat.png);
    assert(ComicUtils.detectImageFormat("page.gif") == ImageFormat.gif);
    
    assert(ComicUtils.isImageFile("page.jpg") == true);
    assert(ComicUtils.isImageFile("page.txt") == false);
    
    writeln("  ✓ Format detection");
}

void testMetadata() {
    writeln("Test: Metadata");
    
    auto metadata = new ComicMetadata();
    metadata.title = "Test Comic";
    metadata.series = "Test Series";
    metadata.number = 1;
    metadata.writer = "Test Writer";
    metadata.publisher = "Test Publisher";
    metadata.year = 2025;
    
    assert(metadata.title == "Test Comic");
    assert(metadata.getFullTitle() == "Test Series #1");
    assert(metadata.isComplete() == true);
    assert(metadata.validate() == true);
    
    // Test creators
    metadata.addCreator(Creator.penciller("Artist Name"));
    assert(metadata.creators.length == 1);
    assert(metadata.penciller == "Artist Name");
    
    // Test date handling
    metadata.setPublicationDate("2025-06-15");
    assert(metadata.year == 2025);
    assert(metadata.month == 6);
    assert(metadata.day == 15);
    assert(metadata.getPublicationDate() == "2025-06-15");
    
    // Test XML generation
    auto xml = metadata.toXML();
    assert(xml.length > 0);
    assert(xml.indexOf("<Title>Test Comic</Title>") > 0);
    
    writeln("  ✓ Metadata");
}

void testPages() {
    writeln("Test: Pages");
    
    auto page = new ComicPage("test.jpg");
    assert(page.filename == "test.jpg");
    assert(page.imageFormat == ImageFormat.jpeg);
    assert(page.type == PageType.story);
    
    // Load image data
    ubyte[] testData = [1, 2, 3, 4, 5];
    page.loadImageData(testData);
    assert(page.imageData.length == 5);
    assert(page.fileSize == 5);
    
    // Test page types
    page.type = PageType.frontCover;
    assert(page.isCover() == true);
    assert(page.getTypeString() == "Front Cover");
    
    page.type = PageType.story;
    assert(page.isCover() == false);
    
    // Validate
    assert(page.validate() == true);
    
    writeln("  ✓ Pages");
}

void testComicCreation() {
    writeln("Test: Comic creation");
    
    auto comic = new ComicBook();
    comic.metadata.title = "Test";
    comic.metadata.series = "Test Series";
    comic.metadata.number = 1;
    
    // Add pages
    ubyte[] dummy = [1, 2, 3];
    comic.addPage(dummy, "page01.jpg", PageType.frontCover);
    comic.addPage(dummy, "page02.jpg", PageType.story);
    comic.addPage(dummy, "page03.jpg", PageType.story);
    
    assert(comic.pageCount == 3);
    assert(comic.metadata.pageCount == 3);
    
    // Get page
    auto page = comic.getPage(0);
    assert(page.filename == "page01.jpg");
    assert(page.type == PageType.frontCover);
    
    // Get page image
    auto imageData = comic.getPageImage(1);
    assert(imageData.length == 3);
    
    // Validate
    assert(comic.validate() == true);
    
    writeln("  ✓ Comic creation");
}

void testReader() {
    writeln("Test: Reader");
    
    auto comic = new ComicBook();
    comic.metadata.title = "Test Comic";
    
    ubyte[] dummy = [1, 2, 3];
    for (int i = 0; i < 10; i++) {
        comic.addPage(dummy, format("page%02d.jpg", i+1), PageType.story);
    }
    
    // Create reader
    auto reader = ComicReader.create(comic);
    assert(reader.currentPageIndex == 0);
    assert(reader.isFirstPage() == true);
    assert(reader.isLastPage() == false);
    
    // Navigate
    assert(reader.nextPage() == true);
    assert(reader.currentPageIndex == 1);
    assert(reader.getProgress() > 0);
    
    assert(reader.previousPage() == true);
    assert(reader.currentPageIndex == 0);
    
    // Jump to page
    assert(reader.gotoPage(5) == true);
    assert(reader.currentPageIndex == 5);
    
    // Go to last page
    reader.gotoLastPage();
    assert(reader.isLastPage() == true);
    assert(reader.currentPageIndex == 9);
    
    // Check progress
    assert(reader.getProgress() > 90.0);
    assert(reader.getPagesRemaining() == 0);
    
    writeln("  ✓ Reader");
}

void testUtils() {
    writeln("Test: Utilities");
    
    // Natural sorting
    string[] files = ["page10.jpg", "page2.jpg", "page1.jpg", "page100.jpg", "page20.jpg"];
    auto sorted = ComicUtils.sortNaturally(files);
    assert(sorted[0] == "page1.jpg");
    assert(sorted[1] == "page2.jpg");
    assert(sorted[2] == "page10.jpg");
    assert(sorted[3] == "page20.jpg");
    assert(sorted[4] == "page100.jpg");
    
    // Natural compare
    assert(ComicUtils.naturalCompare("page1.jpg", "page2.jpg") < 0);
    assert(ComicUtils.naturalCompare("page10.jpg", "page2.jpg") > 0);
    assert(ComicUtils.naturalCompare("page1.jpg", "page1.jpg") == 0);
    
    // File size formatting
    assert(ComicUtils.formatFileSize(500) == "500 B");
    assert(ComicUtils.formatFileSize(1024) == "1.00 KB");
    assert(ComicUtils.formatFileSize(1048576) == "1.00 MB");
    
    // Page number extraction
    assert(ComicUtils.extractPageNumber("page001.jpg") == 1);
    assert(ComicUtils.extractPageNumber("page042.jpg") == 42);
    assert(ComicUtils.extractPageNumber("cover.jpg") == -1);
    
    // Sanitize filename
    auto sanitized = ComicUtils.sanitizeFilename("file:with*bad?chars.jpg");
    assert(sanitized.indexOf(":") < 0);
    assert(sanitized.indexOf("*") < 0);
    assert(sanitized.indexOf("?") < 0);
    
    writeln("  ✓ Utilities");
}
