// Copyright Keefer Taylor, 2018

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

public enum Mnemonic {
    /// Generate a mnemonic from the given hex string in the given language.
    ///
    /// - Parameters:
    ///   - hexString: The hex string to generate a mnemonic from.
    ///   - language: The language to use. Default is english.
    public static func mnemonicString(from hexString: String, language: MnemonicLanguageType = .english) -> String? {
        let seedData = hexString.mnemonicData()
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

            let index = Int(strtoul(subString, nil, 2))
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
    public static func deterministicSeedString(
        from mnemonic: String,
        iterations: Int = 2_048,
        passphrase: String = "",
        language _: MnemonicLanguageType = .english
    ) -> String? {
        deterministicSeedBytes(from: mnemonic)?.hexString
    }
    
    public static func deterministicSeedBytes(
        from mnemonic: String,
        iterations: Int = 2_048,
        passphrase: String = "",
        language _: MnemonicLanguageType = .english
    ) -> [UInt8]? {
        guard self.validate(mnemonic: mnemonic),
            let normalizedData = self.normalized(string: mnemonic),
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
    public static func validate(mnemonic: String) -> Bool {
        let normalizedMnemonic = mnemonic.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let mnemonicComponents = normalizedMnemonic.components(separatedBy: " ")
        guard !mnemonicComponents.isEmpty else {
            return false
        }

        // Use the first component of the mnemonic to determine the language, then make sure all
        // subsequent components are in that language.
        if String.englishMnemonics.contains(mnemonicComponents[0]) {
            for mnemonicComponent in mnemonicComponents {
                guard String.englishMnemonics.contains(mnemonicComponent) else {
                    return false
                }
            }
            return true
        } else if String.chineseMnemonics.contains(mnemonicComponents[0]) {
            for mnemonicComponent in mnemonicComponents {
                guard String.chineseMnemonics.contains(mnemonicComponent) else {
                    return false
                }
            }
            return true
        } else {
            return false
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
