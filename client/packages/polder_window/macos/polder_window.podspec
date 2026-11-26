Pod::Spec.new do |s|
  s.name             = 'polder_window'
  s.version          = '0.1.0'
  s.summary          = 'Window chrome shared by the Polder apps.'
  s.description      = 'Draws the Flutter content under a transparent macOS title bar.'
  s.homepage         = 'https://github.com/DonutWare/Polder'
  s.license          = { :type => 'Proprietary' }
  s.author           = { 'DonutWare' => 'https://github.com/DonutWare' }
  s.source           = { :path => '.' }
  s.source_files     = 'polder_window/Sources/polder_window/**/*'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
