//
//  MnemonicInteractor.swift
//  MnemonicSwift
//
//  Created by Adam Stener on 12/17/21.
//

import Foundation

public struct MnemonicInteractor {

    /// Generate a mnemonic from the given hex string in the given language.
    ///
    /// - Parameters:
    ///   - hexString: The hex string to generate a mnemonic from.
    /// - Returns: the mnemonic string or nil if input is invalid
    /// - Throws:
    ///   - `MnemonicError.InvalidHexString`:  when an invalid string is given
    ///   - `MnemonicError.invalidBitString` when the resulting bitstring generates an invalid word index
    let mnemonicEnglishString: (String) throws -> String

    /// Generate a mnemonic from the given hex string in the given language.
    ///
    /// - Parameters:
    ///   - hexString: The hex string to generate a mnemonic from.
    ///   - language: The language to use. Default is english.
    /// - Returns: the mnemonic string or nil if input is invalid
    /// - Throws:
    ///   - `MnemonicError.InvalidHexString`:  when an invalid string is given
    ///   - `MnemonicError.invalidBitString` when the resulting bitstring generates an invalid word index
    let mnemonicString: (String, MnemonicLanguageType) throws -> String

    /// Generate a deterministic seed string from a Mnemonic String.
    ///
    /// - Parameters:
    ///   - mnemonic: The mnemonic to use.
    ///   - iterations: The iterations to perform in the PBKDF2 algorithm. Default is 2048.
    ///   - passphrase: An optional passphrase. Default is the empty string.
    ///   - language: The language to use. Default is english.
    /// - Returns: hexString representing the deterministic seed bytes
    /// - Throws: `MnemonicError.checksumError` if checksum fails, `MnemonicError.invalidInput` if received input is invalid
    let deterministicSeedString: (String, Int, String, MnemonicLanguageType) throws -> String

    /// Generate a deterministic seed bytes from a Mnemonic String.
    ///
    /// - Parameters:
    ///   - mnemonic: The mnemonic to use.
    ///   - iterations: The iterations to perform in the PBKDF2 algorithm. Default is 2048.
    ///   - passphrase: An optional passphrase. Default is the empty string.
    ///   - language: The language to use. Default is english.
    /// - Returns: a byte array representing the deterministic seed bytes
    /// - Throws: `MnemonicError.checksumError` if checksum fails, `MnemonicError.invalidInput` if received input is invalid
    let deterministicSeedBytes: (String, Int, String, MnemonicLanguageType) throws -> [UInt8]

    /// Generate a mnemonic of the given strength and given language.
    ///
    /// - Parameters:
    ///   - strength: The strength to use. This must be a multiple of 32.
    ///   - language: The language to use.
    /// - Returns: the random mnemonic phrase of the given strenght and language or `nil` if the strength is invalid or an error occurs
    /// - Throws:
    ///  - `MnemonicError.InvalidInput` if stregth is invalid in the terms of BIP-39
    ///  - `MnemonicError.entropyCreationFailed` if random bytes created for entropy fails
    ///  - `MnemonicError.InvalidHexString`  when an invalid string is given
    ///  - `MnemonicError.invalidBitString` when the resulting bitstring generates an invalid word index
    let generateMnemonic: (Int, MnemonicLanguageType) throws -> String

    /// Generate a mnemonic of the given strength and given language.
    ///
    /// - Parameters:
    ///   - strength: The strength to use. This must be a multiple of 32.
    /// - Returns: the random mnemonic phrase of the given strenght and language or `nil` if the strength is invalid or an error occurs
    /// - Throws:
    ///  - `MnemonicError.InvalidInput` if stregth is invalid in the terms of BIP-39
    ///  - `MnemonicError.entropyCreationFailed` if random bytes created for entropy fails
    ///  - `MnemonicError.InvalidHexString`  when an invalid string is given
    ///  - `MnemonicError.invalidBitString` when the resulting bitstring generates an invalid word index
    let generateEnglishMnemonic: (Int) throws -> String

    /// Validate that the given string is a valid mnemonic phrase according to BIP-39
    /// - Parameters:
    ///  - mnemonic: a mnemonic phrase string
    /// - Throws:
    ///  - `MnemonicError.wrongWordCount` if the word count is invalid
    ///  - `MnemonicError.invalidWord(word: word)` this phase as a word that's not represented in this library's vocabulary for the detected language.
    ///  - `MnemonicError.unsupportedLanguage` if the given phrase language isn't supported or couldn't be infered
    ///  - `throw MnemonicError.checksumError` if the given phrase has an invalid checksum
    let validate: (String) throws -> Void

    let determineLanguage: ([String]) throws -> MnemonicLanguageType

    /// Change a string into data.
    /// - Parameter string: the string to convert
    /// - Returns: the utf8 encoded data
    /// - Throws: `MnemonicError.invalidInput` if the given String cannot be converted to Data
    let normalizedString: (String) throws -> Data

    init(
        mnemonicEnglishString: @escaping (String) throws -> String = { hexString in
            try Mnemonic.mnemonicString(from: hexString)
        },
        mnemonicString: @escaping (
            String,
            MnemonicLanguageType
        ) throws -> String = { hexString, languageType in
            try Mnemonic.mnemonicString(from: hexString, language: languageType)
        },
        deterministicSeedString: @escaping (
            String,
            Int,
            String,
            MnemonicLanguageType
        ) throws -> String = { mnemonic, iterations, passphrase, language in
            try Mnemonic.deterministicSeedString(
                from: mnemonic,
                iterations: iterations,
                passphrase: passphrase,
                language: language
            )
        },
        deterministicSeedBytes: @escaping (
            String,
            Int,
            String,
            MnemonicLanguageType
        ) throws -> [UInt8] = { mnemonic, iterations, passphrase, language in
            try Mnemonic.deterministicSeedBytes(
                from: mnemonic,
                iterations: iterations,
                passphrase: passphrase,
                language: language
            )
        },
        generateMnemonic: @escaping (
            Int,
            MnemonicLanguageType
        ) throws -> String = { strength, language in
            try Mnemonic.generateMnemonic(strength: strength, language: language)
        },
        generateEnglishMnemonic: @escaping (Int) throws -> String = { strength in
            try Mnemonic.generateMnemonic(strength: strength)
        },
        validate: @escaping (String) throws -> Void = { mnemonic in
            try Mnemonic.validate(mnemonic: mnemonic)
        },
        determineLanguage: @escaping ([String]) throws -> MnemonicLanguageType = { mnemonicWords in
            try Mnemonic.determineLanguage(from: mnemonicWords)
        },
        normalizedString: @escaping (String) throws -> Data = { string in
            try Mnemonic.normalizedString(string)
        }
    ) {
        self.mnemonicEnglishString = mnemonicEnglishString
        self.mnemonicString = mnemonicString
        self.deterministicSeedString = deterministicSeedString
        self.deterministicSeedBytes = deterministicSeedBytes
        self.generateMnemonic = generateMnemonic
        self.generateEnglishMnemonic = generateEnglishMnemonic
        self.validate = validate
        self.determineLanguage = determineLanguage
        self.normalizedString = normalizedString
    }
}

extension MnemonicInteractor {
    static let live = MnemonicInteractor()

    static let throwing = MnemonicInteractor(
        mnemonicEnglishString: { _ in
            throw MnemonicError.invalidHexstring
        },
        mnemonicString: { _, _ in
            throw MnemonicError.invalidHexstring
        },
        deterministicSeedString: { _, _, _, _ in
            throw MnemonicError.invalidInput
        },
        deterministicSeedBytes: { _, _, _, _ in
            throw MnemonicError.invalidInput
        },
        generateMnemonic: { _, _ in
            throw MnemonicError.invalidHexstring
        },
        generateEnglishMnemonic: { _ in
            throw MnemonicError.invalidHexstring
        },
        validate: { _ in
            throw MnemonicError.checksumError
        },
        determineLanguage: { _ in
            throw MnemonicError.invalidWord(word: "word")
        },
        normalizedString: { _ in
            throw MnemonicError.invalidInput
        }
    )
}
