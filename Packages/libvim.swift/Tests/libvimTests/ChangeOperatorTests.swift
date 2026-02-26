//
//  ChangeOperatorTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-08.
//

import XCTest
import libvim

final class ChangeOperatorTests: VimTestCase {
    override func setUp() {
        super.setUp()

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");

        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_change_word()
    {
        vimInput("c");
        vimInput("w");
        vimInput("a");
        vimInput("b");
        vimInput("c");
        vimKey("<c-c>");

        print("LINE: ", vimBufferGetLine(curbuf, 1));
        mu_check(strcmp(vimBufferGetLine(curbuf, 1),
                        "abc is the first line of a test file") == 0);
    }

    func test_change_line_C()
    {
        vimInput("C");
        vimInput("a");
        vimInput("b");
        vimInput("c");
        vimKey("<c-c>");

        print("LINE: ", vimBufferGetLine(curbuf, 1));
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "abc") == 0);
    }

    func test_change_line_c$()
    {
        vimInput("c");
        vimInput("$");
        vimInput("a");
        vimInput("b");
        vimInput("c");
        vimKey("<c-c>");

        print("LINE: ", vimBufferGetLine(curbuf, 1));
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "abc") == 0);
    }

    func test_change_redo()
    {
        vimInput("c");
        vimInput("w");
        vimInput("a");
        vimInput("b");
        vimInput("c");
        vimKey("<c-c>");
        vimInput("j");
        vimInput("_");
        vimInput(".");

        print("LINE: ", vimBufferGetLine(curbuf, 2));
        mu_check(strcmp(vimBufferGetLine(curbuf, 2),
                        "abc is the second line of a test file") == 0);
    }

    func test_change_macro()
    {
        vimInput("q");
        vimInput("a");

        vimInput("0");
        vimInput("C");
        vimInput("1");
        vimInput("2");
        vimInput("3");
        vimKey("<c-c>");
        vimInput("q");

        vimInput("j");
        vimInput("@");
        vimInput("a");

        print("LINE: ", vimBufferGetLine(curbuf, 2));
        mu_check(strcmp(vimBufferGetLine(curbuf, 2), "123") == 0);
    }
}
