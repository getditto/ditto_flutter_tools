#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint ditto_flutter_tools.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'ditto_flutter_tools'
  s.version          = '1.0.0'
  s.summary          = 'Diagnostic and Debugging Tools for Ditto in Flutter'
  s.description      = <<-DESC
Diagnostic and Debugging Tools for Ditto in Flutter
                       DESC
  s.homepage         = 'https://ditto.live'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ditto' => 'support@ditto.live' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end