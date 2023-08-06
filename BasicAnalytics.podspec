Pod::Spec.new do |s|
  s.name             = 'BasicAnalytics'
  s.version          = '1.0.0'
  s.summary          = 'BasicAnalytics is an SDK for analytics events tracking.'
  s.homepage         = 'https://github.com/EgorGaydamak/BasicAnalytics'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'EgorGaydamak' => 'https://github.com/EgorGaydamak' }
  s.source           = { :git => 'https://github.com/EgorGaydamak/BasicAnalytics.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/BasicAnalytics/**/*'
end
