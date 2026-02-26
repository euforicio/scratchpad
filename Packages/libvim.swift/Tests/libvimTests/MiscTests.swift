//
//  MiscTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class MiscTests: VimTestCase {
    var displayVersionCount = 0
    var displayIntroCount = 0

    override func setUp() {
        super.setUp()

        vimSetDisplayIntroCallback { self.displayIntroCount++ }
        vimSetDisplayVersionCallback { self.displayVersionCount++ }

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");

        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_intro_command() {
        mu_check(displayIntroCount == 0);
        vimExecute("intro");
        mu_check(displayIntroCount == 1);
    }

    func test_version_command() {
        mu_check(displayVersionCount == 0);
        vimExecute("version");
        mu_check(displayVersionCount == 1);
    }
}
