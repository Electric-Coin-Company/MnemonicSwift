 Pod::Spec.new do |s|
  s.name         = "MnemonicKit"
  s.version      = "2.0.0"
  s.summary      = "MnemonicKit provides a Swift implementation of BIP39"
  s.description  = <<-DESC
  MnemonicKit provides a Swift implementation of BIP39.

  This library is originally forked from CKMnemonic: https://github.com/CikeQiu/CKMnemonic. Modifications are made for non-throwing APIs and support on OSX as well as iOS. Credit for most of this work is given to work_cocody@hotmail.com, qiuhongyang@askcoin.org.
                   DESC

  s.homepage     = "https://github.com/keefertaylor/MnemonicKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Keefer Taylor" => "keefer@keefertaylor.com",
                           "Francisco Gindre" => "francisco.gindre@gmail.com" }
  s.source       = { :git => "https://github.com/keefertaylor/MnemonicKit.git", :tag => "1.3.10" }
  s.source_files  = "MnemonicKit/**/*.swift",
  s.swift_version = "5.1"
  s.ios.deployment_target = "13.0"
  s.osx.deployment_target = "10.15"

  s.framework = "CryptoKit"
  s.test_spec "Tests" do |test_spec|
    test_spec.source_files = "Tests/*.swift"
    test_spec.resources = ["Tests/*.json"]
  end
end
