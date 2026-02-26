//
//  SearchHighlightsTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class SearchHighlightsTests: VimTestCase {
    var stopSearchHighlightCount = 0
    var errorCount = 0

    override func setUp() {
        super.setUp()

        vimSetStopSearchHighlightCallback {
            self.stopSearchHighlightCount++
        }
        vimSetMessageCallback { [unowned self] title, message, priority in
            print("onMessage - title: |\(title)| contents: |\(message)|")

            if priority == .error {
                errorCount++
            }

        }

        vimKey("<esc>");
        vimKey("<esc>");

        vimBufferOpen(testfile, 1, 0);

        vimExecute("e!");

        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

//    func test_no_highlights_initially() {
//        vimExecute("let @/ = ''")
//        vimExecute("nohlsearch");
//        let highlights = vimSearchGetHighlights(curbuf, 0, 0)
//        XCTAssertEqual(highlights.count, 0)
//    }

    func test_get_highlights() {

        vimInput("/");
        vimInput("o");
        vimInput("f");

        let highlights = vimSearchGetHighlights(curbuf, 0, 0)

        mu_check(highlights.count == 3);
        mu_check(highlights[0].start.lnum == 1);
        mu_check(highlights[0].start.col == 23);
        mu_check(highlights[0].end.lnum == 1);
        mu_check(highlights[0].end.col == 25);

        mu_check(highlights[1].start.col == 24);

        mu_check(highlights[2].start.lnum == 3);
        mu_check(highlights[2].start.col == 23);
        mu_check(highlights[2].end.lnum == 3);
        mu_check(highlights[2].end.col == 25);
    }

    func test_nohlsearch() {
        mu_check(stopSearchHighlightCount == 0);
        vimExecute("nohlsearch");
        mu_check(stopSearchHighlightCount == 1);
    }

    func test_no_matching_highlights() { vimInput("/");
        vimInput("a");
        vimInput("b");
        vimInput("c");

        let highlights = vimSearchGetHighlights(curbuf, 0, 0)

        mu_check(highlights.isEmpty)
        mu_check(errorCount == 0);
    }

    func test_highlights_multiple_buffers() {
        vimInput("/");
        // Both buffers we're testing have 'Line' or 'line' on every line...
        vimInput("i");
        vimInput("n");
        vimInput("e");

        let originalBuffer = curbuf;

        // Switch to an alternate file
        vimBufferOpen(lines100, 1, 0);
        mu_check(originalBuffer != curbuf);
        var highlights = vimSearchGetHighlights(curbuf, 0, 0)

        mu_check(highlights.count == 100);
        mu_check(errorCount == 0);

        // Check original buffer
        highlights = vimSearchGetHighlights(originalBuffer, 0, 0)
        mu_check(highlights.count == 3);
        mu_check(errorCount == 0);
    }
}
