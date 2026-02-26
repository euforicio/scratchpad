//
//  MatchingPairTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class MatchingPairTests: VimTestCase {
    override func setUp() {
        super.setUp()

        vimBufferOpen("\(collateral)/brackets.txt", 1, 0);

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");
    }

    func test_matching_bracket() {
        let bracket = vimSearchGetMatchingPair(0)!

        mu_check(bracket.lnum == 6);
        mu_check(bracket.col == 0);
    }

    func test_matching_parentheses_cursor()
    {
        vimInput("l");
        vimInput("l");

        let bracket = vimSearchGetMatchingPair(0)!

        mu_check(bracket.lnum == 3);
        mu_check(bracket.col == 38);
    }

    func test_no_match()
    {
        vimInput("j")

        let bracket = vimSearchGetMatchingPair(0)

        XCTAssertNil(bracket)
    }
}
