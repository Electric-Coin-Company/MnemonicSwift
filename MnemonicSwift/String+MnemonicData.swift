// Copyright Keefer Taylor, 2018
// Copyright Electric Coin Company, 2020

import Foundation

extension String {
    func mnemonicData() -> Data? {
        guard self.count % 2 == 0 else { return nil }
        let length = self.count
        let dataLength = length / 2
        var dataToReturn = Data(capacity: dataLength)

        var outIndex = 0
        var outChars = ""
        for (_, char) in enumerated() {
            outChars += String(char)
            if outIndex % 2 == 1 {
                guard let i = UInt8(outChars, radix: 16) else { return nil }
                dataToReturn.append(i)
                outChars = ""
            }
            outIndex += 1
        }

        return dataToReturn
    }

    func pad(toSize: Int) -> String {
        guard self.count < toSize else { return self }
        var padded = self
        for _ in 0..<(toSize - self.count) {
            padded = "0" + padded
        }
        return padded
    }

    /// turns an array of "0"s and "1"s into bytes. fails if count is not modulus of 8
    func bitStringToBytes() -> Data? {
        let length = 8
        guard self.count % length == 0 else {
            return nil
        }
        var data = Data(capacity: self.count)

        for i in 0 ..< self.count / length {
            let startIdx = self.index(self.startIndex, offsetBy: i * length)
            let subArray = self[startIdx ..< self.index(startIdx, offsetBy: length)]
            let subString = String(subArray)
            guard let byte = UInt8(subString, radix: 2) else {
                return nil
            }
            data.append(byte)
        }
        return data
    }
}
