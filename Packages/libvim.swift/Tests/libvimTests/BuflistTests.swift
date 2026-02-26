//
//  BuflistTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-08.
//

import XCTest
import libvim

final class BuflistTests: VimTestCase {
    override func setUp() {
        super.setUp()

        vimExecute("e!");

        vimInput("g");
        vimInput("g");
    }

    func test_buflist_get_id() {
        let current = vimBufferGetCurrent();
        let currentId = vimBufferGetId(current);

        mu_check(vimBufferGetById(currentId) == current);
    }

    func test_buffer_open() {
        let buf = vimBufferOpen(curswant, 1, 0);
        let lines = vimBufferGetLineCount(buf);

        mu_check(lines == 4);
    }

    func test_buffer_load_nonexistent_file() {
        let buf = vimBufferLoad("a-non-existent-file.txt", 1, 0);
        let lines = vimBufferGetLineCount(buf);
        mu_check(lines == 1);
    }

    func test_buffer_load_does_not_change_current() {
        let bufOpen = vimBufferOpen(curswant, 1, 0);

        let bufLoaded = vimBufferLoad("a-non-existent-file.txt", 1, 0);
        let loadedLines = vimBufferGetLineCount(bufLoaded);
        mu_check(loadedLines == 1);

        let openLines = vimBufferGetLineCount(bufOpen);
        mu_check(openLines == 4);

        let currentBuf = vimBufferGetCurrent();

        mu_check(currentBuf == bufOpen);
    }

    func test_buffer_load_read_lines() {
        let bufLoaded = vimBufferLoad(testfile, 1, 0);
        mu_check(strcmp(vimBufferGetLine(bufLoaded, 1), "This is the first line of a test file") == 0);
        mu_check(strcmp(vimBufferGetLine(bufLoaded, 2), "This is the second line of a test file") == 0);
        mu_check(strcmp(vimBufferGetLine(bufLoaded, 3), "This is the third line of a test file") == 0);
    }
}
