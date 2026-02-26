//
//  TerminalTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class TerminalTests: VimTestCase {
    var terminalCallCount = 0
    var lastTerminalRequest: Vim.TerminalRequest!

    override func setUp() {
        super.setUp()

        vimSetTerminalCallback { [unowned self] termRequest in
            lastTerminalRequest = termRequest
            terminalCallCount += 1;
        }

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");
    }

    func test_term_noargs() {
        vimInput(":term");
        vimKey("<cr>");

        mu_check(terminalCallCount == 1);
        mu_check(lastTerminalRequest.curwin == 0);
        mu_check(lastTerminalRequest.cmd == nil);
        mu_check(lastTerminalRequest.finish == "c");
    }

    func test_term_noclose() {
        vimInput(":term ++noclose");
        vimKey("<cr>");

        mu_check(terminalCallCount == 1);
        mu_check(lastTerminalRequest.curwin == 0);
        mu_check(lastTerminalRequest.cmd == nil);
        mu_check(lastTerminalRequest.finish == "n");
    }

    func test_term_bash() {
        vimInput(":term bash");
        vimKey("<cr>");

        mu_check(terminalCallCount == 1);
        mu_check(lastTerminalRequest.curwin == 0);
        mu_check(strcmp(lastTerminalRequest.cmd, "bash") == 0);
        print("Finish: ", lastTerminalRequest.finish);
        mu_check(lastTerminalRequest.finish == "c");
    }

    func test_term_curwin() {
        vimInput(":term ++curwin");
        vimKey("<cr>");

        mu_check(terminalCallCount == 1);
        mu_check(lastTerminalRequest.curwin == 1);
        mu_check(lastTerminalRequest.cmd == nil);
        mu_check(lastTerminalRequest.finish == "c");
    }
}
