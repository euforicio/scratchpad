//
//  CmdlineTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class CmdlineTests: VimTestCase {
    var messageCount: Int = 0

    override func setUp() {
        super.setUp()

        vimSetMessageCallback { (title, message, priority) in
            print("onMessage - title: |\(title)| contents: |\(message)|")
            self.messageCount += 1
        }

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");
        vimInput("g");
        vimInput("g");
        vimInput("0");

        messageCount = 0;
    }

    func test_insert_literal_ctrl_v() {
        vimInput(":");
        vimInput("a");
        vimKey("<c-v>");
        vimInput("1");
        vimInput("2");
        vimInput("6");
        vimInput("b");
        mu_check(strcmp(vimCommandLineGetText(), "a~b") == 0);
    }

    func test_insert_literal_ctrl_q() {
        vimInput(":");
        vimInput("a");
        vimKey("<c-q>");
        vimInput("1");
        vimInput("2");
        vimInput("6");
        vimInput("b");
        mu_check(strcmp(vimCommandLineGetText(), "a~b") == 0);
    }

    func test_typing_function_command() {
        vimInput(":");
        vimInput("function! Test()");
        vimKey("<CR>");
        //Should get an error message for multiline construct
        mu_check(messageCount == 1);
    }

    func test_multiline_command_sends_message() {
        mu_check(messageCount == 0);
        vimExecute("function! Test()");
        // Should get an error message for multiline construct
        mu_check(messageCount == 1);
    }

    func test_valid_multiline_command() {
        mu_check(messageCount == 0);

        let lines = [
            "function! SomeCommandTest()",
            "return 42",
            "endfunction"
        ];

        vimExecuteLines(lines);
        mu_check(messageCount == 0);

        let result = vimEval("SomeCommandTest()");
        print("Got result: \(result)");
        mu_check(strcmp(result, "42") == 0);
    }

    func test_multiline_multiple_functions() {
        mu_check(messageCount == 0);

        let lines = [
            "function! SomeCommandTest()",
            "return 42",
            "endfunction",
            "function! AnotherFunction()",
            "return 99",
            "endfunction"];

        vimExecuteLines(lines);
        mu_check(messageCount == 0);

        let result = vimEval("AnotherFunction()");
        print("Got result: \(result)");
        mu_check(strcmp(result, "99") == 0);
    }

}
