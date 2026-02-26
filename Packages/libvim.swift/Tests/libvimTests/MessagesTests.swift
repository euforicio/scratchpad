//
//  MessagesTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class MessagesTests: VimTestCase {
    let collateralRelative = (collateral as NSString).abbreviatingWithTildeInPath
    var lastMessage: String!
    var lastTitle: String!
    var lastPriority: MessagePriority!
    var lastGoto: Vim.GotoRequest!
    var gotoCount = 0
    var clearCount = 0
    var lastClear: Vim.ClearRequest!

    override func setUp() {
        super.setUp()

        vimSetMessageCallback { [unowned self] title, message, priority in
            print("onMessage -\n",
                  "title:    |\(title)|\n",
                  "contents: |\(message)|")

            lastMessage = message
            lastTitle = title
            lastPriority = priority
        }

        vimSetClearCallback { [unowned self] clearRequest in
            lastClear = clearRequest
            clearCount++
        }

        vimSetGotoCallback { [unowned self] gotoRequest in
            lastGoto = gotoRequest
            gotoCount++
            return false
        }

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");

        vimInput("g");
        vimInput("g");
    }

    func test_msg2_put() {
        var msg = Vim.Message(priority: .info)
        msg.put("a")

        XCTAssertEqual(msg.contents, "a")
    }

    func test_msg2_put_multiple() {
        var msg = Vim.Message(priority: .info)
        msg.put("ab")
        msg.put("\n")
        msg.put("c")

        XCTAssertEqual(msg.contents, "ab\nc")
    }

    func test_msg2_send_triggers_callback() {
        var msg = Vim.Message(priority: .info)
        msg.put("testing")
        msg.send()

        XCTAssertEqual(lastMessage, "testing")
        XCTAssertEqual(lastPriority, .info)
    }

    func test_msg2_title() {
        var msg = Vim.Message(priority: .info)
        msg.title = "test-title"
        msg.put("test-contents")
        msg.send()

        mu_check(strcmp(lastMessage, "test-contents") == 0);
        mu_check(strcmp(lastTitle, "test-title") == 0);
        mu_check(lastPriority == .info);
    }

    func test_echo() {
        vimExecute("echo 'hello'");

        mu_check(strcmp(lastMessage, "hello") == 0);
        mu_check(lastPriority == .info);
    }

    func test_echom() {
        vimExecute("echomsg 'hi'");

        mu_check(strcmp(lastMessage, "hi") == 0);
        mu_check(lastPriority == .info);
    }

    func test_buffers() {
        vimExecute("buffers %")

        let expected = "\n  2 %a   \"testfile.txt\"                 line 1"
        XCTAssertEqual(lastMessage, expected)
        mu_check(lastPriority == .info)
    }

    func test_files() {
        vimExecute("files %")

        let expected = "\n  2 %a   \"testfile.txt\"                 line 1"
        XCTAssertEqual(lastMessage, expected)
        mu_check(lastPriority == .info)
    }

    func test_error() {
        vimExecute("buf 999");

        mu_check(strcmp(lastMessage, "E86: Buffer 999 does not exist") == 0);
        mu_check(lastPriority == .error);
    }

    func test_readonly_warning() {
        vimExecute("set readonly");

        vimInput("i");
        vimInput("a");

        mu_check(strcmp(lastMessage, "W10: Warning: Changing a readonly file") == 0);
        mu_check(lastPriority == .warning);
    }

    func test_set_print() {
        vimExecute("set relativenumber?");

        mu_check(strcmp(lastMessage, "norelativenumber") == 0);
        mu_check(lastPriority == .info);
    }

    func test_print_marks() {
        /* Set a mark */
        vimInput("m");
        vimInput("a");

        vimExecute("marks a");

        mu_check(strcmp(lastTitle, "mark line  col file/text") == 0);
        XCTAssertEqual(lastMessage,
                        "\n a      1    0 This is the first line of a test file")
        mu_check(lastPriority == .info);
    }

    func test_print_jumps() {
        vimExecute("jumps");

        mu_check(strcmp(lastTitle, " jump line  col file/text") == 0);
        mu_check(lastPriority == .info);
    }

    func test_print_changes() {
        vimExecute("changes");

        mu_check(strcmp(lastTitle, " change line  col text") == 0);
        mu_check(lastPriority == .info);
    }

    func test_ex_goto_messages() {
        vimExecute("messages");
        mu_check(gotoCount == 1);
        mu_check(lastGoto.target == .messages);
        mu_check(lastGoto.count == 0);
    }

    func test_ex_goto_messages_count() {
        vimExecute("5messages");
        mu_check(gotoCount == 1);
        mu_check(lastGoto.target == .messages);
        mu_check(lastGoto.count == 5);
    }

    func test_ex_clear_messages() {
        vimExecute("messages clear");
        mu_check(clearCount == 1);
        mu_check(lastClear.target == .messages);
        mu_check(lastClear.count == 0);
    }

    func test_ex_clear_messages_count() {

        vimExecute("10messages clear");
        mu_check(clearCount == 1);
        mu_check(lastClear.target == .messages);
        mu_check(lastClear.count == 10);
    }
}
