//
//  RegistersTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class RegistersTests: VimTestCase {
    override func setUp() {
        super.setUp()

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");
        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_yank_to_register() {
        vimInput("\"");
        vimInput("a");

        vimInput("y");
        vimInput("y");

        let lines = vimRegisterGet("a")

        mu_check(lines.count == 1);
        print("LINE: ", lines[0]);
        XCTAssertEqual(lines[0], "This is the first line of a test file")
    }

    func test_delete_to_register() {
        vimInput("\"");
        vimInput("b");

        vimInput("d");
        vimInput("j");

        let lines = vimRegisterGet("b")

        mu_check(lines.count == 2);
        print("LINE: ", lines[1])
        XCTAssertEqual(lines[1], "This is the second line of a test file")
    }

    func test_extra_yank_doesnt_reset() {
        vimInput("\"");
        vimInput("a");

        vimInput("y");
        vimInput("y");

        vimInput("j");
        vimInput("y");
        vimInput("y");

        let lines = vimRegisterGet("a")

        mu_check(lines.count == 1);
        print("LINE: %", lines[0])
        XCTAssertEqual(lines[0], "This is the first line of a test file")
    }
}
