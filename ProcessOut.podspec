Pod::Spec.new do |s|
  s.name                  = 'ProcessOut'
  s.version               = '4.19.0'
  s.swift_versions        = ['6.0']
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage              = 'https://github.com/processout/processout-ios'
  s.author                = 'ProcessOut'
  s.summary               = 'The smart router for payments. Smartly route each transaction to the relevant payment providers.'
  s.source                = { :git => 'https://github.com/processout/processout-ios.git', :tag => s.version.to_s }
  s.frameworks            = 'Foundation', 'UIKit'
  s.ios.deployment_target = '14.0'
  s.ios.resources         = 'Sources/ProcessOut/Resources/**/*'
  s.source_files          = 'Sources/ProcessOut/**/*.swift'
  s.pod_target_xcconfig   = { 'OTHER_SWIFT_FLAGS' => '-Xfrontend -module-interface-preserve-types-as-written' }
end
