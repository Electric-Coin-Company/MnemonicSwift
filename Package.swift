// swift-tools-version:5.3.0

import PackageDescription

let package = Package(
    name: "MnemonicSwift",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "MnemonicSwift",
            targets: ["MnemonicSwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", "2.1.0" ..< "3.0.0")
    ],
    targets: [
        .target(
            name: "MnemonicSwift",
            dependencies: [.product(name: "Crypto", package: "swift-crypto")],
            path: "MnemonicSwift",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "MnemonicSwiftTests",
            dependencies: ["MnemonicSwift"],
            path: "Tests",
            exclude: ["Info.plist"],
            resources: [.copy("vectors.json")])
    ]
)
