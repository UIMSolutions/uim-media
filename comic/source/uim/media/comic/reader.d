/*********************************************************************************************************
	Copyright: © 2018-2026 Ozan Nurettin Süel (aka UIManufaktur)
	License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
	Authors: Ozan Nurettin Süel (aka UIManufaktur)
**********************************************************************************************************/
module uim.media.comic.reader;

import uim.media.comic.base;
import uim.media.comic.io;
import uim.media.comic.page;
import std.algorithm;
import std.exception;

@safe:

/**
 * Comic book reader with navigation and progress tracking
 */
struct ComicReader {
    ComicBook comic;
    size_t currentPageIndex;
    ReadingDirection direction;
    ReadingProgress progress;
    
    /// Initialize reader with comic
    static ComicReader create(ComicBook comic, ReadingDirection dir = ReadingDirection.leftToRight) @safe {
        ComicReader reader;
        reader.comic = comic;
        reader.currentPageIndex = 0;
        reader.direction = dir;
        reader.progress.totalPages = comic.pageCount;
        reader.updateProgress();
        return reader;
    }
    
    /// Go to next page
    bool nextPage() @safe {
        if (direction == ReadingDirection.leftToRight) {
            if (currentPageIndex < comic.pageCount - 1) {
                currentPageIndex++;
                updateProgress();
                return true;
            }
        } else {
            // Right to left (manga style)
            if (currentPageIndex > 0) {
                currentPageIndex--;
                updateProgress();
                return true;
            }
        }
        return false;
    }
    
    /// Go to previous page
    bool previousPage() @safe {
        if (direction == ReadingDirection.leftToRight) {
            if (currentPageIndex > 0) {
                currentPageIndex--;
                updateProgress();
                return true;
            }
        } else {
            // Right to left (manga style)
            if (currentPageIndex < comic.pageCount - 1) {
                currentPageIndex++;
                updateProgress();
                return true;
            }
        }
        return false;
    }
    
    /// Go to first page
    void gotoFirstPage() @safe {
        if (direction == ReadingDirection.leftToRight) {
            currentPageIndex = 0;
        } else {
            currentPageIndex = comic.pageCount - 1;
        }
        updateProgress();
    }
    
    /// Go to last page
    void gotoLastPage() @safe {
        if (direction == ReadingDirection.leftToRight) {
            currentPageIndex = comic.pageCount - 1;
        } else {
            currentPageIndex = 0;
        }
        updateProgress();
    }
    
    /// Go to specific page
    bool gotoPage(size_t pageIndex) @safe {
        if (pageIndex < comic.pageCount) {
            currentPageIndex = pageIndex;
            updateProgress();
            return true;
        }
        return false;
    }
    
    /// Get current page
    ComicPage getCurrentPage() @safe {
        if (currentPageIndex < comic.pageCount) {
            return comic.pages[currentPageIndex];
        }
        return null;
    }
    
    /// Get current page image data
    const(ubyte)[] getCurrentPageImage() @safe {
        auto page = getCurrentPage();
        if (page !is null) {
            return page.getImageData();
        }
        return [];
    }
    
    /// Check if at first page
    bool isFirstPage() const @safe {
        if (direction == ReadingDirection.leftToRight) {
            return currentPageIndex == 0;
        } else {
            return currentPageIndex == comic.pageCount - 1;
        }
    }
    
    /// Check if at last page
    bool isLastPage() const @safe {
        if (direction == ReadingDirection.leftToRight) {
            return currentPageIndex == comic.pageCount - 1;
        } else {
            return currentPageIndex == 0;
        }
    }
    
    /// Get reading progress percentage
    double getProgress() const @safe {
        return progress.percentage;
    }
    
    /// Check if comic is finished
    bool isFinished() const @safe {
        return progress.isFinished;
    }
    
    /// Update progress tracking
    private void updateProgress() @safe {
        progress.currentPage = currentPageIndex;
        progress.updatePercentage();
    }
    
    /// Get pages remaining
    size_t getPagesRemaining() const @safe {
        if (direction == ReadingDirection.leftToRight) {
            return comic.pageCount - currentPageIndex - 1;
        } else {
            return currentPageIndex;
        }
    }
    
    /// Switch reading direction
    void setReadingDirection(ReadingDirection dir) @safe {
        if (direction != dir) {
            // Adjust current page for new direction
            if (dir == ReadingDirection.rightToLeft) {
                currentPageIndex = comic.pageCount - currentPageIndex - 1;
            } else {
                currentPageIndex = comic.pageCount - currentPageIndex - 1;
            }
            direction = dir;
            updateProgress();
        }
    }
}

/**
 * Bookmark for comic reading
 */
struct ComicBookmark {
    string comicId;
    size_t pageIndex;
    string note;
    string timestamp;
    
    /// Create a new bookmark
    static ComicBookmark create(string comicId, size_t pageIndex, string note = "") @safe {
        ComicBookmark bookmark;
        bookmark.comicId = comicId;
        bookmark.pageIndex = pageIndex;
        bookmark.note = note;
        // timestamp would be set using actual time in real implementation
        return bookmark;
    }
}

/**
 * Reading session for tracking reading history
 */
struct ReadingSession {
    string comicId;
    size_t currentPage;
    size_t totalPages;
    double progressPercentage;
    string lastReadDate;
    size_t totalPagesRead;
    
    /// Update session with current progress
    void update(ComicReader reader) @safe {
        currentPage = reader.currentPageIndex;
        totalPages = reader.comic.pageCount;
        progressPercentage = reader.getProgress();
        totalPagesRead++;
    }
    
    /// Check if comic is complete
    bool isComplete() const @safe {
        return progressPercentage >= 99.0;
    }
}
