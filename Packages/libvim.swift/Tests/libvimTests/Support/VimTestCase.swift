//
//  VimTestCase.swift
//  
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-06.
//

import XCTest
import libvim

class VimTestCase: XCTestCase {
    var curbuf: Vim.Buffer {
        vimBufferGetCurrent()
    }

    func mu_check(_ condition: Bool) {
        XCTAssert(condition)
    }

    private static var vimInitialized = false

    class func vimInitOnce() {
        if !vimInitialized {
            vimInitialized = true
            vimInit()
        }
    }

    class override func setUp() {
        super.setUp()
        vimInitOnce()

        win_setwidth(5);
        win_setheight(100);
        vimBufferOpen(testfile, 1, 0);
    }
}
