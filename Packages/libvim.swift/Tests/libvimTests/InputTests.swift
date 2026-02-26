//
//  InputTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class InputTests: VimTestCase {

    override func setUp() {
        super.setUp()

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");

        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_cmd_key_insert() {
        vimInput("o");
        vimKey("<D-A>");

        mu_check(strcmp(vimBufferGetLine(curbuf, 2), "") == 0);
    }

    func test_binding_inactive() {
        vimExecute("inoremap a b");

        vimInput("o");
        vimKey("a");

        mu_check(strcmp(vimBufferGetLine(curbuf, 2), "a") == 0);
    }

    func test_arrow_keys_normal() {
        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 0);

        vimKey("<Right>");
        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 1);

        vimKey("<Down>");
        mu_check(vimCursorGetLine() == 2);
        mu_check(vimCursorGetColumn() == 1);

        vimKey("<Left>");
        mu_check(vimCursorGetLine() == 2);
        mu_check(vimCursorGetColumn() == 0);

        vimKey("<Up>");
        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 0);
    }

    func test_unhandled_escape() {

        var unhandledEscapeCount = 0
        vimSetUnhandledEscapeCallback {
            unhandledEscapeCount++
        }

        // Should get unhandled escape...
        vimKey("<esc>");
        XCTAssertEqual(unhandledEscapeCount, 1)

        // ...but not if escape was handled
        vimInput("i");
        vimKey("<esc>");
        // Should still be 1 - no additional calls made.
        XCTAssertEqual(unhandledEscapeCount, 1)
    }

    func test_control_bracket() {
        vimInput("i");

        XCTAssert(vimGetMode().contains(.insert))

        vimKey("<c-[>");
        XCTAssert(vimGetMode().contains(.normal))
    }
}
