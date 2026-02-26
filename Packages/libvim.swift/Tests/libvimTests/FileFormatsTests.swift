//
//  FileFormatsTests.swift
//
//
//  Created by Kaï-Zen Berg-Šæmañn on 2024-03-03.
//

import XCTest
import libvim

final class FileFormatsTests: VimTestCase {
    override func setUp() {
        super.setUp()

        vimKey("<esc>");
        vimKey("<esc>");

        vimExecute("e!");
        vimInput("g");
        vimInput("g");
    }

    func test_open_crlf_file() {
        vimBufferOpen("\(collateral)/test.crlf", 1, 0);

        let ff = vimBufferGetFileFormat(curbuf);
        print("file format: ", ff);
        mu_check(ff == .dos);
    }

    func test_open_lf_file() {
        vimBufferOpen("\(collateral)/test.lf", 1, 0);

        let ff = vimBufferGetFileFormat(curbuf);
        print("file format: ", ff);
        mu_check(ff == .unix);
    }

    func test_write_crlf_file() {
        vimBufferOpen("\(collateral)/test.crlf", 1, 0);

        let tmp = vim_tempname("t", FALSE);
        let cmd = "w \(tmp)";

        vimExecute(cmd);

        // Verify file did get overwritten
        var buff = [CChar](repeating: 0, count: 255)
        let fp = fopen(tmp, "rb")

        // Get first line
        if let fp = fp {
            fgets(&buff, 255, fp)
            fclose(fp)
        }

        mu_check(strcmp(buff, "a\r\n") == 0);

    }

    func test_write_lf_file() {
        vimBufferOpen("\(collateral)/test.lf", 1, 0);
        let tmp = vim_tempname("t", FALSE);

        let cmd = "w \(tmp)"

        vimExecute(cmd);

        // Verify file did get overwritten
        var buff = [CChar](repeating: 0, count: 255)
        let fp = fopen(tmp, "rb")

        // Get first line
        if let fp = fp {
            fgets(&buff, 255, fp)
            fclose(fp)
        }

        mu_check(strcmp(buff, "a\n") == 0);
    }

    func test_convert_crlf_to_lf() {
        let buf = vimBufferOpen("\(collateral)/test.crlf", 1, 0);
        vimBufferSetFileFormat(buf, .unix);

        let ff = vimBufferGetFileFormat(buf);
        mu_check(ff == .unix);
    }

    func test_convert_lf_to_crlf() {
        let buf = vimBufferOpen("\(collateral)/test.lf", 1, 0);
        vimBufferSetFileFormat(buf, .dos);

        let ff = vimBufferGetFileFormat(buf);
        mu_check(ff == .dos);
    }

    /*func test_open_cr_file() {
     vimBufferOpen("collateral/test.cr", 1, 0);

     int ff = get_fileformat(curbuf);
     printf("file format: %d\n", ff);
     mu_check(ff == EOL_MAC);
     }*/

}
