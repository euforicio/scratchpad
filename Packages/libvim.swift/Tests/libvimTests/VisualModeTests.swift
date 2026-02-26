//
//  VisualModeTests.swift
//  
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-06.
//

import XCTest
import libvim

final class VisualModeTests: VimTestCase {
    override func setUp() {
        super.setUp()

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");

        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_visual_is_active() {
        mu_check(!vimVisualIsActive());

        vimInput("v");
        mu_check(vimVisualGetType() == "v");
        mu_check(vimVisualIsActive());
        XCTAssert(vimGetMode().contains(.visual))


        vimKey("<esc>");
        XCTAssert(vimGetMode().contains(.normal))

        mu_check(!vimVisualIsActive());

        vimKey("<c-v>");
        mu_check(vimVisualGetType() == .controlV);
        mu_check(vimVisualIsActive());
        XCTAssert(vimGetMode().contains(.visual))

        vimKey("<esc>");
        XCTAssert(vimGetMode().contains(.normal))
        mu_check(!vimVisualIsActive());

        vimInput("V");
        mu_check(vimVisualGetType() == "V");
        mu_check(vimVisualIsActive());
        XCTAssert(vimGetMode().contains(.visual))
    }

    func test_characterwise_range() {
        vimInput("v");

        vimInput("l");
        vimInput("l");

        // Get current range
        var (start, end) = vimVisualGetRange()
        mu_check(start.lnum == 1);
        mu_check(start.col == 0);
        mu_check(end.lnum == 1);
        mu_check(end.col == 2);

        vimKey("<esc>");
        vimInput("j");

        // Validate we still get previous range
        (start, end) = vimVisualGetRange()
        mu_check(start.lnum == 1);
        mu_check(start.col == 0);
        mu_check(end.lnum == 1);
        mu_check(end.col == 2);
    }

    func test_ctrl_q() {
        vimKey("<c-q>");

        XCTAssert(vimGetMode().contains(.visual))
        mu_check(vimVisualGetType() == .controlV);
        mu_check(vimVisualIsActive());
    }

    func test_ctrl_Q() {
        vimKey("<c-Q>");

        XCTAssert(vimGetMode().contains(.visual))
        mu_check(vimVisualGetType() == .controlV);
        mu_check(vimVisualIsActive());
    }

    func test_insert_block_mode() {
        vimKey("<c-v>");
        vimInput("j");
        vimInput("j");
        vimInput("j");

        vimInput("I");

        XCTAssert(vimGetMode().contains(.insert))

        vimInput("a");
        vimInput("b");
        vimInput("c");
    }

    /**
     * This test case does a visual block select and then an "I" insert
     * which should insert at the start of each line.
     * this test fails and will be commented out.
     */

    /*
     MU_TEST(test_insert_block_mode_change)
     {
     char_u *lines[] = {"line1", "line2", "line3", "line4", "line5"};
     vimBufferSetLines(curbuf, 0, 3, lines, 5);

     vimInput("<c-v>");
     vimInput("j");
     vimInput("j");
     vimInput("j");

     vimInput("I");

     vimInput("a");
     vimInput("b");
     vimInput("c");

     vimInput("<esc>");

     char_u *line = vimBufferGetLine(curbuf, 1);
     mu_check(strcmp(line, "abcline1") == 0);
     line = vimBufferGetLine(curbuf, 3);
     mu_check(strcmp(line, "abcline3") == 0);
     }
     */

    /**
     * This test case does a visual block select and then an "c" insert
     * which should insert "abc" at the start of each line, replacing the l
     */

    func test_change_block_mode_change() {
        let lines = ["line1", "line2", "line3", "line4", "line5"];
        vimBufferSetLines(curbuf, 0, 3, lines);

        vimKey("<c-v>");
        vimInput("j");
        vimInput("j");
        vimInput("j");

        vimInput("c");

        vimInput("a");
        vimInput("b");
        vimInput("c");

        vimKey("<esc>");

        var line = vimBufferGetLine(curbuf, 1);
        mu_check(strcmp(line, "abcine1") == 0);

        line = vimBufferGetLine(curbuf, 3);
        mu_check(strcmp(line, "abcine3") == 0);
    }

    func test_in_parentheses() {
        let lines = ["abc\"123\"def"];
        vimBufferSetLines(curbuf, 0, 3, lines);

        vimInput("v");
        vimInput("i");
        vimInput("\"");


        // Get current range, validate coordinates
        let (start, end) = vimVisualGetRange()
        print("start lnum: \(start.lnum) col: \(start.col) end lnum: \(end.lnum) col: \(end.col)\n");
        mu_check(start.lnum == 1);
        mu_check(start.col == 4);
        mu_check(end.lnum == 1);
        mu_check(end.col == 6);
    }

    func test_adjust_start_visual_line() {
        let lines = ["line1", "line2", "line3", "line4", "line5"];
        vimBufferSetLines(curbuf, 0, 3, lines);
        mu_check(vimBufferGetLineCount(curbuf) == 5);

        vimInput("j");
        vimInput("j");
        vimInput("V");

        // Get current range, validate coordinates
        var (start, end) = vimVisualGetRange();
        mu_check(start.lnum == 3);
        mu_check(start.col == 0);
        mu_check(end.lnum == 3);
        mu_check(end.col == 0);

        var newStart = Vim.Position()
        newStart.lnum = 1;
        newStart.col = 0;
        vimVisualSetStart(newStart);

        (start, end) = vimVisualGetRange();
        mu_check(start.lnum == 1);
        mu_check(start.col == 0);
        mu_check(end.lnum == 3);
        mu_check(end.col == 0);

        // Delete the lines - 1 through 3
        vimInput("d");

        // 3 lines should've been deleted
        mu_check(vimBufferGetLineCount(curbuf) == 2);
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "line4") == 0);
    }

    func test_adjust_start_select_character() {
        let lines = ["line1", "line2", "line3", "line4", "line5"];
        vimBufferSetLines(curbuf, 0, 3, lines);
        mu_check(vimBufferGetLineCount(curbuf) == 5);

        // Move two characters to the right - cursor on 'n' in line1
        vimInput("l");
        vimInput("l");
        // Switch to visual
        vimInput("v");
        // and then select
        vimKey("<C-g>");

        mu_check(vimSelectIsActive());

        // Get current range, validate coordinates
        var (start, end) = vimVisualGetRange();
        mu_check(start.lnum == 1);
        mu_check(start.col == 2);
        mu_check(end.lnum == 1);
        mu_check(end.col == 2);

        var newStart = Vim.Position();
        newStart.lnum = 1;
        newStart.col = 3;
        vimVisualSetStart(newStart);

        (start, end) = vimVisualGetRange();
        mu_check(start.lnum == 1);
        mu_check(start.col == 3);
        mu_check(end.lnum == 1);
        mu_check(end.col == 2);

        // Delete the lines - 1 through 3
        vimInput("t");

        // 3 lines should've been deleted
        mu_check(vimBufferGetLineCount(curbuf) == 5);
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "lit1") == 0);
    }
}
