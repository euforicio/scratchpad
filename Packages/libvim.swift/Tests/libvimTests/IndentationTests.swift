//
//  IndentationTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class IndentationTests: VimTestCase {
    var lastRequestType = Vim.FormatRequestType.indentation
    var lastReturnCursor: Bool!
    var lastStartLine = 0
    var lastEndLine = 0
    var lastBuf: Vim.Buffer!
    var lastCmd: String!
    var callCount = 0

    override func setUp() {
        super.setUp()

        vimSetFormatCallback { [unowned self] formatRequest in
            print("onFormat - type: |\(formatRequest.formatType)| returnCursor: |\(formatRequest.returnCursor)| startLine: |\(formatRequest.start.lnum)| endLine: |\(formatRequest.end.lnum)|")

            lastRequestType = formatRequest.formatType
            lastReturnCursor = formatRequest.returnCursor
            lastStartLine = Int(formatRequest.start.lnum)
            lastEndLine = Int(formatRequest.end.lnum)
            lastBuf = formatRequest.buf
            lastCmd = formatRequest.cmd
            callCount++
        }

        // Reset formatexpr, formatprg, and equalprg to defaults
        vimExecute("set formatexpr&");
        vimExecute("set formatprg&");
        vimExecute("setlocal formatprg&");
        vimExecute("set equalprg&");

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");

        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_regression_test_no_crash_after_set_si() {
        vimInput(":set si");
        vimKey("<CR>");
        vimInput("o");

        mu_check(strcmp(vimBufferGetLine(curbuf, 2), "") == 0);
    }

    func test_indent_line() {
        vimInput("=");
        vimInput("=");

        // format callback should've been called
        mu_check(callCount == 1);
        mu_check(lastStartLine == 1);
        mu_check(lastEndLine == 1);
        mu_check(lastRequestType == .indentation)
        XCTAssertNil(lastCmd)
    }

    func test_indent_line_range() {
        vimInput("=");
        vimInput("2");
        vimInput("j");

        mu_check(callCount == 1);
        mu_check(lastStartLine == 1);
        mu_check(lastEndLine == 3);
        mu_check(lastRequestType == .indentation)
        XCTAssertNil(lastCmd)
    }

    func test_indent_line_equalprg() {
        vimExecute("set equalprg=indent");
        vimInput("=");
        vimInput("2");
        vimInput("j");

        mu_check(callCount == 1);
        mu_check(lastStartLine == 1);
        mu_check(lastEndLine == 3);
        mu_check(lastRequestType == .indentation)
        print("EQUALPRG: ", lastCmd!)
        mu_check(strcmp(lastCmd, "indent") == 0);
    }

    func test_format_gq() {
        vimInput("g");
        vimInput("q");
        vimInput("2");
        vimInput("j");

        mu_check(callCount == 1);
        mu_check(lastStartLine == 1);
        mu_check(lastEndLine == 3);
        mu_check(lastRequestType == .formatting);
        XCTAssertFalse(lastReturnCursor)
        XCTAssertNil(lastCmd)
    }

    func test_format_gw() {
        vimInput("g");
        vimInput("w");
        vimInput("j");

        mu_check(callCount == 1);
        mu_check(lastStartLine == 1);
        mu_check(lastEndLine == 2);
        mu_check(lastRequestType == .formatting)
        XCTAssertTrue(lastReturnCursor)
        XCTAssertNil(lastCmd)
    }

    func test_format_gq_buflocal_formatprg() {
        vimExecute("setlocal formatprg=format");
        vimInput("g");
        vimInput("w");
        vimInput("j");

        mu_check(callCount == 1);
        mu_check(lastStartLine == 1);
        mu_check(lastEndLine == 2);
        mu_check(lastRequestType == .formatting)
        XCTAssertTrue(lastReturnCursor)
        print("FORMATPRG: ", lastCmd!)
        mu_check(strcmp(lastCmd, "format") == 0);
    }

    func test_format_gq_buflocal_and_global_formatprg() {
        vimExecute("set formatprg=format1");
        vimExecute("setlocal formatprg=format2");
        vimInput("g");
        vimInput("w");
        vimInput("j");

        mu_check(callCount == 1);
        mu_check(lastStartLine == 1);
        mu_check(lastEndLine == 2);
        mu_check(lastRequestType == .formatting)
        XCTAssertTrue(lastReturnCursor);
        print("FORMATPRG: ", lastCmd!);
        mu_check(strcmp(lastCmd, "format2") == 0);
    }

    func test_formatexpr_overrides_callback() {
        vimExecute("set formatexpr=noop");
        vimInput("g");
        vimInput("q");
        vimInput("j");

        mu_check(callCount == 0);
    }

}
