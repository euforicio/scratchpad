//
//  GotoTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class GotoTests: VimTestCase {
    var gotoCount = 0
    var lastLnum = 0
    var lastCol = 0
    var lastTarget = Vim.GotoTarget.definition

    override func setUp() {
        super.setUp()

        vimSetGotoCallback { [unowned self] gotoInfo in
            lastLnum = Int(gotoInfo.location.lnum)
            lastCol = Int(gotoInfo.location.col)
            lastTarget = gotoInfo.target
            gotoCount++
            return true
        }

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");

        vimInput("g");
        vimInput("g");
    }

    func test_goto_no_callback() {
        vimSetGotoCallback(nil);
        vimInput("g");
        vimInput("d");

        mu_check(gotoCount == 0);
    }

    func test_goto_definition() {
        vimInput("g");
        vimInput("d");

        mu_check(gotoCount == 1);
        mu_check(lastLnum == 1);
        mu_check(lastCol == 0);
        mu_check(lastTarget == .definition);
    }

    func test_goto_declaration() {
        vimInput("g");
        vimInput("D");

        mu_check(gotoCount == 1);
        mu_check(lastLnum == 1);
        mu_check(lastCol == 0);
        mu_check(lastTarget == .declaration);
    }

    func test_goto_hover() {
        vimInput("g");
        vimInput("h");

        mu_check(gotoCount == 1);
        mu_check(lastLnum == 1);
        mu_check(lastCol == 0);
        mu_check(lastTarget == .hover);
    }

    func test_goto_outline() {
        vimInput("g");
        vimInput("O");

        mu_check(gotoCount == 1);
        mu_check(lastLnum == 1);
        mu_check(lastCol == 0);
        mu_check(lastTarget == .outline);
    }

    // TODO: Implement goto-implementation
//    func test_goto_implementation() {
//        vimInput("<C-]>");
//
//        mu_check(gotoCount == 1);
//        mu_check(lastLnum == 1);
//        mu_check(lastCol == 1);
//        mu_check(lastTarget == .implementation);
//    }
}
