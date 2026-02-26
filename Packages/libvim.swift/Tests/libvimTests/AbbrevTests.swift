//
//  AbbrevTests.swift
//  
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-07.
//

import XCTest
import libvim

final class AbbrevTests: VimTestCase {
    override func setUp() {
        super.setUp()

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");

        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_insert_abbrev_multiple() {

        vimExecute("iabbrev waht what");

        vimInput("I");
        vimInput("w");
        vimInput("a");
        vimInput("h");
        vimInput("t");
        vimInput(" ");
        vimInput("w");
        vimInput("a");
        vimInput("h");
        vimInput("t");
        vimInput(" ");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        print("LINE: \(line)");
        mu_check(strcmp(line, "what what This is the first line of a test file") ==
                 0);
    }

    func test_insert_abbrev_no_recursive() {
        vimExecute("iabbrev waht what");
        vimExecute("iabbrev what what2");

        vimInput("I");
        vimInput("w");
        vimInput("a");
        vimInput("h");
        vimInput("t");
        vimInput(" ");
        vimInput("w");
        vimInput("h");
        vimInput("a");
        vimInput("t");
        vimInput(" ");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        print("LINE: \(line)");
        mu_check(strcmp(line, "what what2 This is the first line of a test file") ==
                 0);
    }

    func test_insert_abbrev_expr() {
        vimExecute("iabbrev <expr> waht col('.')");

        vimInput("I");
        vimInput("w");
        vimInput("a");
        vimInput("h");
        vimInput("t");
        vimInput(" ");
        vimInput("w");
        vimInput("a");
        vimInput("h");
        vimInput("t");
        vimInput(" ");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        print("LINE: \(line)");
        mu_check(strcmp(line, "5 7 This is the first line of a test file") == 0);
    }

    func test_command_abbrev() {
        vimExecute("cabbrev abc def");

        vimInput(":");
        vimInput("a");
        vimInput("b");
        vimInput("c");
        vimInput(" ");
        vimInput("a");
        vimInput("b");
        vimInput("c");
        vimInput(" ");

        let line = vimCommandLineGetText();
        print("LINE: \(line)");
        mu_check(strcmp(line, "def def ") == 0);
    }
}
