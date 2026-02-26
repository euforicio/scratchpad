//
//  MotionWordTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class MotionWordTests: VimTestCase {
    override func setUp() {
        super.setUp()
        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_w() {
        mu_check(vimCursorGetColumn() == 0);

        vimInput("w");

        mu_check(vimCursorGetColumn() == 5);

        vimInput("2");
        vimInput("w");

        mu_check(vimCursorGetColumn() == 12);

        vimInput("1");
        vimInput("0");
        vimInput("w");

        mu_check(vimCursorGetLine() == 2);
        mu_check(vimCursorGetColumn() == 19);
    }

    func test_e() {
        mu_check(vimCursorGetColumn() == 0);

        vimInput("e");

        mu_check(vimCursorGetColumn() == 3);

        vimInput("2");
        vimInput("e");

        mu_check(vimCursorGetColumn() == 10);

        vimInput("1");
        vimInput("0");
        vimInput("0");
        vimInput("e");

        mu_check(vimCursorGetLine() == 3);
        mu_check(vimCursorGetColumn() == 36);
    }

    func test_b() {
        mu_check(vimCursorGetColumn() == 0);

        vimInput("$");

        vimInput("b");
        mu_check(vimCursorGetColumn() == 33);

        vimInput("5");
        vimInput("b");
        mu_check(vimCursorGetColumn() == 12);
    }

}
