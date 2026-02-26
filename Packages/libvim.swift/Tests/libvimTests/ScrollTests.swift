//
//  ScrollTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class ScrollTests: VimTestCase {
    var lastScrollDirection: Vim.ScrollDirection!
    var lastScrollCount = 1;
    var scrollRequestCount = 0;

    override func setUp() {
        super.setUp()

        vimSetScrollCallback { [unowned self] direction, count in
            lastScrollDirection = direction;
            lastScrollCount = count;
            scrollRequestCount++;
        }

        vimBufferOpen(lines100, 1, 0);

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");

        vimInput("g");
        vimInput("g");

        vimInput(":");
        vimInput("5");
        vimInput("0");

        vimKey("<cr>");
    }

    func test_set_get_metrics() {
        vimWindowSetWidth(80);
        vimWindowSetHeight(10);

        mu_check(vimWindowGetWidth() == 80);
        mu_check(vimWindowGetHeight() == 10);

        vimWindowSetWidth(20);
        vimWindowSetHeight(21);

        mu_check(vimWindowGetWidth() == 20);
        mu_check(vimWindowGetHeight() == 21);

        vimWindowSetWidth(100);
        vimWindowSetHeight(101);

        mu_check(vimWindowGetWidth() == 100);
        mu_check(vimWindowGetHeight() == 101);
    }

    func test_zz_zb_zt() {
        vimInput("z");
        vimInput("z");

        mu_check(scrollRequestCount == 1);
        mu_check(lastScrollDirection == .cursorCenterV);
        mu_check(lastScrollCount == 1);

        vimInput("z");
        vimInput("b");

        mu_check(scrollRequestCount == 2);
        mu_check(lastScrollDirection == .cursorBottom);
        mu_check(lastScrollCount == 1);

        vimInput("z");
        vimInput("t");
        mu_check(scrollRequestCount == 3);
        mu_check(lastScrollDirection == .cursorTop);
        mu_check(lastScrollCount == 1);
    }

    func test_zs_ze() {
        vimInput("z");
        vimInput("s");

        mu_check(scrollRequestCount == 1);
        mu_check(lastScrollDirection == .cursorLeft);
        mu_check(lastScrollCount == 1);

        vimInput("z");
        vimInput("e");

        mu_check(scrollRequestCount == 2);
        mu_check(lastScrollDirection == .cursorRight);
        mu_check(lastScrollCount == 1);
    }

    func test_zh_zl() {
        vimInput("z");
        vimInput("h");

        mu_check(scrollRequestCount == 1);
        mu_check(lastScrollDirection == .columnRight);
        mu_check(lastScrollCount == 1);

        vimInput("5");
        vimInput("z");
        vimInput("h");

        mu_check(scrollRequestCount == 2);
        mu_check(lastScrollDirection == .columnRight);
        mu_check(lastScrollCount == 5);

        vimInput("2");
        vimInput("z");
        vimInput("H");
        mu_check(scrollRequestCount == 3);
        mu_check(lastScrollDirection == .halfPageRight);
        mu_check(lastScrollCount == 2);

        vimInput("3");
        vimInput("z");
        vimInput("L");
        mu_check(scrollRequestCount == 4);
        mu_check(lastScrollDirection == .halfPageLeft);
        mu_check(lastScrollCount == 3);

        vimInput("z");
        vimInput("l");
        mu_check(scrollRequestCount == 5);
        mu_check(lastScrollDirection == .columnLeft);
    }

    //func test_small_screen_scroll()
    //{
    //  vimWindowSetWidth(80);
    //  vimWindowSetHeight(3);
    //
    //  mu_check(vimCursorGetLine() == 50);
    //
    //  vimInput("z");
    //  vimInput("z");
    //  mu_check(vimWindowGetTopLine() == 49);
    //  mu_check(vimCursorGetLine() == 50);
    //
    //  vimInput("z");
    //  vimInput("b");
    //  mu_check(vimWindowGetTopLine() == 48);
    //  mu_check(vimCursorGetLine() == 50);
    //
    //  vimInput("z");
    //  vimInput("t");
    //  mu_check(vimWindowGetTopLine() == 50);
    //  mu_check(vimCursorGetLine() == 50);
    //}

    //func test_h_m_l()
    //{
    //  vimWindowSetWidth(80);
    //  vimWindowSetHeight(40);
    //
    //  mu_check(vimCursorGetLine() == 50);
    //
    //  vimInput("z");
    //  vimInput("z");
    //
    //  vimInput("H");
    //  mu_check(vimCursorGetLine() == 31);
    //
    //  vimInput("L");
    //  mu_check(vimCursorGetLine() == 70);
    //
    //  vimInput("M");
    //  mu_check(vimCursorGetLine() == 50);
    //}

    //func test_no_.after_setting_topline()
    //{
    //  vimWindowSetWidth(10);
    //  vimWindowSetHeight(10);
    //
    //  pos_T pos;
    //  pos.lnum = 95;
    //  pos.col = 1;
    //
    //  vimCursorSetPosition(pos);
    //
    //  vimWindowSetTopLeft(90, 1);
    //
    //  mu_check(vimWindowGetTopLine() == 90);
    //  vimInput("j");
    //
    //  mu_check(vimWindowGetTopLine() == 90);
    //  mu_check(vimCursorGetLine() == 96);
    //}
    //
    //func test_.left_at_boundary()
    //{
    //  vimWindowSetWidth(4);
    //  vimWindowSetHeight(10);
    //
    //  vimInput("l");
    //  mu_check(vimWindowGetLeftColumn() == 0);
    //
    //  vimInput("l");
    //  mu_check(vimWindowGetLeftColumn() == 0);
    //
    //  vimInput("l");
    //  mu_check(vimWindowGetLeftColumn() == 0);
    //
    //  vimInput("l");
    //  mu_check(vimWindowGetLeftColumn() == 1);
    //
    //  vimInput("l");
    //  mu_check(vimWindowGetLeftColumn() == 2);
    //}

    //func test_no_.after_setting_left()
    //{
    //  vimWindowSetWidth(4);
    //  vimWindowSetHeight(10);
    //
    //  pos_T pos;
    //  pos.lnum = 99;
    //  pos.col = 2;
    //  vimCursorSetPosition(pos);
    //
    //  vimWindowSetTopLeft(1, 2);
    //
    //  vimInput("l");
    //  mu_check(vimWindowGetLeftColumn() == 2);
    //
    //  vimInput("l");
    //  mu_check(vimWindowGetLeftColumn() == 2);
    //
    //  vimInput("l");
    //  mu_check(vimWindowGetLeftColumn() == 2);
    //
    //  vimInput("l");
    //  mu_check(vimWindowGetLeftColumn() == 3);
    //}

    func test_ctrl_d() {
        vimKey("<c-d>");
        mu_check(scrollRequestCount == 1);
        mu_check(lastScrollDirection == .halfPageDown);
        mu_check(lastScrollCount == 0);
    }

    func test_ctrl_u() {
        vimKey("<c-u>");
        mu_check(scrollRequestCount == 1);
        mu_check(lastScrollDirection == .halfPageUp);
        mu_check(lastScrollCount == 0);
    }

    func test_ctrl_e() {
        vimInput("g");
        vimInput("g");

        vimKey("<c-e>");

        mu_check(scrollRequestCount == 1);
        mu_check(lastScrollDirection == .lineUp);
        mu_check(lastScrollCount == 1);

        vimKey("5<c-e>");

        mu_check(scrollRequestCount == 2);
        mu_check(lastScrollDirection == .lineUp);
        mu_check(lastScrollCount == 5);
    }

    func test_ctrl_y()
    {
        vimWindowSetHeight(49);

        vimKey("<c-y>");

        mu_check(scrollRequestCount == 1);
        mu_check(lastScrollDirection == .lineDown);
        mu_check(lastScrollCount == 1);

        vimKey("5<c-y>");

        mu_check(scrollRequestCount == 2);
        mu_check(lastScrollDirection == .lineDown);
        mu_check(lastScrollCount == 5);
    }
}
