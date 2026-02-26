//
//  CmdlineCompletionTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-08.
//

import XCTest
import libvim

final class CmdlineCompletionTests: VimTestCase {
    override func setUp() {
        super.setUp()

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");
    }

    func test_cmdline_null() {
        // Verify values are expected when we're not in command line mode

        mu_check(vimCommandLineGetText() == nil);
        mu_check(vimCommandLineGetType() == Character("\0"));
        mu_check(vimCommandLineGetPosition() == 0);

        let completions = vimCommandLineGetCompletions()
        mu_check(completions.count == 0);
    }

    func test_cmdline_get_type() {
        vimInput(":");
        mu_check(vimCommandLineGetType() == ":");
    }

    func test_cmdline_get_text() {
        vimInput(":");
        mu_check(strcmp(vimCommandLineGetText(), "") == 0);
        mu_check(vimCommandLineGetPosition() == 0);

        vimInput("a");
        mu_check(strcmp(vimCommandLineGetText(), "a") == 0);
        mu_check(vimCommandLineGetPosition() == 1);

        vimInput("b");
        mu_check(strcmp(vimCommandLineGetText(), "ab") == 0);
        mu_check(vimCommandLineGetPosition() == 2);

        vimInput("c");
        mu_check(strcmp(vimCommandLineGetText(), "abc") == 0);
        mu_check(vimCommandLineGetPosition() == 3);

        vimKey("<c-h>");
        mu_check(strcmp(vimCommandLineGetText(), "ab") == 0);
        mu_check(vimCommandLineGetPosition() == 2);

        vimKey("<cr>");
    }

    func test_cmdline_completions() {
        vimExecute("cd \(collateral)");
        vimInput(":");

        vimInput("e");
        var completions = vimCommandLineGetCompletions()
        mu_check(completions.count == 20);

        vimInput("d");
        completions = vimCommandLineGetCompletions()
        mu_check(completions.count == 1);

        vimInput(" ");
        vimInput(".");
        vimInput("/");
        vimInput("c");
        completions = vimCommandLineGetCompletions()
        XCTAssertGreaterThanOrEqual(completions.count, 1);
    }

    func test_cmdline_completions_empty_space() {
        vimInput(":");

        // Try to get completions for an invalid command
        vimInput("d");
        vimInput("e");
        vimInput("r");
        vimInput("p");
        vimInput(" ");

        let completions = vimCommandLineGetCompletions();
        mu_check(completions.count == 0);
    }

    func test_cmdline_completions_eh() {
        vimInput(":");

        // Try to get completions for an invalid command
        vimInput("e");
        vimInput("h");

        let completions = vimCommandLineGetCompletions()
        mu_check(completions.count == 0);
    }

    func test_cmdline_completions_abs() {

        vimInput(":");

        // Try to get completions for an invalid command
        vimInput("e");
        vimInput("c");
        vimInput("h");
        vimInput("o");

        vimInput("a");
        vimInput("b");
        vimInput("s");
        vimInput("(");
        vimInput("-");
        vimInput("1");

        let completions = vimCommandLineGetCompletions();
        mu_check(completions.count == 0);
    }

    func test_cmdline_completion_crash()
    {
        vimInput(":");
        vimInput("!m");
        vimInput(" ");
        vimInput("h");
        vimKey("<LEFT>");
        vimKey("<LEFT>");

        var completions = vimCommandLineGetCompletions()
        mu_check(completions.count > -1)

        vimKey("<LEFT>")
        completions = vimCommandLineGetCompletions()
        mu_check(completions.count > -1)

        vimKey("<RIGHT>")
        completions = vimCommandLineGetCompletions()
        mu_check(completions.count > -1)

        vimKey("<RIGHT>")
        completions = vimCommandLineGetCompletions()
        mu_check(completions.count > -1)

        vimKey("<RIGHT>")
        completions = vimCommandLineGetCompletions()
        mu_check(completions.count > -1)
    }
}
