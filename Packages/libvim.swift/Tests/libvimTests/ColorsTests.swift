//
//  ColorsTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class ColorsTests: VimTestCase {
    var colorSchemeChangedCount = 0
    var lastColorScheme: String!

    override func setUp() {
        super.setUp()

        vimColorSchemeSetChangedCallback { [unowned self] colorScheme in
            colorSchemeChangedCount++
            lastColorScheme = colorScheme
            return true
        }

        vimColorSchemeSetCompletionCallback { context in
            context.colorSchemes = [ "scheme1", "scheme2", "scheme3" ]
            return true
        }

        vimKey("<esc>");
        vimKey("<esc>");
        vimExecute("e!");

        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_colorscheme_changed()
    {
        vimExecute("colorscheme test");

        mu_check(colorSchemeChangedCount == 1);
        mu_check(strcmp(lastColorScheme, "test") == 0);

        vimExecute("colorscheme Multi Word Scheme");
        mu_check(colorSchemeChangedCount == 2);
        mu_check(strcmp(lastColorScheme, "Multi Word Scheme") == 0);

        vimExecute("colorscheme");
        mu_check(colorSchemeChangedCount == 3);
        mu_check(lastColorScheme == nil);
    }

    func test_colorscheme_changed_no_callback()
    {
        vimColorSchemeSetChangedCallback(nil);

        vimExecute("colorscheme test");

        mu_check(colorSchemeChangedCount == 0);

        vimExecute("colorscheme");
        mu_check(colorSchemeChangedCount == 0);
    }

    func test_colorscheme_get_completions()
    {
        var xpc = Vim.Expand()
        let pattern = ""
        xpc.expandOne(pattern,
                      nil,
                      [.silent, .useNL, .addSlash, .noBeep],
                      .allKeep);

        mu_check(xpc.files.count == 3);
        mu_check(strcmp(xpc.files[0], "scheme1") == 0);
        mu_check(strcmp(xpc.files[1], "scheme2") == 0);
        mu_check(strcmp(xpc.files[2], "scheme3") == 0);
    }

    func test_colorscheme_get_completions_no_provider() {
        vimColorSchemeSetCompletionCallback(nil)

        var xpc = Vim.Expand()
        let pattern = ""
        xpc.expandOne(pattern,
                      nil,
                      [.silent, .useNL, .addSlash, .noBeep],
                      .allKeep);
        mu_check(xpc.files.count == 0);

    }
}
