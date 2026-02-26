//
//  NormalModeCurswantTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class NormalModeCurswantTests: VimTestCase {
    override func setUp() {
        super.setUp()
        vimBufferOpen("\(collateral)/curswant.txt", 1, 0);

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");
        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_curswant_column2() {
        mu_check(vimCursorGetLine() == 1);

        // Move one character right
        vimInput("l");

        mu_check(vimCursorGetColumn() == 1);
        mu_check(vimCursorGetLine() == 1);

        // Move two characters down
        vimInput("j");
        vimInput("j");

        XCTAssertEqual(vimCursorGetColumn(), 0);
        mu_check(vimCursorGetLine() == 3);

        vimInput("j");
        mu_check(vimCursorGetColumn() == 1);
        mu_check(vimCursorGetLine() == 4);
    }

    func test_curswant_maxcolumn() {
        mu_check(vimCursorGetLine() == 1);

        // Move all the way to the right
        vimInput("$");

        mu_check(vimCursorGetColumn() == 2);
        mu_check(vimCursorGetLine() == 1);

        // Move three characters down
        vimInput("j");
        vimInput("j");
        vimInput("j");

        // Cursor should be all the way to the right
        mu_check(vimCursorGetColumn() == 3);
        mu_check(vimCursorGetLine() == 4);
    }

    func test_curswant_reset() {
        mu_check(vimCursorGetLine() == 1);

        // Move all the way to the right...
        vimInput("$");
        // And the once to the left...
        // This should reset curswant
        vimInput("h");

        mu_check(vimCursorGetColumn() == 1);
        mu_check(vimCursorGetLine() == 1);
        mu_check(vimCursorGetColumnWant() == 1);

        // Move three characters down
        vimInput("j");
        vimInput("j");
        vimInput("j");

        mu_check(vimCursorGetColumn() == 1);
        mu_check(vimCursorGetLine() == 4);
    }

    func test_setting_curswant_explicitly() {
        mu_check(vimCursorGetLine() == 1);

        vimCursorSetColumnWant(Vim.MAXCOL);

        // Move three characters down
        vimInput("j");
        vimInput("j");
        vimInput("j");

        mu_check(vimCursorGetColumn() == 3);
        mu_check(vimCursorGetLine() == 4);
    }
}
