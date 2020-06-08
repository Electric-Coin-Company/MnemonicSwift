// Copyright Keefer Taylor, 2019
// Copyright Electric Coin Company, 2020
import MnemonicSwift

let strength = 128
if let mnemonic = Mnemonic.generateMnemonic(strength: strength) {
  print("A mnemonic of strength \(strength): \(mnemonic)")
}
