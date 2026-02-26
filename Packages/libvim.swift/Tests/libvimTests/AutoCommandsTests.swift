//
//  AutoCommandsTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-07.
//

import XCTest
import libvim

final class AutoCommandsTests: VimTestCase {
    var events = [Vim.Event]()

    private func didEvent(_ event: Vim.Event) -> Bool {
        events.contains(event)
    }

    override func setUp() {
        super.setUp()

        vimSetAutoCommandCallback { [unowned self] event, _ in
            events.append(event)
        }

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");

    }

    func test_insertenter_insertleave() {
        vimInput("i");
        mu_check(didEvent(.insertEnter));

        vimKey("<esc>");
        mu_check(didEvent(.insertLeave));
    }
}
