//
//  SourceTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class SourceTests: VimTestCase {
    override func setUp() {
        super.setUp()

        vimExecute("e!");

        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_simple_viml() {
        vimExecute("source \(collateral)/reverse_keys.vim");

        let testVal = vimEval("g:test_val")
        XCTAssertEqual(testVal, "123")
    }
}
