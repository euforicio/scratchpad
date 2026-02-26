//
//  InesrtModeTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class InesrtModeTests: VimTestCase {

    override func setUp() {
        super.setUp()

        vimBufferOpen(testfile, 1, 0)

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");

        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_insert_beginning()
    {
        vimInput("I");
        vimInput("a");
        vimInput("b");
        vimInput("c");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        mu_check(strcmp(line, "abcThis is the first line of a test file") == 0);
    }

    func test_insert_cr()
    {
        vimInput("I");
        vimInput("a");
        vimInput("b");
        vimInput("c");
        vimKey("<CR>");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        mu_check(strcmp(line, "This is the first line of a test file") == 0);

        let prevLine = vimBufferGetLine(curbuf, vimCursorGetLine() - 1);
        mu_check(strcmp(prevLine, "abc") == 0);
    }

    func test_insert_prev_line()
    {
        vimInput("O");
        vimInput("a");
        vimInput("b");
        vimInput("c");
        mu_check(vimCursorGetLine() == 1);

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());

        mu_check(strcmp(line, "abc") == 0);
    }

    func test_insert_next_line()
    {
        vimInput("o");
        vimInput("a");
        vimInput("b");
        vimInput("c");

        mu_check(vimCursorGetLine() == 2);

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());

        mu_check(strcmp(line, "abc") == 0);
    }
    func test_insert_end()
    {
        vimInput("A");
        vimInput("a");
        vimInput("b");
        vimInput("c");
        let line = vimBufferGetLine(curbuf, vimCursorGetLine());

        XCTAssertEqual(line, "This is the first line of a test fileabc")
    }

    func test_insert_changed_ticks()
    {
        let buf = vimBufferOpen("\(collateral)/curswant.txt", 1, 0);

        let initialVersion = vimBufferGetLastChangedTick(buf)
        var newVersion: Int
        vimInput("i");
        newVersion = vimBufferGetLastChangedTick(buf);
        mu_check(newVersion == initialVersion);

        vimInput("a");
        newVersion = vimBufferGetLastChangedTick(buf);
        mu_check(newVersion == initialVersion + 1);

        vimInput("b");
        newVersion = vimBufferGetLastChangedTick(buf);
        mu_check(newVersion == initialVersion + 2);

        vimInput("c");
        newVersion = vimBufferGetLastChangedTick(buf);
        mu_check(newVersion == initialVersion + 3);
    }

    /* Ctrl_v inserts a character literal */
    func test_insert_mode_ctrlv()
    {
        vimInput("O");

        mu_check(vimGetSubMode() == .none);

        // Character literal mode
        vimKey("<c-v>");
        mu_check(vimGetSubMode() == .insertLiteral);

        vimInput("1");
        mu_check(vimGetSubMode() == .insertLiteral);
        vimInput("2");
        mu_check(vimGetSubMode() == .insertLiteral);
        vimInput("6");
        mu_check(vimGetSubMode() == .none);

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());

        mu_check(strcmp(line, "~") == 0);
    }

    func test_insert_mode_ctrlv_no_digit()
    {
        vimInput("O");

        mu_check(vimGetSubMode() == .none);
        // Character literal mode
        vimKey("<c-v>");
        mu_check(vimGetSubMode() == .insertLiteral);

        // Jump out of character literal mode by entering a non-digit character
        vimInput("a");
        mu_check(vimGetSubMode() == .none);

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());

        mu_check(strcmp(line, "a") == 0);
    }

    func test_insert_mode_ctrlv_newline()
    {
        vimInput("O");

        // Character literal mode
        mu_check(vimGetSubMode() == .none);
        vimKey("<c-v>");

        mu_check(vimGetSubMode() == .insertLiteral);
        // Jump out of character literal mode by entering a non-digit character
        vimKey("<cr>");
        mu_check(vimGetSubMode() == .none);

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        mu_check(line.first! == Character(Unicode.Scalar(CUnsignedChar(CChar(13)))))
    }

    func test_insert_mode_utf8()
    {
        vimInput("O");

        // Character literal mode
        vimInput("κόσμε");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        mu_check(strcmp(line, "κόσμε") == 0);
    }

    // Regression test for onivim/oni2#1720
    func test_insert_mode_utf8_special_byte()
    {
        vimInput("O");

        let input = String(cString: [ CUnsignedChar(232), 128, 133, 0 ])
        vimInput(input);

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        XCTAssertEqual(line, input)
    }

    func test_insert_mode_arrow_breaks_undo()
    {
        let initialLineCount = vimBufferGetLineCount(curbuf)

        // Add a line above...
        vimInput("O");

        // Type a, left arrow, b, but join undo
        vimInput("a");
        vimKey("<left>");
        vimInput("b");

        mu_check(vimBufferGetLineCount(curbuf) == initialLineCount + 1);
        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        mu_check(strcmp(line, "ba") == 0);

        // Undoing should undo edit past arrow key being pressed,
        // default vim behavior.
        vimKey("<esc>");
        vimInput("u");
        let lineAfterUndo = vimBufferGetLine(curbuf, vimCursorGetLine());
        mu_check(strcmp(lineAfterUndo, "a") == 0);
        mu_check(vimBufferGetLineCount(curbuf) == initialLineCount + 1);
    }

    func test_insert_mode_arrow_key_join_undo()
    {
        let initialLineCount = vimBufferGetLineCount(curbuf)

        // Add a line above...
        vimInput("O");

        // Type a, left arrow, b, but join undo
        vimInput("a");

        // <C-g>U joins the undo for left/right arrow
        vimKey("<C-g>");
        vimInput("U");

        // ...and then use arrow
        vimKey("<left>");
        vimInput("b");

        mu_check(vimBufferGetLineCount(curbuf) == initialLineCount + 1);
        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        mu_check(strcmp(line, "ba") == 0);

        // Undoing should undo entire edit
        vimKey("<esc>");
        vimInput("u");
        mu_check(vimBufferGetLineCount(curbuf) == initialLineCount);
    }

    func test_insert_mode_test_count_i() {
        vimKey("3");
        vimKey("i");

        vimInput("abc");
        vimKey("<esc>");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        XCTAssertEqual(line, "abcabcabcThis is the first line of a test file")
    }

    func test_insert_mode_test_count_A()
    {
        vimKey("4");
        vimKey("A");

        vimInput("abc");
        vimKey("<esc>");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        mu_check(strcmp(line, "This is the first line of a test fileabcabcabcabc") == 0);
    }

    func test_insert_mode_test_count_O()
    {
        vimKey("2");
        vimKey("O");

        vimInput("abc");
        vimKey("<esc>");

        let line1 = vimBufferGetLine(curbuf, 1);
        mu_check(strcmp(line1, "abc") == 0);

        let line2 = vimBufferGetLine(curbuf, 1);
        mu_check(strcmp(line2, "abc") == 0);

        mu_check(vimBufferGetLineCount(curbuf) == 5);
    }

    func test_insert_mode_test_ctrl_o_motion()
    {
        vimKey("I");
        XCTAssert(vimGetMode().contains(.insert))
        mu_check(vimCursorGetLine() == 1);

        vimKey("<c-o>");
        XCTAssert(vimGetMode().contains(.normal))

        vimKey("j");
        mu_check(vimCursorGetLine() == 2);
        XCTAssert(vimGetMode().contains(.insert))
    }

    func test_insert_mode_test_ctrl_o_delete()
    {
        let startingLineCount = vimBufferGetLineCount(curbuf)
        vimKey("I");
        XCTAssert(vimGetMode().contains(.insert))
        mu_check(vimCursorGetLine() == 1);

        vimKey("<c-o>");
        XCTAssert(vimGetMode().contains(.normal))


        vimKey("d");
        XCTAssertFalse(vimGetMode().contains(.insert))
        vimKey("d");
        XCTAssert(vimGetMode().contains(.insert))

        mu_check(vimBufferGetLineCount(curbuf) < startingLineCount);
    }

    func test_insert_mode_test_ctrl_o_delete_translate()
    {
        vimKey("I");
        XCTAssert(vimGetMode().contains(.insert))
        mu_check(vimCursorGetLine() == 1);

        vimKey("<c-o>");
        XCTAssert(vimGetMode().contains(.normal))

        vimKey("D");
        XCTAssert(vimGetMode().contains(.insert))

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        mu_check(strcmp(line, "") == 0);
    }

    func test_insert_mode_test_ctrl_o_change()
    {
        vimKey("i");
        XCTAssert(vimGetMode().contains(.insert))
        mu_check(vimCursorGetLine() == 1);

        vimKey("<c-o>");
        XCTAssert(vimGetMode().contains(.normal))


        vimKey("C");
        XCTAssert(vimGetMode().contains(.insert))

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        mu_check(strcmp(line, "") == 0);
    }

}
