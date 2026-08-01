Pod::Spec.new do |s|
  s.name             = 'device_inspector'
  s.version          = '0.1.0'
  s.summary          = 'Flutter device analysis SDK - iOS implementation'
  s.description      = <<-DESC
Provides device, system, hardware, performance, and security information
through a single MethodChannel-based Flutter plugin.
                       DESC
  s.homepage         = 'https://github.com/ykarateke/device_inspector'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Bear Code Studio' => 'info@bearcode.dev' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform         = :ios, '14.0'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'SWIFT_VERSION' => '5.9',
  }
end
