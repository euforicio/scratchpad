//
//  BufferSetLinesTests.swift
//  
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-08.
//

import XCTest
import libvim

final class BufferSetLinesTests: VimTestCase {
    var updateCount = 0;
    var lastLnum: Vim.LineNumber = 0;
    var lastLnume: Vim.LineNumber = 0;
    var lastXtra = 0;
    var lastVersionAtUpdateTime = 0;

    override func setUp() {
        super.setUp()

        vimSetBufferUpdateCallback { [unowned self] update in
            lastLnum = update.lnum;
            lastLnume = update.lnume;
            lastXtra = update.xtra;
            lastVersionAtUpdateTime = vimBufferGetLastChangedTick(curbuf);

            updateCount++;
        }

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");

        vimInput("g");
        vimInput("g");
    }

    func test_append_before_buffer() {
        let lines = [ "one" ]
        vimBufferSetLines(curbuf, 0, 0, lines);

        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "one") == 0);
        print("LINE 2: ", vimBufferGetLine(curbuf, 2));
        mu_check(strcmp(vimBufferGetLine(curbuf, 2), "This is the first line of a test file") == 0);

        mu_check(vimBufferGetLineCount(curbuf) == 4);
    }

    func test_append_after_buffer() {
        let lines = [ "after" ]
        vimBufferSetLines(curbuf, 3, 4, lines);

        print("LINE 3: \(vimBufferGetLine(curbuf, 3))");
        print("LINE 4: \(vimBufferGetLine(curbuf, 4))");
        mu_check(strcmp(vimBufferGetLine(curbuf, 4), "after") == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 3), "This is the third line of a test file") == 0);

        mu_check(vimBufferGetLineCount(curbuf) == 4);
    }

    func test_append_after_first_line() {

        let lines = [ "after first line" ]
        vimBufferSetLines(curbuf, 1, 1, lines);

        print("LINE 1: ", vimBufferGetLine(curbuf, 1));
        print("LINE 2: ", vimBufferGetLine(curbuf, 2));
        print("LINE 3: ", vimBufferGetLine(curbuf, 3));
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "This is the first line of a test file") == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 2), "after first line") == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 3), "This is the second line of a test file") == 0);

        mu_check(vimBufferGetLineCount(curbuf) == 4);
    }

    func test_replace_second_line_multiple_lines() {
        let lines = [ "new first line", "new second line" ]
        vimBufferSetLines(curbuf, 1, 1, lines);

        print("LINE 1: ", vimBufferGetLine(curbuf, 1));
        print("LINE 2: ", vimBufferGetLine(curbuf, 2));
        print("LINE 3: ", vimBufferGetLine(curbuf, 3));
        print("LINE 4: ", vimBufferGetLine(curbuf, 4));
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "This is the first line of a test file") == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 2), "new first line") == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 3), "new second line") == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 4), "This is the second line of a test file") == 0);
    }

    func test_replace_entire_buffer_from_zero() {
        let lines = [ "abc" ]
        vimBufferSetLines(curbuf, 0, 3, lines);
        mu_check(vimBufferGetLineCount(curbuf) == 1);
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "abc") == 0);

        mu_check(vimBufferGetLineCount(curbuf) == 1);
    }

    func test_replace_entire_buffer_after_first_line() {
        let lines = [ "abc" ]
        vimBufferSetLines(curbuf, 1, 3, lines);
        mu_check(vimBufferGetLineCount(curbuf) == 2);
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "This is the first line of a test file") == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 2), "abc") == 0);

        mu_check(vimBufferGetLineCount(curbuf) == 2);
    }

    func test_replace_entire_buffer_with_more_lines() {
        let lines = [ "line1", "line2", "line3", "line4", "line5" ]
        vimBufferSetLines(curbuf, 0, 3, lines);
        mu_check(vimBufferGetLineCount(curbuf) == 5);
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "line1") == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 5), "line5") == 0);

        mu_check(vimBufferGetLineCount(curbuf) == 5);
    }

    func test_replace_entire_buffer_with_more_lines_again() {
        let lines = [ "line1", "line2", "line3", "line4", "line5" ]
        vimBufferSetLines(curbuf, 0, -1, lines);
        mu_check(vimBufferGetLineCount(curbuf) == 5);
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "line1") == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 5), "line5") == 0);

        mu_check(vimBufferGetLineCount(curbuf) == 5);
    }

    func test_version_is_incremented() {
        let initialVersion = vimBufferGetLastChangedTick(curbuf);
        let lines = [ "one" ]
        vimBufferSetLines(curbuf, 0, 0, lines);

        let afterVersion = vimBufferGetLastChangedTick(curbuf);
        mu_check(afterVersion > initialVersion);
    }

    func test_modified_is_set() {
        mu_check(vimBufferGetModified(curbuf) == FALSE);
        let lines = [ "one" ]
        vimBufferSetLines(curbuf, 0, 0, lines);
        mu_check(vimBufferGetModified(curbuf) == TRUE);
    }

}
