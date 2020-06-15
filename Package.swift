// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
let swiftSettings: [SwiftSetting] = [
    .define("CRYPTO_IN_SWIFTPM")
]
let package = Package(
    name: "MnemonicSwift",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "MnemonicSwift",
            targets: ["MnemonicSwift"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "git@github.com:apple/swift-crypto.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "MnemonicSwift",
            dependencies: ["Crypto"]),
        .testTarget(
            name: "MnemonicSwiftTests",
            dependencies: ["MnemonicSwift"])
    ]
)
