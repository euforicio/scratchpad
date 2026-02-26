//
//  BackspaceTests.swift
//  
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-07.
//

import XCTest
import libvim

final class BackspaceTests: VimTestCase {
    override func setUp() {
        super.setUp()

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");

        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_backspace_beyond_insert() {
        // Go to end of 'This'
        vimInput("e");

        // Enter insert after 'This'
        vimInput("a");

        // Backspace a couple of times...
        // This verifies we have the correct backspace settings
        // (default doesn't backspace past insert region)
        vimKey("<c-h>");
        vimKey("<c-h>");

        let line = vimBufferGetLine(curbuf, vimCursorGetLine());
        print("LINE: \(line)");
        mu_check(strcmp(line, "Th is the first line of a test file") == 0);
    }
}
