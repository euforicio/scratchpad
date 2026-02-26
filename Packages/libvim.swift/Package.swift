// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "libvim",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "libvim",
            targets: ["libvim"])
    ],
    targets: [
        .target(
            name: "clibvim",
            sources: [
              "auto/pathdef.c",
              "init.c",
              "xdiff/xdiffi.c",
              "xdiff/xemit.c",
              "xdiff/xhistogram.c",
              "xdiff/xpatience.c",
              "xdiff/xprepare.c",
              "xdiff/xutils.c",
            ].map { "src/" + $0 }
              + [
              "arabic.c",
              "autocmd.c",
              "blob.c",
              "buffer.c",
              "change.c",
              "channel.c",
              "charset.c",
              "debugger.c",
              "dict.c",
              "diff.c",
              "digraph.c",
              "edit.c",
              "eval.c",
              "evalfunc.c",
              "ex_cmds.c",
              "ex_cmds2.c",
              "ex_docmd.c",
              "ex_eval.c",
              "ex_getln.c",
              "fileio.c",
              "findfile.c",
              "fold.c",
              "getchar.c",
              "hashtab.c",
              "json.c",
              "libvim.c",
              "list.c",
              "mark.c",
              "mbyte.c",
              "memfile.c",
              "memline.c",
              "message.c",
              "message2.c",
              "misc1.c",
              "misc2.c",
              "move.c",
              "normal.c",
              "ops.c",
              "option.c",
              "os_mac_conv.c",
              "os_macosx.m",
              "os_unix.c",
              "pty.c",
              "quickfix.c",
              "regexp.c",
              "screen.c",
              "sds.c",
              "search.c",
              "sha256.c",
              "sign.c",
              "state_insert_literal.c",
              "state_machine.c",
              "syntax.c",
              "tag.c",
              "term.c",
              "ui.c",
              "undo.c",
              "usercmd.c",
              "userfunc.c",
              "version.c",
              "window.c",
            ].map { "onilibvim/src/" + $0 },
            cSettings: [
                .define("HAVE_CONFIG_H"),
                .define("MACOS_X"),
                .define("MACOS_X_DARWIN"),
                .headerSearchPath("."),
                .headerSearchPath("include"),
                .headerSearchPath("include/auto"),
                .headerSearchPath("onilibvim/src"),
                .headerSearchPath("onilibvim/src/proto"),
            ]

        ),
        .target(
          name: "libvim",
          dependencies: [ "clibvim" ]
        ),
        .testTarget(
            name: "libvimTests",
            dependencies: ["libvim"],
            resources: [
                .copy("Resources/collateral")
            ]
        ),
    ]
)
