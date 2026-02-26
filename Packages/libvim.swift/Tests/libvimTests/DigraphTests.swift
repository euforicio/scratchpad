//
//  DigraphTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class DigraphTests: VimTestCase {
    override func setUp() {
//        vimInit()

        vimBufferOpen(lines100, 1, 0);

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");

        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_digraph_doesnt_hang() {
        vimInput("i");

        // Start inserting digraph... should be no-op right now
        // until we bring the feature back
        vimKey("<c-k>");
    }

}
