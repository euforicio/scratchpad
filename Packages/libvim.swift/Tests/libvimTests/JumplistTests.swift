//
//  JumplistTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class JumplistTests: VimTestCase {

    override func setUp() {
        super.setUp()

        vimExecute("e!");

        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_jumplist_openfile() {
        let firstBuf = vimBufferOpen(testfile, 1, 0);
        let secondBuf = vimBufferOpen(lines100, 1, 0);

        mu_check(firstBuf != secondBuf);

        mu_check(curbuf == secondBuf);

        vimKey("<c-o>");
        mu_check(curbuf == firstBuf);

        vimKey("<c-i>");
        mu_check(curbuf == secondBuf);
    }

    func test_jumplist_editnew() {
        let firstBuf = vimBufferOpen(testfile, 1, 0);

        vimExecute("e! \(collateral)/a_new_file.txt");
        let secondBuf = curbuf;

        mu_check(firstBuf != secondBuf);
        mu_check(curbuf == secondBuf);

        vimKey("<c-o>");
        mu_check(curbuf == firstBuf);

        vimKey("<c-i>");
        mu_check(curbuf == secondBuf);
    }

}
