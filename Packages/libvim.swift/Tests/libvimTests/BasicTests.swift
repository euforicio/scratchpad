//
//  BasicTests.swift
//  
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-02-27.
//

import XCTest
import libvim

final class BasicTests: VimTestCase {
    override func setUp() {
        super.setUp()

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");
        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func testBasic() throws {
        let buf = curbuf

        XCTAssert(vimGetMode().contains(.normal))

        var line = vimBufferGetLine(buf, 1);
        print("LINE: \(line)");
        let comp = strcmp(line, "This is the first line of a test file");
        XCTAssertEqual(comp, 0);

        let len = vimBufferGetLineCount(buf);
        XCTAssert(len == 3);

        print("cursor line: \(vimCursorGetLine())");

        XCTAssert(vimCursorGetLine() == 1);

        vimInput("G");
        print("cursor line: \(vimCursorGetLine())");

        XCTAssertGreaterThan(vimCursorGetLine(), 1);

        vimInput("v");
        XCTAssert(vimGetMode().contains(.visual))
        vimInput("l");
        vimInput("l");
        vimInput("x");

        /* assert(vimGetMode() & INSERT == INSERT); */

        line = vimBufferGetLine(buf, 1);
        print("LINE: \(line)");
        print("Completed");

    }
}
