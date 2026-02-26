//
//  YankTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-07.
//

import XCTest
import libvim

final class YankTests: VimTestCase {
    var yankCount = 0
    var lastYankLineCount = -1
    var lastRegname = Character.nul
    var lastYankLines: [String]!
    var lastStart: Vim.Position?
    var lastEnd: Vim.Position?
    var lastYankType: Vim.MotionType?
    var lastOpChar: Character?

    override func setUp() {
        super.setUp()

        vimSetYankCallback { [unowned self] yankInfo in
            lastYankLineCount = yankInfo.numLines
            lastYankLines = yankInfo.lines
            lastStart = yankInfo.start
            lastEnd = yankInfo.end
            lastYankType = yankInfo.blockType
            lastOpChar = yankInfo.opChar
            lastRegname = yankInfo.regName
            yankCount += 1
        }

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");

        vimInput("g");
        vimInput("g");

        yankCount = 0
    }

    func test_yank_line() {

        vimInput("y");
        vimInput("y");

        mu_check(yankCount == 1);
        mu_check(lastYankLineCount == 1);
        mu_check(lastOpChar == "y");
        mu_check(lastYankType == .lineWise);
        mu_check(lastRegname == .nul)
        mu_check(strcmp(lastYankLines[0], "This is the first line of a test file") == 0);
    };

    func test_yank_register() {

        vimInput("\"");
        vimInput("c");
        vimInput("y");
        vimInput("y");

        mu_check(yankCount == 1);
        mu_check(lastYankLineCount == 1);
        mu_check(lastOpChar == "y");
        mu_check(lastYankType == .lineWise);
        mu_check(lastRegname == "c");
        mu_check(strcmp(lastYankLines[0], "This is the first line of a test file") == 0);
    };

    func test_clipboard_registers() {

        vimInput("\"");
        vimInput("+");
        vimInput("y");
        vimInput("y");

        print("LASTREGNAME: \(lastRegname)")
        mu_check(yankCount == 1);
        mu_check(lastRegname == "+");

        vimInput("\"");
        vimInput("*");
        vimInput("y");
        vimInput("y");

        mu_check(yankCount == 2);
        mu_check(lastRegname == "*");
    };

    func test_delete_line() {

        vimInput("d");
        vimInput("d");

        mu_check(yankCount == 1);
        mu_check(lastYankLineCount == 1);
        mu_check(lastYankType == .lineWise);
        mu_check(strcmp(lastYankLines[0], "This is the first line of a test file") == 0);
    };

    func test_delete_two_lines() {
        vimInput("d");
        vimInput("j");

        mu_check(yankCount == 1);
        mu_check(lastYankLineCount == 2);
        mu_check(lastYankType == .lineWise);
        mu_check(lastOpChar == "d");
        mu_check(strcmp(lastYankLines[0], "This is the first line of a test file") == 0);
        mu_check(strcmp(lastYankLines[1], "This is the second line of a test file") == 0);
    };

    func test_delete_char() {
        vimInput("x");

        mu_check(yankCount == 1);

        mu_check(lastYankLineCount == 1);
        mu_check(lastYankType == .charWise);
        mu_check(lastOpChar == "d");
        mu_check(strcmp(lastYankLines[0], "T") == 0);
    };
}
