require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "react-native-clickio-sdk"
  s.version      = package['version']
  s.summary      = "React Native bridge for Clickio Consent SDK"
  s.description  = package['description']
  s.homepage     = "https://clickio.com/"
  s.license      = package['license'] || "MIT"
  s.author       = { "Clickio" => "app-dev@clickio.com" }
  s.platforms    = { :ios => "12.0" }

  s.source       = { :git => 'https://github.com/ClickioTech/clickio_consent_sdk_react_native', :tag => s.version.to_s }

  s.source_files = "ios/**/*.{h,m,mm,swift}"
  s.requires_arc = true
  s.frameworks = 'UIKit', 'WebKit'

s.dependency "React-Codegen"
  s.dependency "ReactCommon"
  s.dependency "React-Core/DevSupport"
  s.dependency 'ClickioConsentSDKManager', '1.0.6'

  s.swift_version = "5.0"

 s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }

  s.resource_bundles = {
    'ClickioAssets' => ['ios/**/*.{xib,storyboard,xcassets,json}']
  }
end
