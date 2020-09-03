// Copyright Keefer Taylor, 2018
// Copyright Electric Coin Company, 2020
import CryptoKit
import Foundation
import Security
public enum MnemonicLanguageType {
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
}

public enum Mnemonic {
    /// Generate a mnemonic from the given hex string in the given language.
    ///
    /// - Parameters:
    ///   - hexString: The hex string to generate a mnemonic from.
    ///   - language: The language to use. Default is english.
    /// - Returns: the mnemonic string or nil if input is invalid
    public static func mnemonicString(from hexString: String, language: MnemonicLanguageType = .english) -> String? {
        guard let seedData = hexString.mnemonicData() else { return nil }
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
                return nil
            }
            mnemonic.append(words[index])
        }
        return mnemonic.joined(separator: " ")
    }

    /// Generate a deterministic seed string from the given inputs.
    ///
    /// - Parameters:
    ///   - mnemonic: The mnemonic to use.
    ///   - iterations: The iterations to perform in the PBKDF2 algorithm. Default is 2048.
    ///   - passphrase: An optional passphrase. Default is the empty string.
    ///   - language: The language to use. Default is english.
    /// - Returns: hexString representing the deterministic seed bytes or `nil` if the given mnemonic is invalid
    public static func deterministicSeedString(
        from mnemonic: String,
        iterations: Int = 2_048,
        passphrase: String = "",
        language: MnemonicLanguageType = .english
    ) -> String? {
        deterministicSeedBytes(from: mnemonic, iterations: iterations, passphrase: passphrase, language: language)?.hexString
    }

    /// Generate a deterministic seed string from the given inputs.
    ///
    /// - Parameters:
    ///   - mnemonic: The mnemonic to use.
    ///   - iterations: The iterations to perform in the PBKDF2 algorithm. Default is 2048.
    ///   - passphrase: An optional passphrase. Default is the empty string.
    ///   - language: The language to use. Default is english.
    /// - Returns: a byte array representing the deterministic seed bytes or `nil` if the given mnemonic is invalid

    public static func deterministicSeedBytes(
        from mnemonic: String,
        iterations: Int = 2_048,
        passphrase: String = "",
        language: MnemonicLanguageType = .english
    ) -> [UInt8]? {

        do {
            try self.validate(mnemonic: mnemonic)
        } catch {
            return nil
        }
        guard let normalizedData = self.normalized(string: mnemonic),
            let saltData = normalized(string: "mnemonic" + passphrase) else {
                return nil
        }

        let passwordBytes = normalizedData.map { Int8(bitPattern: $0) }

        do {
            let bytes =
                try PKCS5.PBKDF2SHA512(password: passwordBytes, salt: [UInt8](saltData), iterations: iterations)
            return bytes
        } catch {
            return nil
        }
    }

    /// Generate a mnemonic of the given strength and given language.
    ///
    /// - Parameters:
    ///   - strength: The strength to use. This must be a multiple of 32.
    ///   - language: The language to use. Default is english.
    /// -- Returns: the random mnemonic phrase of the given strenght and language or `nil` if the strength is invalid or an error occurs
    public static func generateMnemonic(strength: Int, language: MnemonicLanguageType = .english)
        -> String? {
            guard strength % 32 == 0 else {
                return nil
            }

            let count = strength / 8
            var bytes = [UInt8](repeating: 0, count: count)

            guard SecRandomCopyBytes(kSecRandomDefault, count, &bytes) == errSecSuccess else { return nil }

            return mnemonicString(from: bytes.hexString, language: language)
    }

    /// Validate that the given string is a valid mnemonic.
    public static func validate(mnemonic: String) throws {
        let normalizedMnemonic = mnemonic.trimmingCharacters(in: .whitespacesAndNewlines)
        let mnemonicComponents = normalizedMnemonic.components(separatedBy: " ")
        guard !mnemonicComponents.isEmpty else {
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

    static func determineLanguage(from mnemonicWords: [String]) throws -> MnemonicLanguageType {
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
    fileprivate static func normalized(string: String) -> Data? {
        guard let data = string.data(using: .utf8, allowLossyConversion: true),
            let dataString = String(data: data, encoding: .utf8),
            let normalizedData = dataString.data(using: .utf8, allowLossyConversion: false) else {
                return nil
        }
        return normalizedData
    }
}

extension PKCS5 {
    public static func PBKDF2SHA512(password: String, salt: String, iterations: Int = 2_048, keyLength: Int = 64) throws -> Array<UInt8> {

        guard let saltData = Mnemonic.normalized(string: salt) else {
            throw PKCS5.Error.invalidInput
        }

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
