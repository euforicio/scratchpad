//
//  ReplaceTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class ReplaceTests: VimTestCase {
    override func setUp() {
        super.setUp()

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");
        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_simple_replace() {
        vimInput("r");
        vimInput("a");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine())
        print("LINE: ", line)
        XCTAssertEqual(line, "ahis is the first line of a test file")
    }

    func test_replace_esc() {
        vimInput("r");
        vimKey("<ESC>");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine())
        print("LINE: ", line)
        XCTAssertEqual(line, "This is the first line of a test file")
    }

}
