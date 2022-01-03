//
//  PKCS5.swift
//
//
//  Created by Liu Pengpeng on 2019/10/10.
//  Modifed by Francisco Gindre on 2020/02/02

import CommonCrypto
import Foundation

public struct PKCS5 {
    public enum Error: Swift.Error {
        case invalidInput
    }

    public static func PBKDF2SHA512(password: [Int8], salt: [UInt8], iterations: Int = 2_048, keyLength: Int = 64) throws -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: keyLength)

        try bytes.withUnsafeMutableBytes { (outputBytes: UnsafeMutableRawBufferPointer) in
            let status = CCKeyDerivationPBKDF(
                CCPBKDFAlgorithm(kCCPBKDF2),
                password,
                password.count,
                salt,
                salt.count,
                CCPBKDFAlgorithm(kCCPRFHmacAlgSHA512),
                UInt32(iterations),
                outputBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                keyLength
            )
            guard status == kCCSuccess else {
                throw Error.invalidInput
            }
        }
        return bytes
    }
}
