// Copyright Keefer Taylor, 2018
// Copyright Electric Coin Company, 2020

#if canImport(CryptoKit)
import CryptoKit
#else
import Crypto
#endif

import Foundation
import Security

public enum MnemonicLanguageType: Codable, Equatable {
    case english
    case chinese

    func words() -> [String] {
        switch self {
        case .english:
            return String.englishMnemonics
        case .chinese:
            return String.chineseMnemonics
        }
    }
}

public enum MnemonicError: Error {
    case wrongWordCount
    case checksumError
    case invalidWord(word: String)
    case unsupportedLanguage
    case invalidHexstring
    case invalidBitString
    case invalidInput
    case entropyCreationFailed
}

public enum WordCount: Int {
    case twelve = 12
    case fifteen = 15
    case eighteen = 18
    case twentyOne = 21
    case twentFour = 24

    var bitLength: Int {
        self.rawValue / 3 * 32
    }

    var checksumLength: Int {
        self.rawValue / 3
    }
}

public enum Mnemonic {
    /// Generate a mnemonic from the given hex string in the given language.
    ///
    /// - Parameters:
    ///   - hexString: The hex string to generate a mnemonic from.
    ///   - language: The language to use. Default is english.
    /// - Returns: the mnemonic string or nil if input is invalid
    /// - Throws:
    ///   - `MnemonicError.InvalidHexString`:  when an invalid string is given
    ///   - `MnemonicError.invalidBitString` when the resulting bitstring generates an invalid word index
    public static func mnemonicString(from hexString: String, language: MnemonicLanguageType = .english) throws -> String {
        guard let seedData = hexString.mnemonicData() else { throw MnemonicError.invalidHexstring }
        let hashData = SHA256.hash(data: seedData)
        let checkSum = hashData.bytes.toBitArray()
        var seedBits = seedData.toBitArray()

        for i in 0 ..< seedBits.count / 32 {
            seedBits.append(checkSum[i])
        }

        let words = language.words()

        let mnemonicCount = seedBits.count / 11
        var mnemonic = [String]()
        for i in 0 ..< mnemonicCount {
            let length = 11
            let startIndex = i * length
            let subArray = seedBits[startIndex ..< startIndex + length]
            let subString = subArray.joined(separator: "")

            guard let index = Int(subString, radix: 2) else {
                throw MnemonicError.invalidBitString
            }
            mnemonic.append(words[index])
        }
        return mnemonic.joined(separator: " ")
    }

    /// Generate a deterministic seed string from a Mnemonic String.
    ///
    /// - Parameters:
    ///   - mnemonic: The mnemonic to use.
    ///   - iterations: The iterations to perform in the PBKDF2 algorithm. Default is 2048.
    ///   - passphrase: An optional passphrase. Default is the empty string.
    ///   - language: The language to use. Default is english.
    /// - Returns: hexString representing the deterministic seed bytes
    /// - Throws: `MnemonicError.checksumError` if checksum fails, `MnemonicError.invalidInput` if received input is invalid
    public static func deterministicSeedString(
        from mnemonic: String,
        iterations: Int = 2_048,
        passphrase: String = "",
        language: MnemonicLanguageType = .english
    ) throws -> String {
        try deterministicSeedBytes(from: mnemonic, iterations: iterations, passphrase: passphrase, language: language).hexString
    }

    /// Generate a deterministic seed bytes from a Mnemonic String.
    ///
    /// - Parameters:
    ///   - mnemonic: The mnemonic to use.
    ///   - iterations: The iterations to perform in the PBKDF2 algorithm. Default is 2048.
    ///   - passphrase: An optional passphrase. Default is the empty string.
    ///   - language: The language to use. Default is english.
    /// - Returns: a byte array representing the deterministic seed bytes
    /// - Throws: `MnemonicError.checksumError` if checksum fails, `MnemonicError.invalidInput` if received input is invalid
    public static func deterministicSeedBytes(
        from mnemonic: String,
        iterations: Int = 2_048,
        passphrase: String = "",
        language: MnemonicLanguageType = .english
    ) throws -> [UInt8] {
        let normalizedMnemonic = mnemonic.trimmingCharacters(in: .whitespacesAndNewlines)

        try self.validate(mnemonic: normalizedMnemonic)

        let normalizedData = try self.normalizedString(normalizedMnemonic)
        let saltData = try self.normalizedString("mnemonic" + passphrase)
        let passwordBytes = normalizedData.map { Int8(bitPattern: $0) }

        do {
            let bytes =
            try PKCS5.PBKDF2SHA512(password: passwordBytes, salt: [UInt8](saltData), iterations: iterations)
            return bytes
        } catch {
            throw MnemonicError.invalidInput
        }
    }

    /// Generate a mnemonic of the given strength and given language.
    ///
    /// - Parameters:
    ///   - strength: The strength to use. This must be a multiple of 32.
    ///   - language: The language to use. Default is english.
    /// - Returns: the random mnemonic phrase of the given strenght and language or `nil` if the strength is invalid or an error occurs
    /// - Throws:
    ///  - `MnemonicError.InvalidInput` if stregth is invalid in the terms of BIP-39
    ///  - `MnemonicError.entropyCreationFailed` if random bytes created for entropy fails
    ///  - `MnemonicError.InvalidHexString`  when an invalid string is given
    ///  - `MnemonicError.invalidBitString` when the resulting bitstring generates an invalid word index
    public static func generateMnemonic(
        strength: Int,
        language: MnemonicLanguageType = .english
    ) throws -> String {
        guard strength % 32 == 0 else {
            throw MnemonicError.invalidInput
        }

        let count = strength / 8
        var bytes = [UInt8](repeating: 0, count: count)

        guard SecRandomCopyBytes(kSecRandomDefault, count, &bytes) == errSecSuccess else {
            throw MnemonicError.entropyCreationFailed
        }

        return try mnemonicString(from: bytes.hexString, language: language)
    }

    /// Validate that the given string is a valid mnemonic phrase according to BIP-39
    /// - Parameters:
    ///  - mnemonic: a mnemonic phrase string
    /// - Throws:
    ///  - `MnemonicError.wrongWordCount` if the word count is invalid
    ///  - `MnemonicError.invalidWord(word: word)` this phase as a word that's not represented in this library's vocabulary for the detected language.
    ///  - `MnemonicError.unsupportedLanguage` if the given phrase language isn't supported or couldn't be infered
    ///  - `throw MnemonicError.checksumError` if the given phrase has an invalid checksum
    public static func validate(mnemonic: String) throws {
        let mnemonicComponents = mnemonic.components(separatedBy: " ")
        guard !mnemonicComponents.isEmpty else {
            throw MnemonicError.wrongWordCount
        }

        guard let wordCount = WordCount(rawValue: mnemonicComponents.count) else {
            throw MnemonicError.wrongWordCount
        }

        // determine the language of the seed or fail
        let language = try determineLanguage(from: mnemonicComponents)
        let vocabulary = language.words()

        // generate indices array
        var seedBits = ""
        for word in mnemonicComponents {
            guard let indexInVocabulary = vocabulary.firstIndex(of: word) else {
                throw MnemonicError.invalidWord(word: word)
            }

            let binaryString = String(indexInVocabulary, radix: 2).pad(toSize: 11)

            seedBits.append(contentsOf: binaryString)
        }

        let checksumLength = mnemonicComponents.count / 3

        guard checksumLength == wordCount.checksumLength else {
            throw MnemonicError.checksumError
        }

        let dataBitsLength = seedBits.count - checksumLength

        let dataBits = String(seedBits.prefix(dataBitsLength))
        let checksumBits = String(seedBits.suffix(checksumLength))

        guard let dataBytes = dataBits.bitStringToBytes() else {
            throw MnemonicError.checksumError
        }

        let hash = SHA256.hash(data: dataBytes)
        let hashBits = hash.bytes.toBitArray().joined(separator: "").prefix(checksumLength)

        guard hashBits == checksumBits else {
            throw MnemonicError.checksumError
        }

    }

    public static func determineLanguage(from mnemonicWords: [String]) throws -> MnemonicLanguageType {
        guard mnemonicWords.count > 0 else {
            throw MnemonicError.wrongWordCount
        }

        if String.englishMnemonics.contains(mnemonicWords[0]) {
            return .english
        } else if String.chineseMnemonics.contains(mnemonicWords[0]) {
            return .chinese
        } else {
            throw MnemonicError.unsupportedLanguage
        }
    }

    /// Change a string into data.
    /// - Parameter string: the string to convert
    /// - Returns: the utf8 encoded data
    /// - Throws: `MnemonicError.invalidInput` if the given String cannot be converted to Data
    public static func normalizedString(_ string: String) throws -> Data {
        guard let data = string.data(using: .utf8, allowLossyConversion: true),
              let dataString = String(data: data, encoding: .utf8),
              let normalizedData = dataString.data(using: .utf8, allowLossyConversion: false) else {
                  throw MnemonicError.invalidInput
              }
        return normalizedData
    }
}

extension PKCS5 {
    public static func PBKDF2SHA512(password: String, salt: String, iterations: Int = 2_048, keyLength: Int = 64) throws -> [UInt8] {

        let saltData = try Mnemonic.normalizedString(salt)

        return try PBKDF2SHA512(password: password.utf8.map({ Int8(bitPattern: $0) }), salt: [UInt8](saltData), iterations: iterations, keyLength: keyLength)
    }
}

extension Digest {
    var bytes: [UInt8] { Array(makeIterator()) }
    var data: Data { Data(bytes) }
    var hexString: String {
        bytes.hexString
    }
}

extension Array where Element == UInt8 {
    var hexString: String {
        self.map { String(format: "%02x", $0) }.joined()
    }
}
