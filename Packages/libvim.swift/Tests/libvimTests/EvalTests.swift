//
//  EvalTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class EvalTests: VimTestCase {
    var getCharLastMode = -2
    var getCharReturn = Character.nul
    var getCharReturnMod = 0

    override func setUp() {
        super.setUp()

        vimSetMessageCallback { title, message, _ in
            print("onMessage - title: |\(title)| contents: |\(message)|")
        }

        vimSetFunctionGetCharCallback { [unowned self] mode, c, modMask in
            getCharLastMode = mode
            c!.pointee = CChar(getCharReturn.asciiValue!)
            modMask!.pointee = CInt(getCharReturnMod)
            print("onGetChar called with mode: ", mode)
            return OK
        }

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");
        vimInput("g");
        vimInput("g");
        vimInput("0");
    }

    func test_simple_addition() {
        let result = vimEval("2+2");

        mu_check(strcmp(result, "4") == 0);
    }

    func test_empty() {
        let result = vimEval("");

        mu_check(result == nil);
    }

    func test_exe_norm_delete_line() {
        mu_check(vimBufferGetLineCount(curbuf) == 3);
        vimExecute("source \(collateral)/ex_normal.vim");
        vimExecute("call NormDeleteLine()");
        mu_check(vimBufferGetLineCount(curbuf) == 2);
    }

    func test_exe_norm_insert_character() {
        mu_check(vimBufferGetLineCount(curbuf) == 3);
        vimExecute("source \(collateral)/ex_normal.vim");
        vimExecute("call NormInsertCharacter()");
        mu_check(vimBufferGetLineCount(curbuf) == 3);
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "aThis is the first line of a test file") == 0);
    }

    func test_exe_norm_insert_character_both_sides() {
        mu_check(vimBufferGetLineCount(curbuf) == 3);
        vimExecute("source \(collateral)/ex_normal.vim");
        vimExecute("call NormInsertCharacterBothSides()");
        mu_check(vimBufferGetLineCount(curbuf) == 3);
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "aThis is the first line of a test fileb") == 0);
    }

    func test_exe_norm_insert_character_both_sides_multiple_lines() {
        mu_check(vimBufferGetLineCount(curbuf) == 3);
        vimExecute("source \(collateral)/ex_normal.vim");
        vimExecute("call NormInsertCharacterBothSidesMultipleLines()");
        mu_check(vimBufferGetLineCount(curbuf) == 3);
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "aThis is the first line of a test fileb") == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 2), "aThis is the second line of a test fileb") == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 3), "aThis is the third line of a test fileb") == 0);
    }

    func test_range_norm_insert_all_lines() {
        mu_check(vimBufferGetLineCount(curbuf) == 3);
        vimExecute("g/line/norm! Ia");
        mu_check(vimBufferGetLineCount(curbuf) == 3);
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "aThis is the first line of a test file") == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 2), "aThis is the second line of a test file") == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 3), "aThis is the third line of a test file") == 0);
    }

    func test_range_norm_insert_single_line() {
        mu_check(vimBufferGetLineCount(curbuf) == 3);
        vimExecute("g/second/norm! Ia");
        mu_check(vimBufferGetLineCount(curbuf) == 3);
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "This is the first line of a test file") == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 2), "aThis is the second line of a test file") == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 3), "This is the third line of a test file") == 0);
    }

    func test_inverse_range_norm() {
        mu_check(vimBufferGetLineCount(curbuf) == 3);
        vimExecute("g!/second/norm! Ia");
        mu_check(vimBufferGetLineCount(curbuf) == 3);
        mu_check(strcmp(vimBufferGetLine(curbuf, 1), "aThis is the first line of a test file") == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 2), "This is the second line of a test file") == 0);
        mu_check(strcmp(vimBufferGetLine(curbuf, 3), "aThis is the third line of a test file") == 0);
    }

    func test_getchar() {
        // Getchar with no arguments
        getCharReturn = "a"
        let szNoArgs = vimEval("getchar()");
        mu_check(getCharLastMode == -1);
        mu_check(strcmp(szNoArgs, "97") == 0);

        getCharReturn = .nul
        let szOne = vimEval("getchar(1)");
        mu_check(getCharLastMode == 1);
        mu_check(strcmp(szOne, "0") == 0);

        getCharReturn = "b";
        let szZero = vimEval("getchar(0)");
        mu_check(getCharLastMode == 0);
        mu_check(strcmp(szZero, "98") == 0);
    }
}
