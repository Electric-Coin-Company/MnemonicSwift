// Copyright Keefer Taylor, 2018
// Copyright Electric Coin Company, 2020

import Foundation

public extension UInt8 {
    func mnemonicBits() -> [String] {
        let totalBitsCount = MemoryLayout<UInt8>.size * 8

        var bitsArray = [String](repeating: "0", count: totalBitsCount)

        for j in 0 ..< totalBitsCount {
            let bitVal: UInt8 = 1 << UInt8(totalBitsCount - 1 - j)
            let check = self & bitVal

            if check != 0 {
                bitsArray[j] = "1"
            }
        }
        return bitsArray
    }
}

public extension Data {
    func toBitArray() -> [String] {
        var toReturn = [String]()
        for num in [UInt8](self) {
            toReturn.append(contentsOf: num.mnemonicBits())
        }
        return toReturn
    }
}
public extension Array where Element == UInt8 {
    func toBitArray() -> [String] {
        var toReturn = [String]()
        for num in self {
            toReturn.append(contentsOf: num.mnemonicBits())
        }
        return toReturn
    }
}
