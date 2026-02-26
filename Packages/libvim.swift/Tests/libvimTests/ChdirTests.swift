//
//  ChdirTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-08.
//

import XCTest
import libvim

final class ChdirTests: VimTestCase {
    let MAX_SIZE = 8192

    var lastDirectory: String!
    var onDirectoryChangedCount = 0

    override func setUp() {
        super.setUp()

        vimSetDirectoryChangedCallback { [unowned self] path in
            print("onDirectoryChanged - path: |\(path)|")

            XCTAssertLessThan(path.count, MAX_SIZE);
            onDirectoryChangedCount++;

            lastDirectory = path
        }

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");

        vimInput("g");
        vimInput("g");
    }

    func test_chdir() {
        vimExecute("cd \(collateral)");

        mu_check(onDirectoryChangedCount == 1);

        let cwd = FileManager.default.currentDirectoryPath
        XCTAssert(cwd.hasSuffix("collateral"))
    };
}
