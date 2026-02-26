//
//  OutputTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class OutputTests: VimTestCase {
    var lastCmd: String!
    var lastOutput: String!
    var lastSilent: Bool!
    var outputCount: Int = 0

    override func setUp() {
        super.setUp()

        vimSetOutputCallback { [unowned self] cmd, output, isSilent in
            print("onOutput - cmd: |\(cmd)| output: |\(output)| silent: |\(isSilent)|\n")

            lastCmd = cmd
            lastOutput = output
            lastSilent = isSilent
            outputCount += 1
        }

        vimSetMessageCallback { title, message, _ in
            print("onMessage - title: |\(title)| contents: |\(message)|")
        }

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");
        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    // func test_ex_bang_ls() {
    //   vimExecute("!ls");

    //   mu_check(outputCount == 1);
    //   mu_check(strcmp(lastCmd, "ls") == 0);
    //   mu_check(strlen(lastOutput) > 0);
    // }

    func test_ex_bang_echo() {
        vimExecute("!echo 'hi'");

        mu_check(outputCount == 1);
        mu_check(strcmp(lastCmd, "echo 'hi'") == 0);
        mu_check(strlen(lastOutput) > 0);
        XCTAssertFalse(lastSilent)
    }

    func test_ex_bang_echo_silent() {
        vimExecute("silent !echo 'whisper...'");

        mu_check(outputCount == 1);
        mu_check(strcmp(lastCmd, "echo 'whisper...'") == 0);
        mu_check(strlen(lastOutput) > 0);
        XCTAssertTrue(lastSilent)

        // Verify silent flag gets reset
        vimExecute("!echo 'hi'");
        XCTAssertFalse(lastSilent)
    }

    func test_ex_read_cmd() {
        let originalBufferLength = vimBufferGetLineCount(vimBufferGetCurrent())
        vimExecute("read !ls .")

        mu_check(outputCount == 0)
        let newBufferLength = vimBufferGetLineCount(vimBufferGetCurrent())
        mu_check(newBufferLength > originalBufferLength)
    }
}
