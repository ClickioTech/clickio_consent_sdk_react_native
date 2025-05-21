require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "react-native-clickio-sdk"
  s.version      = package['version']
  s.summary      = "React Native bridge for Clickio Consent SDK"
  s.description  = package['description']
  s.homepage     = "https://example.com"
  s.license      = package['license'] || "MIT"
  s.author       = { "Anna" => "sargsian.ann@gmail.com" }
  s.platforms    = { :ios => "12.0" }

  s.source       = { :git => 'https://github.com/reactNDeveloper/react-native-clickio-sdk.git', :tag => s.version.to_s }

  s.source_files = "ios/**/*.{h,m,mm,swift}"
  s.requires_arc = true
  s.frameworks = 'UIKit', 'WebKit'

s.dependency "React-Codegen"
  s.dependency "ReactCommon"
  s.dependency "React-Core/DevSupport"
  s.dependency 'ClickioConsentSDKManager', '1.0.5-rc'

  s.swift_version = "5.0"

 s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }

  s.resource_bundles = {
    'ClickioAssets' => ['ios/**/*.{xib,storyboard,xcassets,json}']
  }
end
