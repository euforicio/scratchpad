//
//  NormalModeMotionTests.swift
//  
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-02-27.
//

import XCTest
import libvim

final class NormalModeMotionTests: VimTestCase {
    override func setUp() {
        super.setUp()

        vimExecute("e!")
        vimKey("<esc>")
        vimKey("<esc>")
        vimInput("g")
        vimInput("g")
    }

    func test_G_gg() {
        mu_check(vimCursorGetLine() == 1);

        vimInput("G");

        mu_check(vimCursorGetLine() == 3);

        vimInput("g");
        vimInput("g");

        mu_check(vimCursorGetLine() == 1);
    }

    func test_j_k() {
        mu_check(vimCursorGetLine() == 1);

        vimInput("j");

        mu_check(vimCursorGetLine() == 2);

        vimInput("k");

        mu_check(vimCursorGetLine() == 1);
    }

    func test_2j_2k() {
        mu_check(vimCursorGetLine() == 1);

        vimInput("2");
        vimInput("j");

        mu_check(vimCursorGetLine() == 3);

        vimInput("2");
        vimInput("k");

        mu_check(vimCursorGetLine() == 1);
    }

    func test_forward_search() {
        // Move to very beginning
        vimKey("g");
        vimKey("g");
        vimKey("0");

        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 0);

        // Search forwards to first 'line'
        vimKey("/");
        vimInput("line");
        vimKey("<cr>");

        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 18);

        // Search again from here
        vimKey("<esc>");
        vimKey("<esc>");

        vimKey("/");
        vimInput("line");
        vimKey("<cr>");

        mu_check(vimCursorGetLine() == 2);
        mu_check(vimCursorGetColumn() == 19);
    }

    func test_reverse_search() {
        // Move to second line, first byte
        vimKey("j");
        vimKey("0");

        mu_check(vimCursorGetLine() == 2);

        // Search backwards to first
        vimKey("?");
        vimInput("line");
        vimKey("<cr>");

        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 18);

        // Starting from match, searching backwards again
        vimKey("<esc>");
        vimKey("<esc>");

        vimKey("?");
        vimInput("line");
        vimKey("<cr>");

        // Serach should loop back
        mu_check(vimCursorGetLine() == 3);
        mu_check(vimCursorGetColumn() == 18);
    }

    func test_forward_search_with_delete_operator() {
        // Delete, searching forward
        vimInput("d");
        vimKey("/");
        vimInput("line");
        vimKey("<cr>");

        XCTAssert(vimGetMode().contains(.normal))
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "line of a test file") == 0);
    }

    func test_backward_search_with_delete_operator() {
        vimInput("$"); // Go to end of line
        // Delete, searching forward
        vimInput("d");
        vimKey("?");
        vimInput("line");
        vimKey("<cr>");

        XCTAssert(vimGetMode().contains(.normal))
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "This is the first e") == 0);
    }

    func test_forward_search_with_change_operator() {
        // Move to second line, first byte

        // Change forwards, to first
        vimInput("c");
        vimKey("/");
        vimInput("line");
        vimKey("<cr>");
        vimKey("a");

        XCTAssert(vimGetMode().contains(.insert))
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "aline of a test file") == 0);

        vimKey("<esc>");
        XCTAssert(vimGetMode().contains(.normal))
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "aline of a test file") == 0);
    }

    func test_backward_search_with_change_operator() {
        // Move to last byte in first line
        vimInput("$");

        // Change forwards, to first
        vimInput("c");
        vimKey("?");
        vimInput("line");
        vimKey("<cr>");
        vimKey("a");

        XCTAssert(vimGetMode().contains(.insert))
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "This is the first ae") == 0);

        vimKey("<esc>");
        XCTAssert(vimGetMode().contains(.normal))
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "This is the first ae") == 0);
    }
}
