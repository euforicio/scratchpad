//
//  CursorTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class CursorTests: VimTestCase {
    var onCursorAddCount = 0
    var cursors = [Vim.Position](repeating: Vim.Position(), count: 128)

    class override func setUp() {
        super.setUp()

        win_setwidth(80);
        win_setheight(40);

        vimBufferOpen(lines100, 1, 0);
    }

    override func setUp() {
        super.setUp()

        vimSetCursorAddCallback { [unowned self] cursor in
            print("TEST: onCursorAdd - Adding cursor at line: \(cursor.lnum) col: \(cursor.col)")
            cursors[onCursorAddCount] = cursor;
            onCursorAddCount++;
        }

        vimExecute("e!");
        vimKey("<esc>");
        vimKey("<esc>");

        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_set_cursor() {
        var pos = Vim.Position()
        pos.lnum = 5
        pos.col = 4
        vimCursorSetPosition(pos)

        XCTAssertEqual(vimCursorGetLine(), 5)
        XCTAssertEqual(vimCursorGetColumn(), 4)
    }

    func test_set_cursor_invalid_line() {
        var pos = Vim.Position()
        pos.lnum = 500;
        pos.col = 4;
        vimCursorSetPosition(pos);

        mu_check(vimCursorGetLine() == 100);
        mu_check(vimCursorGetColumn() == 4);
    }

    func test_set_cursor_doesnt_move_topline() {
        vimWindowSetTopLeft(71, 1);
        var pos = Vim.Position()
        pos.lnum = 90;
        pos.col = 4;
        vimCursorSetPosition(pos);

        mu_check(vimCursorGetLine() == 90);
        mu_check(vimCursorGetColumn() == 4);
        print("window topline: ", vimWindowGetTopLine());
        mu_check(vimWindowGetTopLine() == 71);
    }

    func test_set_cursor_invalid_column() {
        var pos = Vim.Position()
        pos.lnum = 7;
        pos.col = 500;
        vimCursorSetPosition(pos);

        mu_check(vimCursorGetLine() == 7);
        mu_check(vimCursorGetColumn() == 5);
    }

    func test_add_cursors_visual_I() {
        vimKey("<c-v>");
        vimInput("j");
        vimInput("j");
        vimInput("I");

        mu_check(cursors[0].lnum == 1);
        mu_check(cursors[0].col == 0);

        mu_check(cursors[1].lnum == 2);
        mu_check(cursors[1].col == 0);

        mu_check(onCursorAddCount == 2);

        mu_check(vimCursorGetLine() == 3);
        mu_check(vimCursorGetColumn() == 0);

        // Verify we switch to insert mode
        XCTAssert(vimGetMode().contains(.insert))
    }

    func test_add_cursors_visual_reverse_I() {
        vimInput("j");
        vimInput("j");
        vimKey("<c-v>");
        vimInput("k");
        vimInput("k");

        vimInput("I");

        mu_check(cursors[0].lnum == 2);
        mu_check(cursors[0].col == 0);

        mu_check(cursors[1].lnum == 3);
        mu_check(cursors[1].col == 0);

        mu_check(onCursorAddCount == 2);

        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 0);

        // Verify we switch to insert mode
        XCTAssert(vimGetMode().contains(.insert))
    }

    func test_add_cursors_visual_after() {
        vimKey("<c-v>");
        vimInput("j");
        vimInput("j");
        vimInput("A");

        mu_check(cursors[0].lnum == 1);
        mu_check(cursors[0].col == 1);

        mu_check(cursors[1].lnum == 2);
        mu_check(cursors[1].col == 1);

        mu_check(onCursorAddCount == 2);

        mu_check(vimCursorGetLine() == 3);
        mu_check(vimCursorGetColumn() == 1);

        // Verify we switch to insert mode
        XCTAssert(vimGetMode().contains(.insert))
    }

    func test_add_cursors_visual_skip_empty_line() {
        // Add an empty line up top
        let lines = ["abc", "", "def"]

        vimBufferSetLines(curbuf, 0, 0, lines, 3)
        vimKey("<c-v>");
        vimInput("j");
        vimInput("j");
        vimInput("l");
        vimInput("I");

        mu_check(cursors[0].lnum == 1);
        mu_check(cursors[0].col == 1);

        mu_check(onCursorAddCount == 1);

        mu_check(vimCursorGetLine() == 3);
        mu_check(vimCursorGetColumn() == 1);

        // Verify we switch to insert mode
        XCTAssert(vimGetMode().contains(.insert))
    }

    func test_add_cursors_visual_utf8_vcol() {
        // Add an empty line up top
        let lines = ["abc", "κόσμε", "def"];

        vimBufferSetLines(curbuf, 0, 0, lines, 3)
        vimKey("<c-v>");
        // Move two lines down
        vimInput("j");
        vimInput("j");
        //  Move two characters to the right (`de|f`)
        vimInput("l");
        vimInput("l");
        vimInput("I");

        mu_check(cursors[0].lnum == 1);
        mu_check(cursors[0].col == 2);

        // Verify we're on the proper byte...
        mu_check(cursors[1].lnum == 2);
        mu_check(cursors[1].col == 5);

        mu_check(onCursorAddCount == 2);

        mu_check(vimCursorGetLine() == 3);
        mu_check(vimCursorGetColumn() == 2);

        // Verify we switch to insert mode
        XCTAssert(vimGetMode().contains(.insert))
    }

    // Verify the primary cursor ends up past EOL when transitioning to insert mode
    func test_add_cursors_eol() {
        // Add an empty line up top
        let lines = ["abc", "def", "ghi"]

        vimBufferSetLines(curbuf, 0, 0, lines, 3)
        vimKey("<c-v>");
        // Move two lines down
        vimInput("j");
        vimInput("j");
        //  Move two characters to the right (`de|f`)
        vimInput("l");
        vimInput("l");
        vimInput("A");

        mu_check(cursors[0].lnum == 1);
        XCTAssertEqual(cursors[0].col, 3);

        // Verify we're on the proper byte...
        mu_check(cursors[1].lnum == 2);
        XCTAssertEqual(cursors[1].col, 3);

        XCTAssertEqual(onCursorAddCount, 2);

        XCTAssertEqual(vimCursorGetLine(), 3);
        XCTAssertEqual(vimCursorGetColumn(), 3);

        // Verify we switch to insert mode
        XCTAssert(vimGetMode().contains(.insert))
    }
}
