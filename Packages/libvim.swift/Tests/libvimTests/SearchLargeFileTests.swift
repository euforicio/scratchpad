//
//  SearchLargeFileTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class SearchLargeFileTests: VimTestCase {
    override func setUp() {
        super.setUp()

        vimBufferOpen("\(collateral)/large-c-file.c", 1, 0);

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");
        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_search_in_large_file() {
        vimInput("/");
        vimInput("e");

        let highlights = vimSearchGetHighlights(curbuf, 0, 0)
        XCTAssertEqual(highlights.count, 15420)
    }
}
