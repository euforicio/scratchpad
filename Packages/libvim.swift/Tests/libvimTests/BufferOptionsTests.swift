//
//  BufferOptionsTests.swift
//  
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-08.
//

import XCTest
import libvim

final class BufferOptionsTests: VimTestCase {
    let MAX_TEST_MESSAGE = 8192

    var updateCount = 0;
    var lastLnum: Vim.LineNumber = 0;
    var lastLnume: Vim.LineNumber = 0;
    var lastXtra = 0;
    var lastVersionAtUpdateTime = 0;
    var lastMessage: String?
    var lastTitle: String?
    var lastPriority: MessagePriority!;
    var messageCount = 0;

    override func setUp() {
        super.setUp()

        vimSetMessageCallback { [unowned self] message, title, priority in
            print("onMessage - title: |\(title)| contents: |\(message)|");

            XCTAssertLessThan(message.count, MAX_TEST_MESSAGE);
            XCTAssertLessThan(title.count, MAX_TEST_MESSAGE);

            lastMessage = message
            lastTitle = title
            lastPriority = priority;
            messageCount++;
        }

        vimSetBufferUpdateCallback { [unowned self] update in
            lastLnum = update.lnum;
            lastLnume = update.lnume;
            lastXtra = update.xtra;
            lastVersionAtUpdateTime = vimBufferGetLastChangedTick(curbuf);

            updateCount++;
        }

        vimBufferSetModifiable(curbuf, true);
        vimBufferSetReadOnly(curbuf, false);

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");

        vimInput("g");
        vimInput("g");
    }

    func test_get_set_modifiable() {
        vimBufferSetModifiable(curbuf, FALSE);
        mu_check(vimBufferGetModifiable(curbuf) == FALSE);

        vimBufferSetModifiable(curbuf, TRUE);
        mu_check(vimBufferGetModifiable(curbuf) == TRUE);
    }

    func test_get_set_readonly() {
        vimBufferSetReadOnly(curbuf, FALSE);
        mu_check(vimBufferGetReadOnly(curbuf) == FALSE);

        vimBufferSetReadOnly(curbuf, TRUE);
        mu_check(vimBufferGetReadOnly(curbuf) == TRUE);
    }

    func test_error_msg_nomodifiable() {
        vimBufferSetModifiable(curbuf, FALSE);

        vimInput("o");

        // Verify no change to the buffer...
        mu_check(updateCount == 0);
        // ...but we shouldn've gotten an error message
        mu_check(messageCount == 1);
        mu_check(lastPriority == .error);
    }
}
