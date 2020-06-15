 Pod::Spec.new do |s|
  s.name         = "MnemonicSwift"
  s.version      = "1.0.0"
  s.summary      = "A Swift implementation of BIP39 Mnemonics"
  s.description  = <<-DESC
  MnemonicSwift provides a Swift implementation of BIP39 using CriptoKit

  This library is originally forked from MnemonicKit: https://github.com/keefertaylor/MnemonicKit
                   DESC

  s.homepage     = "https://github.com/zcash-hackworks/MnemonicSwift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Francisco Gindre" => "francisco.gindre@gmail.com" }
  s.source       = { :git => "https://github.com/zcash-hackworks/MnemonicSwift.git", :tag => s.version }
  s.source_files  = "Sources/MnemonicSwift/**/*.swift",
  s.swift_version = "5.1"
  s.ios.deployment_target = "13.0"
  s.osx.deployment_target = "10.15"

  s.framework = "CryptoKit"
  s.test_spec "Tests" do |test_spec|
    test_spec.source_files = "Tests/MnemonicSwift/*.swift"
    test_spec.resources = ["Tests/MnemonicSwift/*.json"]
  end
end
