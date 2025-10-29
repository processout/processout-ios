Pod::Spec.new do |s|
  s.name                  = 'ProcessOutCore'
  s.version               = '4.34.0'
  s.swift_versions        = ['5.10']
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage              = 'https://github.com/processout/processout-ios'
  s.author                = 'ProcessOut'
  s.summary               = 'Core components. Pod is meant to be used only with other ProcessOut pods.'
  s.source                = { :git => 'https://github.com/processout/processout-ios.git', :tag => s.version.to_s }
  s.frameworks            = 'Foundation', 'UIKit'
  s.ios.deployment_target = '15.0'
  s.ios.resources         = 'Sources/ProcessOut/Resources/**/*'
  s.source_files          = 'Sources/ProcessOut/**/*.swift'
  s.pod_target_xcconfig   = { 'OTHER_SWIFT_FLAGS' => '-package-name ProcessOut' }
end
