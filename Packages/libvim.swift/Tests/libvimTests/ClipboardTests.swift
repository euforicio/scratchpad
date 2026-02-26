//
//  ClipboardTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-08.
//

import XCTest
import libvim

final class ClipboardTests: VimTestCase {
    override func setUp() {
        super.setUp()

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");
        vimInput("g");
        vimInput("g");
        vimInput("0");

        vimSetClipboardGetCallback(nil)
    }

    /* When clipboard is not enabled, the '*' register
     * should just behave like a normal register
     */
    func test_clipboard_not_enabled_star()
    {
        vimInput("\"");
        vimInput("*");

        vimInput("y");
        vimInput("y");

        let lines = vimRegisterGet(0)
        let numLines = lines.count
        mu_check(numLines == 1);
        print("LINE: ", lines[0]);
        mu_check(strcmp(lines[0], "This is the first line of a test file") == 0);
    }

//    // Alloc + copy
//    char_u *acopy(char_u *str)
//    {
//        char_u *sz = malloc(sizeof(char_u) * (strlen(str) + 1));
//        strcpy(sz, str);
//        sz[strlen(str)] = 0;
//        return sz;
//    };
//
//    int simpleClipboardTest(int regname, int *numlines, char_u ***lines, int *blockType)
//    {
//
//        printf("simpleClipboardTest called\n");
//        *blockType = MLINE;
//        *numlines = 1;
//        *lines = ALLOC_ONE(char_u *);
//        (*lines)[0] = acopy("Hello, World");
//        return TRUE;
//    };
    private func simpleClipboardTest(_ regName: Character) -> (lines: [String], blockType: Vim.MotionType)? {
        print("\(#function) called")
        return (
            lines: ["Hello, World"],
            blockType: .lineWise
        )
    }

//    int charClipboardTest(int regname, int *numlines, char_u ***lines, int *blockType)
//    {
//
//        printf("charClipboardTest called\n");
//        *blockType = MCHAR;
//        *numlines = 1;
//        *lines = ALLOC_ONE(char_u *);
//        (*lines)[0] = acopy("abc");
//        return TRUE;
//    };
    private func charClipboardTest(_ regName: Character) -> (lines: [String], blockType: Vim.MotionType)? {
        print("\(#function) called")
        return (
            lines: ["abc"],
            blockType: .charWise
        )
    }
//
//    int multipleLineClipboardTest(int regname, int *numlines, char_u ***lines, int *blockType)
//    {
//        printf("multipleLineClipboardTest called\n");
//        *blockType = MLINE;
//        *numlines = 3;
//        *lines = ALLOC_MULT(char_u *, 3);
//        (*lines)[0] = acopy("Hello2");
//        (*lines)[1] = acopy("World");
//        (*lines)[2] = acopy("Again");
//        printf("multipleLineClipboardTest done\n");
//        return TRUE;
//    };
    private func multipleLineClipboardTest(_ regName: Character) -> (lines: [String], blockType: Vim.MotionType)? {
        print("\(#function) called")
        return (
            lines: ["Hello2", "World", "Again"],
            blockType: .lineWise
        )
    }
//
//    int falseClipboardTest(int regname, int *numlines, char_u ***lines, int *blockType)
//    {
//        return FALSE;
//    }
//
    private func falseClipboardTest(_ regName: Character) -> (lines: [String], blockType: Vim.MotionType)? {
        nil
    }

    func test_paste_from_clipboard() {
        vimSetClipboardGetCallback(simpleClipboardTest);

        vimInput("\"");
        vimInput("*");

        vimInput("P");

        let line = vimBufferGetLine(curbuf, 1);

        print("LINE: |\(line)|");
        mu_check(strcmp(line, "Hello, World") == 0);
    }

    func test_paste_from_clipboard_mchar() {
        vimSetClipboardGetCallback(charClipboardTest);

        vimInput("p");

        let line = vimBufferGetLine(curbuf, 1);

        print("LINE: |\(line)|");
        mu_check(strcmp(line, "Tabchis is the first line of a test file") == 0);
    }

    func test_paste_from_clipboard_mchar_star_register() {
        vimSetClipboardGetCallback(charClipboardTest);

        vimInput("\"");
        vimInput("*");
        vimInput("p");

        let line = vimBufferGetLine(curbuf, 1);

        print("LINE: |\(line)|");
        mu_check(strcmp(line, "Tabchis is the first line of a test file") == 0);
    }

    func test_paste_multiple_lines_from_clipboard() {
        vimSetClipboardGetCallback(multipleLineClipboardTest);

        vimInput("\"");
        vimInput("+");

        vimInput("P");

        let line1 = vimBufferGetLine(curbuf, 1);
        print("LINE1: |\(line1)|");
        let line2 = vimBufferGetLine(curbuf, 2);
        print("LINE2: |\(line2)|");
        let line3 = vimBufferGetLine(curbuf, 3);
        print("LINE3: |\(line3)|");

        mu_check(strcmp(line1, "Hello2") == 0);
        mu_check(strcmp(line2, "World") == 0);
        mu_check(strcmp(line3, "Again") == 0);
    }

    func test_paste_overrides_default_register() {
        // If there is a callback set, and it returns lines,
        // it should overwrite the register.
        vimSetClipboardGetCallback(multipleLineClipboardTest);

        vimInput("y");
        vimInput("y");

        // The 'P' should pull from the clipboard callback,
        // overriding what was yanked.
        vimInput("P");

        let line1 = vimBufferGetLine(curbuf, 1);
        print("LINE1: |\(line1)|");
        let line2 = vimBufferGetLine(curbuf, 2);
        print("LINE2: |\(line2)|");
        let line3 = vimBufferGetLine(curbuf, 3);
        print("LINE3: |\(line3)|");

        mu_check(strcmp(line1, "Hello2") == 0);
        mu_check(strcmp(line2, "World") == 0);
        mu_check(strcmp(line3, "Again") == 0);
    }

    /* When clipboard returns false, everything
     * should just behave like a normal register
     */
    func test_clipboard_returns_false() {
        vimSetClipboardGetCallback(falseClipboardTest);

        vimInput("\"");
        vimInput("b");

        vimInput("y");
        vimInput("y");

        let lines = vimRegisterGet("b")

        mu_check(lines.count == 1);
        print("LINE: ", lines[0]);
        mu_check(strcmp(lines[0], "This is the first line of a test file") == 0);
    }

    func test_clipboard_returns_false_doesnt_override_default() {
        vimSetClipboardGetCallback(falseClipboardTest);

        vimInput("y");
        vimInput("y");

        vimInput("P");

        let line1 = vimBufferGetLine(curbuf, 1);
        print("LINE1: |\(line1)|");
        let line2 = vimBufferGetLine(curbuf, 2);
        print("LINE2: |\(line2)|");

        mu_check(strcmp(line1, "This is the first line of a test file") == 0);
        mu_check(strcmp(line2, "This is the first line of a test file") == 0);
    }
}
