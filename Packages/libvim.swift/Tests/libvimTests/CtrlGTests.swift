//
//  CtrlGTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class CtrlGTests: VimTestCase {
    var lastMessage: String!
    var lastTitle: String!
    var lastPriority: MessagePriority!

    override func setUp() {
        super.setUp()

        vimSetMessageCallback { [unowned self] title, message, priority in
            print("onMessage - title: |\(title)| contents: |\(message)|")

            lastMessage = message
            lastTitle = title
            lastPriority = priority
        }

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");

        vimInput("g");
        vimInput("g");
    }

    func test_fileinfo() {
        vimKey("<c-g>");

        let expected = "\"testfile.txt\" line 1 of 3 --33%-- col 1";
        XCTAssertEqual(lastMessage, expected);
        XCTAssertEqual(lastPriority, .info);
    }

}
