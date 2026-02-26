// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "scratchpad",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(path: "Packages/Bonsplit"),
        .package(path: "Packages/libvim.swift"),
    ],
    targets: [
        .target(
            name: "ScratchpadCore",
            dependencies: [
                .product(name: "Bonsplit", package: "Bonsplit"),
                .product(name: "libvim", package: "libvim.swift"),
            ],
            path: "Sources",
            exclude: ["Info.plist", "scratchpad.entitlements"],
            resources: [.process("Resources")],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "Sources/Info.plist"])
            ]
        ),
        .executableTarget(
            name: "Scratchpad",
            dependencies: ["ScratchpadCore"],
            path: "Executable"
        ),
        .testTarget(
            name: "ScratchpadTests",
            dependencies: ["ScratchpadCore"],
            path: "Tests"
        ),
    ]
)
