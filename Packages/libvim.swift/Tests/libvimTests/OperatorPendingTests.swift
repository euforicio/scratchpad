//
//  OperatorPendingTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class OperatorPendingTests: VimTestCase {
    override func setUp() {
        super.setUp()
        vimBufferOpen("\(collateral)/curswant.txt", 1, 0);

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");
        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_delete_operator_pending() {
        vimInput("d");

        // Pressing 'd' should bring us to operator-pending state
        XCTAssert(vimGetMode().contains(.opPending ))

        vimInput("2");

        // Should still be in op_pending since this didn't finish the motion...
        XCTAssert(vimGetMode().contains(.opPending))

        // Should now be back to normal
        vimInput("j");

        XCTAssertFalse(vimGetMode().contains(.opPending))
        XCTAssert(vimGetMode().contains(.normal))
    }

    func test_pending_operator_insert() {
        vimInput("i");

        XCTAssert(vimGetMode().contains(.insert))

        XCTAssertNil(vimGetPendingOperator())
    }

    func test_pending_operator_cmdline() {
        vimInput(":");

        XCTAssert(vimGetMode().contains(.cmdLine))

        XCTAssertNil(vimGetPendingOperator())
    }

    func test_pending_operator_visual() {
        vimInput("v");

        XCTAssert(vimGetMode().contains(.visual))

        XCTAssertNil(vimGetPendingOperator())
    }

    func test_pending_operator_delete() {
        vimInput("d");

        let pendingOp = vimGetPendingOperator()!
        mu_check(pendingOp.opType == .delete)
        mu_check(pendingOp.count == 0)
    }

    func test_pending_operator_delete_count() {
        vimInput("5");
        vimInput("d");

//        XCTAssert(vimGetMode().contains(.visual))

        let pendingOp = vimGetPendingOperator()!
        mu_check(pendingOp.opType == .delete);
        mu_check(pendingOp.count == 5);
    }

    func test_pending_operator_change() {
        vimInput("2");
        vimInput("c");

        let pendingOp = vimGetPendingOperator()!
        mu_check(pendingOp.opType == .change);
        mu_check(pendingOp.count == 2);
    }

    func test_pending_operator_comment() {
        vimInput("g");
        vimInput("c");

        let pendingOp = vimGetPendingOperator()!
        mu_check(pendingOp.opType == .comment);
    }

    func test_pending_operator_register() {
        vimInput("\"");
        vimInput("a");
        vimInput("y");

        let pendingOp = vimGetPendingOperator()!
        mu_check(pendingOp.opType == .yank);
        mu_check(pendingOp.regName == "a");
    }
}
