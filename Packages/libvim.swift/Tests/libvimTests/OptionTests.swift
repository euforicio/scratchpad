//
//  OptionTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class OptionTests: VimTestCase {
    var optionSetCount = 0
    var lastOptionSet: Vim.OptionSet!

    override func setUp() {
        super.setUp()

        vimSetOptionSetCallback { [unowned self] in
            lastOptionSet = $0
            optionSetCount += 1
        }

        vimBufferOpen(lines100, 1, 0);

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");
        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_get_set_tab_options() {
        vimOptionSetTabSize(4);
        mu_check(vimOptionGetTabSize() == 4);

        vimOptionSetTabSize(2);
        mu_check(vimOptionGetTabSize() == 2);

        vimOptionSetInsertSpaces(true)
        XCTAssertTrue(vimOptionGetInsertSpaces())

        vimOptionSetInsertSpaces(false)
        XCTAssertFalse(vimOptionGetInsertSpaces())
    }

    func test_insert_spaces() {
        vimOptionSetTabSize(3);
        vimOptionSetInsertSpaces(TRUE);

        vimInput("I");
        vimKey("<tab>");

        var line = vimBufferGetLine(curbuf, 1);
        XCTAssertEqual(line, "   Line 1")

        vimKey("<bs>");
        line = vimBufferGetLine(curbuf, 1);
        XCTAssertEqual(line, "Line 1")

        vimOptionSetTabSize(4);

        vimKey("<tab>");
        vimKey("<tab>");
        line = vimBufferGetLine(curbuf, 1);
        XCTAssertEqual(line, "        Line 1")

        vimKey("<bs>");
        line = vimBufferGetLine(curbuf, 1);
        XCTAssertEqual(line, "    Line 1")
    }

    func test_insert_tabs() {
        vimOptionSetTabSize(3);
        vimOptionSetInsertSpaces(FALSE);

        vimInput("I");
        vimKey("<tab>");

        var line = vimBufferGetLine(curbuf, 1);
        XCTAssertEqual(line, "\tLine 1")

        vimKey("<bs>");
        line = vimBufferGetLine(curbuf, 1);
        XCTAssertEqual(line, "Line 1")

        vimOptionSetTabSize(4);

        vimKey("<tab>");
        vimKey("<tab>");
        line = vimBufferGetLine(curbuf, 1);
        XCTAssertEqual(line, "\t\tLine 1")

        vimKey("<bs>");
        line = vimBufferGetLine(curbuf, 1);
        XCTAssertEqual(line, "\tLine 1")
    }

    func test_tab_size() {
        vimOptionSetTabSize(3);
        var calculatedTabSize = chartabsize("\t", 0);
        mu_check(calculatedTabSize == 3);

        vimOptionSetTabSize(4);
        calculatedTabSize = chartabsize("\t", 0);
        mu_check(calculatedTabSize == 4);
    }

    func test_encoding_cannot_change() {

        XCTAssertEqual(p_enc, "utf-8")
        vimExecute("set encoding=latin1");
        XCTAssertEqual(p_enc, "utf-8")
    }

    func test_opt_relative_number() {
        vimExecute("set rnu");
        mu_check(optionSetCount == 1);
        XCTAssertEqual(lastOptionSet.fullname, "relativenumber")
        XCTAssertEqual(lastOptionSet.shortname, "rnu")
        mu_check(lastOptionSet.numval == 1);
        mu_check(lastOptionSet.type == 1);

        vimExecute("set nornu");
        mu_check(optionSetCount == 2);
        XCTAssertEqual(lastOptionSet.fullname, "relativenumber")
        XCTAssertEqual(lastOptionSet.shortname, "rnu")
        mu_check(lastOptionSet.numval == 0);
        mu_check(lastOptionSet.type == 1);
    }

    func test_opt_codelens() {
        vimExecute("set codelens");
        mu_check(optionSetCount == 1);
        XCTAssertEqual(lastOptionSet.fullname, "codelens")
        XCTAssertNil(lastOptionSet.shortname)
        mu_check(lastOptionSet.numval == 1);
        mu_check(lastOptionSet.type == 1);

        vimExecute("set nocodelens");
        mu_check(optionSetCount == 2);
        XCTAssertEqual(lastOptionSet.fullname, "codelens")
        XCTAssertNil(lastOptionSet.shortname)
        mu_check(lastOptionSet.numval == 0);
        mu_check(lastOptionSet.type == 1);
    }

    func test_opt_minimap() {
        vimExecute("set minimap");
        mu_check(optionSetCount == 1);
        XCTAssertEqual(lastOptionSet.fullname, "minimap")
        XCTAssertNil(lastOptionSet.shortname)
        mu_check(lastOptionSet.numval == 1);
        mu_check(lastOptionSet.type == 1);

        vimExecute("set nominimap");
        mu_check(optionSetCount == 2);
        XCTAssertEqual(lastOptionSet.fullname, "minimap")
        XCTAssertNil(lastOptionSet.shortname)
        mu_check(lastOptionSet.numval == 0);
        mu_check(lastOptionSet.type == 1);
    }

    func test_opt_smoothscroll() {
        vimExecute("set smoothscroll");
        mu_check(optionSetCount == 1);
        XCTAssertEqual(lastOptionSet.fullname, "smoothscroll")
        XCTAssertNil(lastOptionSet.shortname)
        mu_check(lastOptionSet.numval == 1);
        mu_check(lastOptionSet.type == 1);

        vimExecute("set nosmoothscroll");
        mu_check(optionSetCount == 2);
        XCTAssertEqual(lastOptionSet.fullname, "smoothscroll")
        XCTAssertNil(lastOptionSet.shortname)
        mu_check(lastOptionSet.numval == 0);
        mu_check(lastOptionSet.type == 1);
    }

    func test_opt_runtimepath() {
        vimExecute("set runtimepath=abc");
        mu_check(optionSetCount == 1);
        XCTAssertEqual(lastOptionSet.fullname, "runtimepath")
        XCTAssertEqual(lastOptionSet.shortname, "rtp")
        XCTAssertEqual(lastOptionSet.stringval, "abc")
        mu_check(lastOptionSet.type == 0);
    }

    func test_opt_backspace_string() {
        vimExecute("set backspace=indent,eol");
        mu_check(optionSetCount == 1);
        XCTAssertEqual(lastOptionSet.fullname, "backspace")
        XCTAssertEqual(lastOptionSet.shortname, "bs")
        XCTAssertEqual(lastOptionSet.stringval, "indent,eol")
        mu_check(lastOptionSet.type == 0);
    }
}
