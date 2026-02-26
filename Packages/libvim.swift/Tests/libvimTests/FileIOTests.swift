//
//  FileIOTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class FileIOTests: VimTestCase {
    var tempFile: String!
    var lastMessage: String!
    var lastTitle: String!
    var lastPriority: MessagePriority!

    var writeFailureCount = 0
    var lastWriteFailureReason: Vim.WriteFailureReason!

    override func setUp() {
        super.setUp()

        vimSetFileWriteFailureCallback { [unowned self] failureReason, buf in
            print("onWriteFailure - reason: \(failureReason)")
            writeFailureCount += 1
            lastWriteFailureReason = failureReason
        }

        vimSetMessageCallback { [unowned self] title, message, priority in
            print("onMessage - title: |\(title)| contents: |\(message)|")
            lastMessage = message
            lastTitle = title
            lastPriority = priority
        }

        tempFile = vim_tempname("t", FALSE)

        vimKey("<esc>");
        vimKey("<esc>");
        vimBufferOpen(tempFile, 1, 0)
        vimExecute("e!");

        vimInput("g");
        vimInput("g");
    }

    func test_modify_file_externally() {
        vimInput("i");
        vimInput("a");
        vimKey("<esc>");
        vimExecute("w");

        // HACK: This sleep is required to get different 'mtimes'
        // for Vim to realize that the buffer is modified
        sleep(3);

        mu_check(writeFailureCount == 0);

        if let fp = fopen(tempFile, "w") {
            fputs("Hello!", fp)
            fclose(fp)
        }

        vimExecute("u");
        vimExecute("w");

        mu_check(writeFailureCount == 1);
        mu_check(lastWriteFailureReason == FILE_CHANGED);
    }

    // TODO: Get passing on Arch, currently causes stack overflow
    // func test_modify_file_externally_forceit() {
    //   vimInput("i");
    //   vimInput("a");
    //   vimInput("<esc>");
    //   vimExecute("w");

    //   // HACK: This sleep is required to get different 'mtimes'
    //   // for Vim to realize that the buffer is modified
    //   sleep(3);

    //   mu_check(writeFailureCount == 0);
    //   FILE *fp = fopen(tempFile, "w");
    //   fprintf(fp, "Hello!\n");
    //   fclose(fp);

    //   vimExecute("u");
    //   vimExecute("w!");

    //   mu_check(writeFailureCount == 0);
    // }

    // Verify that the vimBufferCheckIfChanged call updates the buffer,
    // if there are no unsaved changes.
    func test_checkifchanged_updates_buffer() {
        mu_check(vimBufferCheckIfChanged(curbuf) == 0);
        vimInput("i");
        vimInput("a");
        vimKey("<esc>");
        vimExecute("w");

        // HACK: This sleep is required to get different 'mtimes'
        // for Vim to realize that th ebfufer is modified
        sleep(3);

        mu_check(writeFailureCount == 0);

        if let fp = fopen(tempFile, "w") {
            fputs("Hello!", fp)
            fclose(fp)
        }

        let v = vimBufferCheckIfChanged(curbuf);
        /* Should return 1 because the buffer was changed */
        /* Should we get a buffer update? */
        mu_check(v == 1);

        /* With auto-read, we should've picked up the change */
        let line = vimBufferGetLine(curbuf, 1);
        mu_check(strcmp(line, "Hello!") == 0);
    }

    // Verify that the vimBufferCheckIfChanged call updates the buffer,
    // if there are no unsaved changes.
    func test_checkifchanged_with_unsaved_changes()
    {
        mu_check(vimBufferCheckIfChanged(curbuf) == 0);
        vimInput("i");
        vimInput("a");
        vimKey("<esc>");
        vimExecute("w");

        vimInput("i");
        vimInput("b");

        // HACK: This sleep is required to get different 'mtimes'
        // for Vim to realize that th ebfufer is modified
        sleep(3);

        mu_check(writeFailureCount == 0);

        if let fp = fopen(tempFile, "w") {
            fputs("Hello!", fp)
            fclose(fp)
        }

        let v = vimBufferCheckIfChanged(curbuf);
        /* Should return 1 because the buffer was changed */
        /* Should we get a buffer update? */
        mu_check(v == 1);

        /* We should not have picked up changes, because we have modifications */
        let line = vimBufferGetLine(curbuf, 1);
        mu_check(strcmp(line, "ba") == 0);
    }
}
