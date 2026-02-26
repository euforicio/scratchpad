//
//  AutoIndentTests.swift
//  
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-07.
//

import XCTest
import libvim

final class AutoIndentTests: VimTestCase {
    var lastLnum = -1

    override func setUp() {
        super.setUp()

        vimKey("<Esc>");
        vimKey("<Esc>");
        vimExecute("e!");

        vimInput("g");
        vimInput("g");
        vimInput("0");

    }

    func test_autoindent_tab_normal_o() {
        vimOptionSetInsertSpaces(false);
        vimSetAutoIndentCallback(alwaysIndent);
        vimInput("o");
        vimInput("a");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        let line2 = "\ta";
        mu_check(strcmp(line, line2) == 0);
        mu_check(lastLnum == 2);
    }

    func test_autoindent_spaces_normal_o() {
        vimOptionSetInsertSpaces(true);
        vimOptionSetTabSize(7);
        vimSetAutoIndentCallback(alwaysIndent);
        vimInput("o");
        vimInput("a");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        let line2 = "       a";
        mu_check(strcmp(line, line2) == 0);
        mu_check(lastLnum == 2);
    }

    func test_autounindent_spaces_normal_o() {
        vimOptionSetInsertSpaces(true);
        vimOptionSetTabSize(2);
        vimSetAutoIndentCallback(alwaysUnindent);
        vimInput("o");
        vimInput("  a");
        vimKey("<cr>");
        vimInput("b");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        let line2 = "b";
        mu_check(strcmp(line, line2) == 0);
        mu_check(lastLnum == 3);
    }

    func test_autounindent_double_spaces_overflow_normal_o() {
        vimOptionSetInsertSpaces(true);
        vimOptionSetTabSize(2);
        vimSetAutoIndentCallback(alwaysUnindentDouble);
        vimInput("o");
        vimInput("  a");
        vimKey("<cr>");
        vimInput("b");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        let line2 = "b";
        mu_check(strcmp(line, line2) == 0);
        mu_check(lastLnum == 3);
    }

    func test_autounindent_double_spaces_normal_o() {
        vimOptionSetInsertSpaces(true);
        vimOptionSetTabSize(2);
        vimSetAutoIndentCallback(alwaysUnindentDouble);
        vimInput("o");
        vimInput("    a");
        vimKey("<cr>");
        vimInput("b");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        let line2 = "b";
        mu_check(strcmp(line, line2) == 0);
        mu_check(lastLnum == 3);
    }

    func test_autounindent_spaces_no_indent() {
        vimOptionSetInsertSpaces(true);
        vimOptionSetTabSize(2);
        vimSetAutoIndentCallback(alwaysUnindent);
        vimInput("A");
        vimKey("<cr>");
        vimInput("b");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        let line2 = "b";
        mu_check(strcmp(line, line2) == 0);
        mu_check(lastLnum == 2);
    }

    func test_autoindent_double_tab() {
        vimOptionSetInsertSpaces(false);
        vimSetAutoIndentCallback(alwaysIndentDouble);
        vimInput("A");
        vimKey("<cr>");
        vimInput("a");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        print("LINE: |\(line)|");
        let line2 = "\t\ta";
        mu_check(strcmp(line, line2) == 0);
        mu_check(lastLnum == 2);
    }

    func test_autoindent_tab_insert_cr() {
        vimOptionSetInsertSpaces(false);
        vimSetAutoIndentCallback(alwaysIndent);
        vimInput("A");
        vimKey("<cr>");
        vimInput("a");
        vimKey("<cr>");
        vimInput("a");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        print("LINE: |\(line)|", line);
        let line3 = "\t\ta";
        mu_check(strcmp(line, line3) == 0);
        mu_check(lastLnum == 3);
    }
}

extension AutoIndentTests {
    func alwaysIndent(lnum: Int, buf: Vim.Buffer, prevLine: String?, line: String?) -> Int {
        print("\(#function) - lnum: \(lnum)")
        lastLnum = lnum;
        return 1;
    }

    func alwaysIndentDouble(lnum: Int, buf: Vim.Buffer, prevLine: String?, line: String?) -> Int {
        print("\(#function) - lnum: \(lnum)")
        lastLnum = lnum;
        return 2;
    }

    func alwaysUnindent(lnum: Int, buf: Vim.Buffer, prevLine: String?, line: String?) -> Int {
        print("\(#function) - lnum: \(lnum)")
        lastLnum = lnum;
        return -1;
    }

    func alwaysUnindentDouble(lnum: Int, buf: Vim.Buffer, prevLine: String?, line: String?) -> Int {
        print("\(#function) - lnum: \(lnum)")
        lastLnum = lnum;
        return -2;
    }

    func neverIndent(lnum: Int, buf: Vim.Buffer, prevLine: String?, line: String?) -> Int {
        print("\(#function) - lnum: \(lnum)")
        lastLnum = lnum;
        return 0;
    }
}

