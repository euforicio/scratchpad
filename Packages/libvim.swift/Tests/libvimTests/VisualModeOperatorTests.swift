//
//  VisualModeOperatorTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class VisualModeOperatorTests: VimTestCase {
    override func setUp() {
        super.setUp()

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");

        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_visual_linewise_delete() {
        vimInput("V");

        vimInput("d");

        mu_check(vimBufferGetLineCount(curbuf) == 2);
        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        print("LINE: ", line);
        mu_check(strcmp(line, "This is the second line of a test file") == 0);
    }

    func test_visual_linewise_motion_delete() {
        vimInput("V");

        vimInput("2");
        vimInput("j");

        vimInput("d");

        mu_check(vimBufferGetLineCount(curbuf) == 1);
        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        print("LINE: ", line);
        mu_check(strcmp(line, "") == 0);
    }

    func test_visual_character_delete() {
        vimInput("v");
        vimInput("l");
        vimInput("d");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        print("LINE: ", line);
        mu_check(strcmp(line, "is is the first line of a test file") == 0);
    }

    func test_visual_character_insert() {
        vimInput("v");
        vimInput("j");
        vimInput("I");

        XCTAssert(vimGetMode().contains(.insert))
    }

    func test_visual_linewise_append() {
        vimInput("V");
        vimInput("j");
        vimInput("A");

        XCTAssert(vimGetMode().contains(.insert))
    }
}
