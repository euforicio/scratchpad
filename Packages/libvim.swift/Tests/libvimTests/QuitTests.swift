//
//  QuitTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class QuitTests: VimTestCase {
    var quitCount = 0
    var lastForce: Bool!
    var lastQuitBuf: Vim.Buffer!

    override func setUp() {
        super.setUp()

        vimSetQuitCallback { [unowned self] buffer, force in
            lastQuitBuf = buffer;
            lastForce = force;
            quitCount += 1;
        }

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");

        vimInput("g");
        vimInput("g");
    }
    
    func test_q() {
        vimExecute("q");

        mu_check(quitCount == 1);
        mu_check(lastQuitBuf == curbuf);
        XCTAssertFalse(lastForce)
    }

    func test_q_force() {
        vimExecute("q!");

        mu_check(quitCount == 1);
        mu_check(lastQuitBuf == curbuf);
        XCTAssertTrue(lastForce)
    }

    func test_xall() {
        vimExecute("xall");

        mu_check(quitCount == 1);
        XCTAssertNil(lastQuitBuf)
        XCTAssertFalse(lastForce)
    }

    func test_xit() {
        vimExecute("for b in getbufinfo({'bufmodified':1}) | exe 'bdelete! ' . b.bufnr | endfor")
        vimExecute("xit!");

        XCTAssertEqual(quitCount, 1);
        XCTAssertEqual(lastQuitBuf, curbuf);
        XCTAssertTrue(lastForce)
    }
}
