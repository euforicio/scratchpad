//
//  DotOperatorTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class DotOperatorTests: VimTestCase {
    override func setUp() {
        super.setUp()

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("ene!");
    }

    func test_basic_redo() {
        vimInput("I");
        vimInput("a");
        vimInput("b");
        vimInput("c");
        vimKey("<esc>");

        XCTAssertEqual(vimBufferGetLine(curbuf, 1), "abc")

        vimInput(".")
        XCTAssertEqual(vimBufferGetLine(curbuf, 1), "abcabc")
    }
}
