# MnemonicSwift

[![Build Status](https://travis-ci.org/zcash-hackworks/MnemonicSwift.svg?branch=master)](https://travis-ci.org/zcash-hackworks/MnemonicSwift)

An implementation of BIP39 in Swift. MnemonicSwift supports both English and Chinese mnemonics.

This library is a fork of [MnemonicKit](https://github.com/keefertaylor/MnemonicKit). This fork provides provides support for BIP39 using Crypto.

**NOTE to 1.0.0 users**: If you are using 1.0.0 in your project, we no longer maintain that version. Upgrade to 2.0.0 immediately. 

## Installation

### CocoaPods
MnemonicSwift supports installation via CocoaPods. You can depened on MnemonicSwift by adding the following to your Podfile:

```
pod "MnemonicSwift"
```

#### Carthage

If you use [Carthage](https://github.com/Carthage/Carthage) to manage your dependencies, simply add
MnemonicSwift to your `Cartfile`:

```
github "zcash-hackworks/MnemonicSwift"
```

## Usage

### Generate a Mnemonic

```swift
  let englishMnemonic = Mnemonic.generateMnemonic(strength: 64, language: .english)
  let chineseMnemonic = Mnemonic.generateMnemonic(strength: 128, language: .chinese)
```


### Generate a Mnemonic from a Hex Representation

```swift
  let hexRepresentation: String = ...
  let mnemonic = Mnemonic.mnemonicString(from: hexRepresentation)
  print("Mnemonic: \(mnemonic)\nFrom hex string: \(hexRepresentation)")
```

### Generate a Seed String

```swift
  let englishMnemonic = Mnemonic.generateMnemonic(strength: 64, language: .english)
  let passphrase: String = ...
  let deterministicSeedString = Mnemonic.deterministicSeedString(from: mnemonicString,
                                                                 passphrase: passphrase,
                                                                 language: .english)
  print("Deterministic Seed String: \(deterministicSeedString)")
```

## Setting up the project as contributor

To get set up:
```shell
$ brew install xcodegen # if you don't already have it
$ xcodegen generate # Generate an XCode project from Project.yml
$ open MnemonicSwift.xcodeproj
```

## License

Licensed under either of

 * Apache License, Version 2.0, ([LICENSE-APACHE](./LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
 * MIT license ([LICENSE-MIT](./LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

### Contribution

Unless you explicitly state otherwise, any contribution intentionally
submitted for inclusion in the work by you, as defined in the Apache-2.0
license, shall be dual licensed as above, without any additional terms or
conditions.
