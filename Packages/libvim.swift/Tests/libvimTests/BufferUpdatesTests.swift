//
//  BufferUpdatesTests.swift
//  
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-08.
//

import XCTest
import libvim

final class BufferUpdatesTests: VimTestCase {
    var updateCount = 0;
    var lastLnum: Vim.LineNumber = 0;
    var lastLnume: Vim.LineNumber = 0;
    var lastXtra = 0;
    var lastVersionAtUpdateTime = 0;

    override func setUp() {
        super.setUp()

        vimSetBufferUpdateCallback { [unowned self] update in
            lastLnum = update.lnum;
            lastLnume = update.lnume;
            lastXtra = update.xtra;
            lastVersionAtUpdateTime = vimBufferGetLastChangedTick(curbuf);

            updateCount++;
        }

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");

        vimInput("g");
        vimInput("g");
    }

    func test_single_line_update() {
        vimInput("x");

        mu_check(updateCount == 1);
        mu_check(lastLnum == 1);
        mu_check(lastLnume == 2);
        mu_check(lastXtra == 0);
        mu_check(lastVersionAtUpdateTime == vimBufferGetLastChangedTick(curbuf));
    }

    func test_add_line() {
        vimInput("y");
        vimInput("y");
        vimInput("p");

        mu_check(updateCount == 1);
        mu_check(lastLnum == 2);
        mu_check(lastLnume == 2);
        mu_check(lastXtra == 1);
        mu_check(lastVersionAtUpdateTime == vimBufferGetLastChangedTick(curbuf));
    }

    func test_add_multiple_lines() {
        vimInput("y");
        vimInput("y");
        vimInput("2");
        vimInput("p");

        mu_check(updateCount == 1);
        mu_check(lastLnum == 2);
        mu_check(lastLnume == 2);
        mu_check(lastXtra == 2);
        mu_check(lastVersionAtUpdateTime == vimBufferGetLastChangedTick(curbuf));
    }

    func test_delete_line() {
        vimInput("d");
        vimInput("d");

        mu_check(updateCount == 1);
        mu_check(lastLnum == 1);
        mu_check(lastLnume == 2);
        mu_check(lastXtra == -1);
        mu_check(lastVersionAtUpdateTime == vimBufferGetLastChangedTick(curbuf));
    }

    func test_delete_multiple_lines() {
        vimInput("d");
        vimInput("2");
        vimInput("j");

        mu_check(updateCount == 1);
        mu_check(lastLnum == 1);
        mu_check(lastLnume == 4);
        mu_check(lastXtra == -3);
        mu_check(lastVersionAtUpdateTime == vimBufferGetLastChangedTick(curbuf));
    }

    func test_delete_n_lines() {
        vimBufferOpen(lines100, 1, 0);

        vimInput("5");
        vimInput("d");
        vimInput("d");

        mu_check(updateCount == 1);
        mu_check((lastLnume - lastLnum) == 5);
        mu_check(lastXtra == -5);
        mu_check(lastVersionAtUpdateTime == vimBufferGetLastChangedTick(curbuf));
    }

    func test_delete_large_n_lines() {
        vimBufferOpen(lines100, 1, 0);

        vimInput("5");
        vimInput("5");
        vimInput("d");
        vimInput("d");

        mu_check(updateCount == 1);
        mu_check((lastLnume - lastLnum) == 55);
        mu_check(lastXtra == -55);
        mu_check(lastVersionAtUpdateTime == vimBufferGetLastChangedTick(curbuf));
    }

    func test_delete_mn_lines() {
        vimBufferOpen(lines100, 1, 0);

        vimInput("5");
        vimInput("d");
        vimInput("5");
        vimInput("d");

        mu_check(updateCount == 1);
        mu_check((lastLnume - lastLnum) == 25);
        mu_check(lastXtra == -25);
        mu_check(lastVersionAtUpdateTime == vimBufferGetLastChangedTick(curbuf));
    }

    func test_set_lines() {
        vimBufferOpen(lines100, 1, 0);
        let lines = [ "one" ]
        vimBufferSetLines(curbuf, 0, -1, lines);

        mu_check(updateCount == 1);
        mu_check(lastLnum == 1);
        mu_check(lastLnume == 101);
        mu_check(lastXtra == -99);
        mu_check(lastVersionAtUpdateTime == vimBufferGetLastChangedTick(curbuf));

        mu_check(vimBufferGetLineCount(curbuf) == 1);
    }

    func test_insert() {
        vimInput("i");
        vimInput("a");
        vimInput("b");

        mu_check(updateCount == 2);
        mu_check(lastLnum == 1);
        mu_check(lastLnume == 2);
        mu_check(lastXtra == 0);
        mu_check(lastVersionAtUpdateTime == vimBufferGetLastChangedTick(curbuf));
    }

    func test_modified() {
        vimInput("i");
        vimInput("a");

        mu_check(vimBufferGetModified(curbuf) == TRUE);
    }

    func test_reset_modified_after_reload() {
        vimInput("i");
        vimInput("a");

        vimExecute("e!");

        mu_check(vimBufferGetModified(curbuf) == FALSE);
    }

    func test_reset_modified_after_undo() {
        vimExecute("e!");
        mu_check(vimBufferGetModified(curbuf) == FALSE);

        vimInput("O");
        vimInput("a");
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "a") == 0);

        vimKey("<esc>");
        vimInput("u");
        mu_check(vimBufferGetModified(curbuf) == FALSE);

        vimKey("<c-r>");
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "a") == 0);
        mu_check(vimBufferGetModified(curbuf) == TRUE);
    }
}
