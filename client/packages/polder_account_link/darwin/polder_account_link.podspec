Pod::Spec.new do |s|
  s.name             = 'polder_account_link'
  s.version          = '0.1.0'
  s.summary          = 'One Polder sign-in shared by every Polder app on a device.'
  s.description      = 'Stores the Polder account in a keychain group (iOS) or app group (macOS) shared by the Polder apps.'
  s.homepage         = 'https://github.com/DonutWare/Polder'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'DonutWare' => 'https://github.com/DonutWare' }
  s.source           = { :path => '.' }
  s.source_files     = 'polder_account_link/Sources/polder_account_link/**/*'
  s.ios.dependency 'Flutter'
  s.osx.dependency 'FlutterMacOS'
  s.ios.deployment_target = '15.0'
  s.osx.deployment_target = '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
