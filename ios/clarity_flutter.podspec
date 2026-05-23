Pod::Spec.new do |s|
  s.name             = 'clarity_flutter'
  s.version          = '1.0.0'
  s.summary          = 'Microsoft Clarity Flutter SDK native iOS support.'
  s.description      = 'Provides native platform channel implementations for the Clarity Flutter SDK.'
  s.homepage         = 'https://clarity.microsoft.com'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Microsoft - Clarity' => 'clarity-apps-support@microsoft.com' }
  s.source           = { :http => 'https://pub.dev/packages/clarity_flutter' }
  s.source_files     = 'clarity_flutter/Sources/clarity_flutter/**/*.swift'
  s.dependency       'Flutter'
  s.platform         = :ios, '12.0'
  s.swift_version    = '5.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.resource_bundles = { 'clarity_flutter_privacy' => ['clarity_flutter/Sources/clarity_flutter/PrivacyInfo.xcprivacy'] }
end
