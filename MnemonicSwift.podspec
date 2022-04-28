 Pod::Spec.new do |s|
  s.name         = "MnemonicSwift"
  s.version      = "2.2.4"
  s.summary      = "A Swift implementation of BIP39 Mnemonics"
  s.description  = <<-DESC
  MnemonicSwift provides a Swift implementation of BIP39 using CriptoKit

  This library is originally forked from MnemonicSwift: https://github.com/keefertaylor/MnemonicSwift
                   DESC

  s.homepage     = "https://github.com/zcash-hackworks/MnemonicSwift"
  s.license      = { :type => "dual", :file => "COPYING.md" }
  s.author       = { "Francisco Gindre" => "francisco.gindre@gmail.com" }
  s.source       = { :git => "https://github.com/zcash-hackworks/MnemonicSwift.git", :tag => s.version }
  s.source_files  = "MnemonicSwift/**/*.swift",
  s.swift_version = "5.3"
  s.ios.deployment_target = "13.0"
  s.osx.deployment_target = "10.15"

  s.framework = "CryptoKit"
  s.test_spec "Tests" do |test_spec|
    test_spec.source_files = "Tests/*.swift"
    test_spec.resources = ["Tests/*.json"]
  end
end
