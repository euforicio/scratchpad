//
//  WindowSplitsTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class WindowSplitsTests: VimTestCase {
    var lastFilename: String!
    var lastSplitType: Vim.WindowSplit!
    var lastMovement: Vim.WindowMovement!
    var lastMovementCount: Int!

    class override func setUp() {
        super.setUp()
        vimExecute("q!")
    }

    override func setUp() {
        super.setUp()

        vimSetWindowSplitCallback { [unowned self] splitType, fname in
            print("onWindowSplit - type: |\(splitType)| file: |\(fname)|")

            lastFilename = fname
            lastSplitType = splitType
        }

        vimSetWindowMovementCallback { [unowned self] movementType, count in
            print("onWindowMovement - type: |\(movementType)| count: |\(count)|")

            lastMovement = movementType
            lastMovementCount = count
        }

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");

        vimInput("g");
        vimInput("g");
    }

    func test_vsplit() {
        vimExecute("vsp test-file.txt");

        mu_check(strcmp(lastFilename, "test-file.txt") == 0);
        mu_check(lastSplitType == .vertical);
    }

    func test_hsplit() {
        vimExecute("sp test-h-file.txt");

        mu_check(strcmp(lastFilename, "test-h-file.txt") == 0);
        mu_check(lastSplitType == .horizontal);
    }

    func test_vnew() {
        vimExecute("vnew");

        mu_check(strcmp(lastFilename, "") == 0);
        mu_check(lastSplitType == .verticalNew);
    }

    func test_new() {
        vimExecute("new");

        mu_check(strcmp(lastFilename, "") == 0);
        mu_check(lastSplitType == .horizontalNew);
    }

    func test_vsplit_ctrl_w() {
        vimBufferOpen(testfile, 1, 0);

        vimKey("<c-w>");
        vimInput("v");

        mu_check(lastSplitType == .vertical);
        mu_check(strstr(lastFilename, "testfile.txt") != nil);
    }

    func test_hsplit_ctrl_w() {
        vimBufferOpen(testfile, 1, 0);

        vimKey("<c-w>");
        vimInput("s");

        mu_check(lastSplitType == .horizontal);
        mu_check(strstr(lastFilename, "testfile.txt") != nil);
    }

    func test_tabnew() {
        vimExecute("tabnew test-tabnew-file.txt");

        mu_check(strcmp(lastFilename, "test-tabnew-file.txt") == 0);
        mu_check(lastSplitType == .tabNew);
    }

    func test_tabedit() {
        vimExecute("tabedit test-tabnew-file.txt");

        mu_check(strcmp(lastFilename, "test-tabnew-file.txt") == 0);
        mu_check(lastSplitType == .tab);
    }

    func test_win_movements() {

        print("Entering <c-w>");
        vimKey("<c-w>");
        print("Entering <c-j>");
        vimKey("<c-j>");

        mu_check(lastMovement == .cursorDown);
        mu_check(lastMovementCount == 1);

        vimKey("<c-w>");
        vimInput("k");

        mu_check(lastMovement == .cursorUp);
        mu_check(lastMovementCount == 1);

        vimKey("<c-w>");
        vimInput("h");

        mu_check(lastMovement == .cursorLeft);
        mu_check(lastMovementCount == 1);

        vimKey("<c-w>");
        vimInput("l");

        mu_check(lastMovement == .cursorRight);
        mu_check(lastMovementCount == 1);

        vimKey("<c-w>");
        vimInput("t");

        mu_check(lastMovement == .cursorTopLeft);
        mu_check(lastMovementCount == 1);

        vimKey("<c-w>");
        vimInput("b");

        mu_check(lastMovement == .cursorBottomRight);
        mu_check(lastMovementCount == 1);

        vimKey("<c-w>");
        vimInput("p");

        mu_check(lastMovement == .cursorPrevious);
        mu_check(lastMovementCount == 1);
    }

    func test_win_move_count_before() {
        vimInput("2");
        vimKey("<c-w>");
        vimInput("k");

        mu_check(lastMovement == .cursorUp);
        mu_check(lastMovementCount == 2);
    }

    func test_win_move_count_after() {
        vimKey("<c-w>");
        vimInput("4");
        vimInput("k");

        mu_check(lastMovement == .cursorUp);
        mu_check(lastMovementCount == 4);
    }

    func test_win_move_count_before_and_after() {
        vimInput("3");
        vimKey("<c-w>");
        vimInput("5");
        vimInput("k");

        mu_check(lastMovement == .cursorUp);
        mu_check(lastMovementCount == 35);
    }

    func test_move_commands() {
        vimKey("<c-w>");
        vimInput("H");
        mu_check(lastMovement == .moveFullLeft);
        mu_check(lastMovementCount == 1);

        vimKey("<c-w>");
        vimInput("L");

        mu_check(lastMovement == .moveFullRight);
        mu_check(lastMovementCount == 1);

        vimKey("<c-w>");
        vimInput("K");

        mu_check(lastMovement == .moveFullUp);
        mu_check(lastMovementCount == 1);

        vimKey("<c-w>");
        vimInput("J");

        mu_check(lastMovement == .moveFullDown);
        mu_check(lastMovementCount == 1);

        vimKey("<c-w>");
        vimInput("r");

        mu_check(lastMovement == .moveRotateDownwards);
        mu_check(lastMovementCount == 1);

        vimKey("<c-w>");
        vimInput("R");

        mu_check(lastMovement == .moveRotateUpwards);
        mu_check(lastMovementCount == 1);
    }
}
