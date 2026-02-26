//
//  BasicCmdlineTests.swift
//  
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-08.
//

import XCTest
import libvim

final class BasicCmdlineTests: VimTestCase {
    var cmdLineEnterCount = 0;
    var cmdLineLeaveCount = 0;
    var cmdLineChangedCount = 0;

    override func setUp() {
        super.setUp()

        vimSetAutoCommandCallback { [unowned self] command, _ in
            switch command {
            case .cmdLineChanged: cmdLineChangedCount++
            case .cmdLineEnter: cmdLineEnterCount++
            case .cmdLineLeave: cmdLineLeaveCount++
            default: break
            }
        }

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");
    }

    func test_cmdline_esc() {
        vimInput(":");
        XCTAssert(vimGetMode().contains(.cmdLine))
        vimKey("<esc>");
        XCTAssert(vimGetMode().contains(.normal))
    }

    func test_cmdline_enter() {
        vimInput(":");
        XCTAssert(vimGetMode().contains(.cmdLine))
        vimKey("<cr>");
        XCTAssert(vimGetMode().contains(.normal))
    }

    func test_cmdline_autocmds() {
        let buffer = vimBufferGetCurrent();
        let lc = vimBufferGetLineCount(buffer);
        mu_check(lc == 3);

        mu_check(cmdLineEnterCount == 0);
        vimInput(":");
        mu_check(cmdLineEnterCount == 1);
        mu_check(cmdLineChangedCount == 0);

        vimInput("a");
        mu_check(cmdLineChangedCount == 1);

        vimInput("b");
        mu_check(cmdLineChangedCount == 2);

        vimInput("c");
        mu_check(cmdLineChangedCount == 3);
        mu_check(cmdLineLeaveCount == 0);
        vimKey("<esc>");
        mu_check(cmdLineLeaveCount == 1);

        XCTAssert(vimGetMode().contains(.normal))
    }

    func test_cmdline_no_execute_with_esc() {
        let buffer = vimBufferGetCurrent();
        var lc = vimBufferGetLineCount(buffer);
        mu_check(lc == 3);

        vimInput(":");
        vimInput("1");
        vimInput(",");
        vimInput("2");
        vimInput("d");
        vimKey("<c-c>");
        XCTAssert(vimGetMode().contains(.normal))

        lc = vimBufferGetLineCount(buffer);
        mu_check(lc == 3);
    }

    func test_cmdline_execute() {
        let buffer = vimBufferGetCurrent();
        var lc = vimBufferGetLineCount(buffer);
        mu_check(lc == 3);

        vimInput(":");
        vimInput("1");
        vimInput(",");
        vimInput("2");
        vimInput("d");
        vimKey("<cr>");
        XCTAssert(vimGetMode().contains(.normal))

        lc = vimBufferGetLineCount(buffer);
        mu_check(lc == 1);
    }

    func test_cmdline_substitution() {
        let buffer = vimBufferGetCurrent();
        let lc = vimBufferGetLineCount(buffer);
        mu_check(lc == 3);

        vimInput(":");
        vimInput("s");
        vimInput("!");
        vimInput("T");
        vimInput("!");
        vimInput("A");
        vimInput("!");
        vimInput("g");
        vimKey("<cr>");

        mu_check(strcmp(vimBufferGetLine(buffer, 1),
                        "Ahis is the first line of a test file") == 0);
    }

    func test_cmdline_substitution_confirm() {
        let buffer = vimBufferGetCurrent();
        let lc = vimBufferGetLineCount(buffer);
        mu_check(lc == 3);

        vimInput(":");
        vimInput("s");
        vimInput("!");
        vimInput("T");
        vimInput("!");
        vimInput("A");
        vimInput("!");
        vimInput("g");
        vimInput("g");
        vimInput("c");
        vimKey("<cr>");

        mu_check(strcmp(vimBufferGetLine(buffer, 1),
                        "This is the first line of a test file") == 0);
    }

    func test_cmdline_get_type() {
        vimInput(":");
        mu_check(vimCommandLineGetType() == ":");
        vimKey("<esc>");

        vimInput("/");
        mu_check(vimCommandLineGetType() == "/");
        vimKey("<esc>");

        vimInput("?");
        mu_check(vimCommandLineGetType() == "?");
        vimKey("<esc>");
    }
}
