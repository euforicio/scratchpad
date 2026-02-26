//
//  CommandFilterTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class CommandFilterTests: VimTestCase {
    var debugCount = 0
    var hitCount = 0

    override func setUp() {
        super.setUp()

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");
        vimInput("g");
        vimInput("g");
        vimInput("0");

        vimSetCustomCommandHandler { [unowned self] exCommand in
            print("COMMAND: \(exCommand.command)")
            hitCount++
            if exCommand.command.hasPrefix("debug") {
                debugCount++
                return true
            } else {
                return false
            }
        }
    }

    override func tearDown() {
        super.tearDown()
        vimSetCustomCommandHandler(nil)
    }

    func test_handle_command_via_command_line() {
        vimInput(":");
        vimInput("debug");
        vimKey("<cr>");
        XCTAssertEqual(debugCount, 1)
        XCTAssertEqual(hitCount, 1)
    }

    func test_handle_command_via_execute() {
        vimExecute("debug .");
        XCTAssertEqual(debugCount, 1)
        XCTAssertEqual(hitCount, 1)
    }

}
