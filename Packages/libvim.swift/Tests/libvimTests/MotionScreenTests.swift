//
//  MotionScreenTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class MotionScreenTests: VimTestCase {
    override func setUp() {
        super.setUp()
        vimBufferOpen("\(collateral)/lines_100.txt", 1, 0);
        vimKey("<Esc>");
        vimKey("<Esc>");
        vimExecute("e!");
        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func simpleScreenLineCallback(_ motion: Vim.ScreenLineMotion, _ count: Int, _ startLine: Vim.LineNumber) -> Vim.LineNumber {
        switch motion {
        case .h: 10
        case .m: 20
        case .l: 30
        }
    }

    func erroneousScreenLineCallback(_ motion: Vim.ScreenLineMotion, _ count: Int, _ startLine: Vim.LineNumber) -> Vim.LineNumber {
        switch motion {
        case .h: -1
        case .m: 101
        case .l: 999
        }
    }

    func simplePositionCallback(_ dir: Vim.Direction, _ count: Int, _ srcLine: Vim.LineNumber, _ srcColumn: Vim.ColumnNumber, _ curswant: Vim.ColumnNumber) -> (Vim.LineNumber, Vim.ColumnNumber) {
        if dir == .backward {
            (1, 0)
        } else {
            (100, 0)
        }
    }

    func sameLinePositionCallback(_ dir: Vim.Direction, _ count: Int, _ srcLine: Vim.LineNumber, _ srcColumn: Vim.ColumnNumber, _ curswant: Vim.ColumnNumber) -> (Vim.LineNumber, Vim.ColumnNumber) {
        (srcLine, dir == .backward ? 0 : srcColumn + 1)
    }

    func maxColPositionCallback(_ dir: Vim.Direction, _ count: Int, _ srcLine: Vim.LineNumber, _ srcColumn: Vim.ColumnNumber, _ curswant: Vim.ColumnNumber) -> (Vim.LineNumber, Vim.ColumnNumber) {
        (srcLine + (dir == .backward ? -1 : 1), Vim.MAXCOL)
    }

    func erroneousPositionCallback(_ dir: Vim.Direction, _ count: Int, _ srcLine: Vim.LineNumber, _ srcColumn: Vim.ColumnNumber, _ curswant: Vim.ColumnNumber) -> (Vim.LineNumber, Vim.ColumnNumber) {
        (srcLine, dir == .backward ? -1 : 10000)
    }

    func test_no_callback()
    {
        // When no callback is set, the cursor should not move at all.
        vimSetCursorMoveScreenLineCallback(nil);

        vimInput("H");

        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 0);

        vimInput("L");

        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 0);

        vimInput("M");

        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 0);

        vimInput("j");

        vimInput("H");

        mu_check(vimCursorGetLine() == 2);
        mu_check(vimCursorGetColumn() == 0);

        vimInput("L");

        mu_check(vimCursorGetLine() == 2);
        mu_check(vimCursorGetColumn() == 0);

        vimInput("M");

        mu_check(vimCursorGetLine() == 2);
        mu_check(vimCursorGetColumn() == 0);
    }

    func test_simple_callback() {
        // When no callback is set, the cursor should not move at all.
        vimSetCursorMoveScreenLineCallback(simpleScreenLineCallback);

        vimInput("H");

        mu_check(vimCursorGetLine() == 10);
        mu_check(vimCursorGetColumn() == 0);

        vimInput("L");

        mu_check(vimCursorGetLine() == 30);
        mu_check(vimCursorGetColumn() == 0);

        vimInput("M");

        mu_check(vimCursorGetLine() == 20);
        mu_check(vimCursorGetColumn() == 0);
    }

    func test_erroneous_callback() {
        // When no callback is set, the cursor should not move at all.
        vimSetCursorMoveScreenLineCallback(erroneousScreenLineCallback);

        vimInput("H");

        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 0);

        vimInput("L");

        mu_check(vimCursorGetLine() == 100);
        mu_check(vimCursorGetColumn() == 0);

        vimInput("M");

        mu_check(vimCursorGetLine() == 100);
        mu_check(vimCursorGetColumn() == 0);
    }

    func test_gj_gk_motion() {
        // When no callback is set, the cursor should not move at all.
        vimSetCursorMoveScreenPositionCallback(simplePositionCallback);

        vimInput("gj");

        mu_check(vimCursorGetLine() == 100);
        mu_check(vimCursorGetColumn() == 0);

        vimInput("gk");

        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 0);
    }

    func test_gk_motion_same_line() {
        // When no callback is set, the cursor should not move at all.
        vimSetCursorMoveScreenPositionCallback(sameLinePositionCallback);

        vimInput("3l");
        vimInput("d");
        vimInput("gk");

        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "e 1") == 0);
    }

    func test_gj_motion_same_line() {
        // When no callback is set, the cursor should not move at all.
        vimSetCursorMoveScreenPositionCallback(sameLinePositionCallback);

        vimInput("3l");
        mu_check(vimCursorGetColumn() == 3);

        vimInput("d");
        vimInput("gj");

        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 3);
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "Lin 1") == 0);
    }

    func test_erroneous_position_callback() {
        // When no callback is set, the cursor should not move at all.
        vimSetCursorMoveScreenPositionCallback(erroneousPositionCallback);

        vimInput("gk");

        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 0);

        vimInput("gj");

        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumn() == 5);
    }

    func test_curswant() {
        vimBufferOpen("\(collateral)/curswant.txt", 1, 0);
        // When no callback is set, the cursor should not move at all.
        vimSetCursorMoveScreenPositionCallback(maxColPositionCallback);

        vimInput("$");
        vimInput("gj");

        mu_check(vimCursorGetLine() == 2);
        mu_check(vimCursorGetColumn() == 1);

        vimInput("gj");
        mu_check(vimCursorGetLine() == 3);
        mu_check(vimCursorGetColumn() == 0);

        vimInput("gj");
        mu_check(vimCursorGetLine() == 4);
        mu_check(vimCursorGetColumn() == 3);
    }
}
