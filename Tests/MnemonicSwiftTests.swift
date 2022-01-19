// Copyright Keefer Taylor, 2018
// Copyright Electric Coin Company, 2020

@testable import MnemonicSwift
import XCTest

class MnemonicSwiftTests: XCTestCase {
    /// Indices in the input file.
    private let hexRepresentationIndex = 0
    private let mnenomicStringIndex = 1
    private let deterministicSeedStringIndex = 2

    /// Named arrays in the test file
    private let englishTestCases = "english"

    /// Passphrase
    private let passphrase = "TREZOR"

    /// Test that MnemonicSwift can generate mnemonic strings from hex representations.
    func testGenerateMnemonicFromHex() throws {
        guard let vectors = MnemonicSwiftTests.dictionaryFromTestInputFile(),
              let testCases = vectors[englishTestCases] as? [[String]] else {
                  XCTFail("Failed to parse input file.")
                  return
              }

        for testCase in testCases {
            let expectedMnemonicString = testCase[mnenomicStringIndex]
            let hexRepresentation = testCase[hexRepresentationIndex]
            let mnemonicString = try Mnemonic.mnemonicString(from: hexRepresentation)

            XCTAssertEqual(mnemonicString, expectedMnemonicString)
        }
    }

    /// Test that MnemonicSwift can generate deterministic seed strings strings without a passphrase.
    func testGenerateDeterministicSeedStringWithPassphrase() throws {
        guard let vectors = MnemonicSwiftTests.dictionaryFromTestInputFile(),
              let testCases = vectors[englishTestCases] as? [[String]] else {
                  XCTFail("Failed to parse input file.")
                  return
              }

        for testCase in testCases {
            let mnemonicString = testCase[mnenomicStringIndex]
            let expectedDeterministicSeedString = testCase[deterministicSeedStringIndex]

            XCTAssertNoThrow({
                let deterministicSeedString: String = try Mnemonic.deterministicSeedString(from: mnemonicString, passphrase: self.passphrase)
                XCTAssertEqual(deterministicSeedString, expectedDeterministicSeedString)
            })
        }
    }

    static func dictionaryFromTestInputFile() -> [String: Any]? {
#if SWIFT_PACKAGE
        guard let url = Bundle.module.url(forResource: "vectors", withExtension: "json") else {
            return nil
        }
#else
        guard let url = Bundle(for: MnemonicSwiftTests.self).url(forResource: "vectors", withExtension: "json") else {
            return nil
        }
#endif

        do {
            let data = try Data(contentsOf: url)
            let options: JSONSerialization.ReadingOptions = [.allowFragments, .mutableContainers, .mutableLeaves]
            guard let parsedDictionary =
                    try JSONSerialization.jsonObject(with: data, options: options) as? [String: Any] else {
                        return nil
                    }
            return parsedDictionary
        } catch {
            return nil
        }
    }

    /// Test mnemonic generation in english.
    func testGenerateMnemonic() {

        XCTAssertNoThrow(try Mnemonic.generateMnemonic(strength: 32))
    }

    /// Prove that functions work in chinese as well.
    func testGenerateMnemonicChinese() {
        XCTAssertNoThrow(try Mnemonic.generateMnemonic(strength: 32, language: .chinese))
    }

    /// Test input strengths for mnemonic generation.
    func testMnemonicGenerationStrength() {

        XCTAssertNoThrow(try {
            XCTAssertEqual(try Mnemonic.generateMnemonic(strength: 32).components(separatedBy: " ").count, 3)
        }())

        XCTAssertNoThrow(try {
            XCTAssertEqual(try Mnemonic.generateMnemonic(strength: 64).components(separatedBy: " ").count, 6)
        }())

        XCTAssertNoThrow(try {
            XCTAssertEqual(try Mnemonic.generateMnemonic(strength: 128).components(separatedBy: " ").count, 12)
        }())

        XCTAssertNoThrow(try {
            XCTAssertEqual(try Mnemonic.generateMnemonic(strength: 160).components(separatedBy: " ").count, 15)
        }())

        XCTAssertNoThrow(try {
            XCTAssertEqual(try Mnemonic.generateMnemonic(strength: 192).components(separatedBy: " ").count, 18)
        }())

        XCTAssertNoThrow(try {
            XCTAssertEqual(try Mnemonic.generateMnemonic(strength: 224).components(separatedBy: " ").count, 21)
        }())

        XCTAssertNoThrow(try {
            XCTAssertEqual(try Mnemonic.generateMnemonic(strength: 256).components(separatedBy: " ").count, 24)
        }())
    }

    /// Test valid chinese and english mnemonics are determined to be Invalid.
    func testInValidEnglishAndChineseMnemonics() {
        let englishMnemonic =
        "pear peasant pelican pen pear peasant pelican pen pear peasant pelican pen pear peasant pelican pen"
        let chineseMnemonic = "式 扬 它 锦 亦 桥 晋 尼 登 串 焦 五 溶 寿 沿 能 妹 少 旅 冬 乳 承"

        XCTAssertThrowsError(try Mnemonic.validate(mnemonic: englishMnemonic))
        XCTAssertThrowsError(try Mnemonic.validate(mnemonic: chineseMnemonic))
    }

    /// Test invalid chinese and english mnemonics are determined to be invalid.
    func testInvalidEnglishAndChineseMnemonics() {
        let englishMnemonic = "slacktivist snacktivity snuggie"
        let chineseMnemonic = "亂 語"

        XCTAssertThrowsError(try Mnemonic.validate(mnemonic: englishMnemonic))
        XCTAssertThrowsError(try Mnemonic.validate(mnemonic: chineseMnemonic))
    }

    /// Test the empty string is determined to be an invalid mnemonic.
    func testEmptyStringValidation() {
        XCTAssertThrowsError(try Mnemonic.validate(mnemonic: ""))
    }

    /// Test that strings in an unknown language are determined to be invalid.
    func testUnknownLanguageValidation() {
        let spanishMnemonic =
        "pera campesina pelican pen pera campesina pelican pen pera campesina pelican pen pera campesina pelican pen"
        XCTAssertThrowsError(try Mnemonic.validate(mnemonic: spanishMnemonic))
    }

    /// Test that strings of mixed case are determined to be invalid.
    func testMixedCaseValidation() {
        let mixedCaseMnemonic = "pear PEASANT PeLiCaN pen"
        XCTAssertThrowsError(try Mnemonic.validate(mnemonic: mixedCaseMnemonic))
    }

    /// Test mixed language mnemonics.
    func testMixedLanguageMnemonicValidation() {
        let mixedLanguageMnemonic = "pear peasant pelican pen 路 级 少 图"
        XCTAssertThrowsError(try Mnemonic.validate(mnemonic: mixedLanguageMnemonic))
    }

    /// Test that strings padded with whitespace are determined to be valid.
    func testWhitespacePaddedValidation() {
        let whitespacePaddedMnemonic = "    flash tobacco obey genius army stove desk anchor quarter reflect chalk caution\t\t\n"
        XCTAssertThrowsError(try Mnemonic.validate(mnemonic: whitespacePaddedMnemonic))

        XCTAssertNoThrow(try Mnemonic.deterministicSeedString(from: whitespacePaddedMnemonic))
    }

    /// Test an valid mnemonic generates a seed string.
    func testDeterministicSeedStringVisuallyValidButYetInvalidMnemonic() {
        let invalidMnemonic =
        "pear peasant pelican pen pear peasant pelican pen pear peasant pelican pen pear peasant pelican pen"
        XCTAssertThrowsError(try Mnemonic.deterministicSeedString(from: invalidMnemonic))
    }

    /// Test an invalid mnemonic does not generate a seed string.
    func testDeterministicSeedStringInvalidMnemonic() {
        let invalidMnemonic =
        "MnemonicSwift MnemonicSwift MnemonicSwift MnemonicSwift MnemonicSwift MnemonicSwift MnemonicSwift MnemonicSwift MnemonicSwift"
        XCTAssertThrowsError(try Mnemonic.deterministicSeedString(from: invalidMnemonic))
    }

    func testValidWordCountChinese() {
        let mnemonic12 = "针 环 焦 译 脏 密 嘴 土 殿 钠 燕 仰"
        XCTAssertNoThrow(try Mnemonic.validate(mnemonic: mnemonic12))
        let mnemonic15 = "李 凉 暗 均 粒 卖 再 送 绳 勃 窗 丙 洁 危 位"
        XCTAssertNoThrow(try Mnemonic.validate(mnemonic: mnemonic15))
        let mnemonic18 = "蚀 司 档 截 硫 空 激 狱 型 影 湖 钙 柱 控 拜 元 条 扶"
        XCTAssertNoThrow(try Mnemonic.validate(mnemonic: mnemonic18))
        let mnemonic21 = "遭 霉 费 龙 依 固 征 乔 束 锋 盐 芳 走 他 声 废 带 如 套 迹 代"
        XCTAssertNoThrow(try Mnemonic.validate(mnemonic: mnemonic21))
        let mnemonic24 = "式 扬 技 书 它 锦 亦 桥 晋 尼 登 串 焦 五 溶 寿 沿 能 妹 少 旅 冬 乳 承"
        XCTAssertNoThrow(try Mnemonic.validate(mnemonic: mnemonic24))
    }

    func testInvalidSmallWordCount() {
        let twoWordSeed = "flash tobacco"
        XCTAssertThrowsError(try Mnemonic.validate(mnemonic: twoWordSeed))
        let singleWordSeed = "flash"
        XCTAssertThrowsError(try Mnemonic.validate(mnemonic: singleWordSeed))
    }

    func testValidWordCount() {
        let twelveWordSeed = "flash tobacco obey genius army stove desk anchor quarter reflect chalk caution"
        let fifteenWordSeed = "figure manual hunt oil unusual outer flee yellow cable bottom uncle okay deputy witness fire"
        let eighteenWordSeed = "cost raccoon apple hill success sight bag harvest lawsuit exact snow police camp faith weather squirrel defy dry"
        let twentyOneWordSeed = "beach allow aim neglect phone boring horror venture door crouch ecology tent bulb oval culture hat half easily crucial horse heart"
        let twentyFourWordSeed = "vanish dream art asset response click orphan patch property owner lawsuit sweet smoke bicycle grunt sentence dish tribe review soap chief soft bone race"

        XCTAssertNoThrow(try Mnemonic.validate(mnemonic: twelveWordSeed), "error validating 12 word seed")
        XCTAssertNoThrow(try Mnemonic.validate(mnemonic: fifteenWordSeed), "error validating 15 word seed")
        XCTAssertNoThrow(try Mnemonic.validate(mnemonic: eighteenWordSeed), "error validating 18 word seed")
        XCTAssertNoThrow(try Mnemonic.validate(mnemonic: twentyOneWordSeed), "error validating 21 word seed")
        XCTAssertNoThrow(try Mnemonic.validate(mnemonic: twentyFourWordSeed), "error validating 24 word seed")
    }

    func testInvalidWordCount() {
        let elevenWordSeed = "flash tobacco obey genius army stove desk anchor quarter reflect chalk"
        let fourteenWordSeed = "figure manual hunt oil unusual outer flee yellow cable bottom uncle okay deputy witness"
        let seventeenWordSeed = "cost raccoon apple hill success sight bag harvest lawsuit exact snow police camp faith weather squirrel defy"
        let twentyWordSeed = "beach aim neglect phone boring horror venture door crouch ecology tent bulb oval culture hat half easily crucial horse heart"
        let twentythreeWordSeed = "vanish dream art  response click orphan patch property owner lawsuit sweet smoke bicycle grunt sentence dish tribe review soap chief soft bone race"

        XCTAssertThrowsError(try Mnemonic.validate(mnemonic: elevenWordSeed))
        XCTAssertThrowsError(try Mnemonic.validate(mnemonic: fourteenWordSeed))
        XCTAssertThrowsError(try Mnemonic.validate(mnemonic: seventeenWordSeed))
        XCTAssertThrowsError(try Mnemonic.validate(mnemonic: twentyWordSeed))
        XCTAssertThrowsError(try Mnemonic.validate(mnemonic: twentythreeWordSeed))
    }

    func testApparentlyValidSeedPhraseWithUppercaseCharacter() throws {
        let x = "human pulse approve subway climb stairs mind gentle raccoon warfare fog roast sponsor under absorb spirit hurdle animal original honey owner upper empower describe"
        let y = "Human pulse approve subway climb stairs mind gentle raccoon warfare fog roast sponsor under absorb spirit hurdle animal original honey owner upper empower describe"
        XCTAssertNoThrow(try Mnemonic.validate(mnemonic: x))
        XCTAssertThrowsError(try Mnemonic.validate(mnemonic: y))

        XCTAssertNoThrow(try Mnemonic.deterministicSeedBytes(from: x))
        XCTAssertThrowsError(try Mnemonic.deterministicSeedBytes(from: y))

        XCTAssertEqual(
            try Mnemonic.deterministicSeedBytes(from: x),
            try Mnemonic.deterministicSeedBytes(from: " " + x)
        )
        XCTAssertEqual(
            try Mnemonic.deterministicSeedBytes(from: x),
            try Mnemonic.deterministicSeedBytes(from: x + "\n")
        )
    }

    func testSwapTwoWords() {
        let phrase = "human pulse approve subway climb stairs mind gentle raccoon warfare fog roast sponsor under absorb spirit hurdle animal original honey owner upper empower describe"
        var x = phrase.components(separatedBy: " ")
        let i = Int.random(in: 1 ..< x.count)
        let j = Int.random(in: 0 ..< i)
        x.swapAt(i, j)

        let swappedPhrase = x.joined(separator: " ")

        XCTAssertNoThrow(try Mnemonic.deterministicSeedBytes(from: phrase))
        XCTAssertThrowsError(try Mnemonic.deterministicSeedBytes(from: swappedPhrase))

    }

    func testBitStringArrayToData() {
        let validBitString = "10000000" + "00010000" + "00001111" + "11110000"

        let uints: [UInt8] = [128, 16, 15, 240]
        let expectedDataArray = Data(uints)

        let result = validBitString.bitStringToBytes()

        XCTAssertNotNil(result)
        XCTAssertEqual(result, expectedDataArray)
    }

    func testBitStringArrayToDataFailsOnIncorrectString() {
        let bendersDream = "10000000" + "00010000" + "00020111" + "11110000"
        let result = bendersDream.bitStringToBytes()

        XCTAssertNil(result)
    }

    func testInvalidMnemonicData() {
        let validMnemonicData = "f1f1f1"

        let invalidMnemonicData = "f1f1f1f"

        let veryInvalidMnemonicData = "f1f1g1"
        let expectedData = Data([0xf1, 0xf1, 0xf1])

        XCTAssertEqual(validMnemonicData.mnemonicData(), expectedData)
        XCTAssertEqual(invalidMnemonicData.mnemonicData(), nil)
        XCTAssertEqual(veryInvalidMnemonicData.mnemonicData(), nil)
    }

    func testPad() {
        // it should pad to givesize when size is less that target size
        XCTAssertEqual("0".pad(toSize: 8), "00000000")
        XCTAssertEqual("1".pad(toSize: 8), "00000001")
        XCTAssertEqual("10".pad(toSize: 8), "00000010")
        XCTAssertEqual("10".pad(toSize: 8), "00000010")

        // it should not pad when size of the given string is same as target size
        XCTAssertEqual("00000010".pad(toSize: 8), "00000010")

        // it should n ot pad whe size of the given string is greater that target size
        XCTAssertEqual("100000010".pad(toSize: 8), "100000010")
    }

}
