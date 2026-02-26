//
//  ToggleCommentTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class ToggleCommentTests: VimTestCase {
    func simulateAddCommentCallback(_ buf: Vim.Buffer, _ start: Vim.LineNumber, _ end: Vim.LineNumber) -> [String]? {
        let count = end - start + 1
        var lines = [String]()
        if count >= 1 {
            lines.append("//This is the first line of a test file")
        }
        if count >= 2 {
            lines.append("//This is the second line of a test file")
        }
        if count >= 3 {
            lines.append("//This is the third line of a test file")
        }
        return lines
    }

    func simulateRemoveCommentCallback(_ buf: Vim.Buffer, _ start: Vim.LineNumber, _ end: Vim.LineNumber) -> [String]? {
        let count = end - start + 1
        var lines = [String]()
        if count >= 1 {
            lines.append("This is the first line of a test file")
        }
        if count >= 2 {
            lines.append("This is the second line of a test file")
        }
        if count >= 3 {
            lines.append("This is the third line of a test file")
        }
        return lines
    }


    override func setUp() {
        super.setUp()

        vimKey("<Esc>");
        vimKey("<Esc>");
        vimExecute("e!");

        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_toggle_uncommented() {
        vimSetToggleCommentsCallback(simulateAddCommentCallback)
        vimInput("g");
        vimInput("c");
        vimInput("c");

        var line = vimBufferGetLine(curbuf, vimCursorGetLine());
        print("LINE: ", line);

        mu_check(strcmp(line, "//This is the first line of a test file") == 0);
    }

    func test_toggle_there_and_back_again() {
        vimSetToggleCommentsCallback(simulateAddCommentCallback);
        vimInput("g");
        vimInput("c");
        vimInput("c");

        var line = vimBufferGetLine(curbuf, vimCursorGetLine());
        print("LINE: ", line)

        mu_check(strcmp(line, "//This is the first line of a test file") == 0);

        vimSetToggleCommentsCallback(simulateRemoveCommentCallback);
        vimInput("g");
        vimInput("c");
        vimInput("c");

        line = vimBufferGetLine(curbuf, vimCursorGetLine());
        print("LINE: ", line);

        mu_check(strcmp(line, "This is the first line of a test file") == 0);
    }

    func test_toggle_uncommented_visual() {
        vimSetToggleCommentsCallback(simulateAddCommentCallback);
        vimInput("V");
        vimInput("g");
        vimInput("c");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        print("LINE: ", line);

        mu_check(strcmp(line, "//This is the first line of a test file") == 0);
    }

    func test_toggle_uncommented_visual_multi() {
        vimSetToggleCommentsCallback(simulateAddCommentCallback);
        vimInput("V");
        vimInput("j");

        mu_check(vimCursorGetLine() == 2);

        vimInput("g");
        vimInput("c");

        let line1 = vimBufferGetLine(curbuf, 1);
        print("LINE1: |\(line1)|");
        mu_check(strcmp(line1, "//This is the first line of a test file") == 0);

        let line2 = vimBufferGetLine(curbuf, 2);
        print("LINE2: |\(line2)|");
        mu_check(strcmp(line2, "//This is the second line of a test file") == 0);

        let line3 = vimBufferGetLine(curbuf, 3);
        print("LINE3: |\(line3)|");
        mu_check(strcmp(line3, "This is the third line of a test file") == 0);
    }

    func test_toggle_there_and_back_again_visual_multi()
    {
        vimSetToggleCommentsCallback(simulateAddCommentCallback);
        vimInput("V");
        vimInput("j");
        vimInput("g");
        vimInput("c");

        var line1 = vimBufferGetLine(curbuf, 1);
        print("LINE1: |\(line1)|");
        mu_check(strcmp(line1, "//This is the first line of a test file") == 0);

        var line2 = vimBufferGetLine(curbuf, 2);
        print("LINE2: |\(line2)|");
        mu_check(strcmp(line2, "//This is the second line of a test file") == 0);

        var line3 = vimBufferGetLine(curbuf, 3);
        print("LINE3: |\(line3)|");
        mu_check(strcmp(line3, "This is the third line of a test file") == 0);

        // and back again
        vimSetToggleCommentsCallback(simulateRemoveCommentCallback);

        vimInput("V");
        vimInput("j");
        vimInput("g");
        vimInput("c");

        line1 = vimBufferGetLine(curbuf, 1);
        print("LINE1: |\(line1)|", line1);
        mu_check(strcmp(line1, "This is the first line of a test file") == 0);

        line2 = vimBufferGetLine(curbuf, 2);
        print("LINE2: |\(line2)|");
        mu_check(strcmp(line2, "This is the second line of a test file") == 0);

        line3 = vimBufferGetLine(curbuf, 3);
        print("LINE3: |\(line3)|");
        mu_check(strcmp(line3, "This is the third line of a test file") == 0);
    }

    func test_undo() {
        vimSetToggleCommentsCallback(simulateAddCommentCallback);
        vimInput("g");
        vimInput("c");
        vimInput("c");

        var line = vimBufferGetLine(curbuf, vimCursorGetLine());
        print("LINE: ", line);

        mu_check(strcmp(line, "//This is the first line of a test file") == 0);

        vimInput("u");

        line = vimBufferGetLine(curbuf, vimCursorGetLine());
        print("LINE, after undo: ", line);

        mu_check(strcmp(line, "This is the first line of a test file") == 0);
    }

    func test_undo_visual_multi() {
        vimSetToggleCommentsCallback(simulateAddCommentCallback);
        vimInput("V");
        vimInput("j");

        mu_check(vimCursorGetLine() == 2);

        vimInput("g");
        vimInput("c");

        var line1 = vimBufferGetLine(curbuf, 1);
        print("LINE1: |\(line1)|");
        mu_check(strcmp(line1, "//This is the first line of a test file") == 0);

        var line2 = vimBufferGetLine(curbuf, 2);
        print("LINE2: |\(line2)|");
        mu_check(strcmp(line2, "//This is the second line of a test file") == 0);

        var line3 = vimBufferGetLine(curbuf, 3);
        print("LINE3: |\(line3)|");
        mu_check(strcmp(line3, "This is the third line of a test file") == 0);

        // and back again

        vimInput("u");

        line1 = vimBufferGetLine(curbuf, 1);
        print("LINE1, after undo: |\(line1)|");
        mu_check(strcmp(line1, "This is the first line of a test file") == 0);

        line2 = vimBufferGetLine(curbuf, 2);
        print("LINE2, after undo: |\(line2)|");
        mu_check(strcmp(line2, "This is the second line of a test file") == 0);

        line3 = vimBufferGetLine(curbuf, 3);
        print("LINE3, after undo: |\(line3)|");
        mu_check(strcmp(line3, "This is the third line of a test file") == 0);
    }

    func test_cursor_toggle_there_and_back_again()
    {
        vimSetToggleCommentsCallback(simulateAddCommentCallback);
        vimInput("g");
        vimInput("c");
        vimInput("c");

        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 0);

        // and back again
        vimSetToggleCommentsCallback(simulateRemoveCommentCallback);

        vimInput("g");
        vimInput("c");
        vimInput("c");

        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 0);
    }

    func test_cursor_toggle_there_and_back_again_visual_multi()
    {
        vimSetToggleCommentsCallback(simulateAddCommentCallback);
        vimInput("V");
        vimInput("j");

        mu_check(vimCursorGetLine() == 2);
        mu_check(vimCursorGetColumn() == 0);

        vimInput("g");
        vimInput("c");

        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 0);

        // and back again

        vimSetToggleCommentsCallback(simulateRemoveCommentCallback);
        vimInput("V");
        vimInput("j");

        mu_check(vimCursorGetLine() == 2);
        mu_check(vimCursorGetColumn() == 0);

        vimInput("g");
        vimInput("c");

        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 0);
    }

    func test_regression_Vc() {
        vimInput("V");
        vimInput("c");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        print("LINE: |\(line)|");

        mu_check(strcmp(line, "") == 0);
    }

}
