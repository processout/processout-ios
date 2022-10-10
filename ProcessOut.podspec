Pod::Spec.new do |s|
  s.name                  = 'ProcessOut'
  s.version               = '3.0.0'
  s.swift_versions        = ['5.7']
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage              = 'https://github.com/processout/ios-v2'
  s.author                = 'ProcessOut'
  s.summary               = 'The smart router for payments. Smartly route each transaction to the relevant payment providers.'
  s.source                = { :git => 'https://github.com/processout/ios-v2.git', :tag => s.version.to_s }
  s.frameworks            = 'Foundation'
  s.requires_arc          = true
  s.ios.deployment_target = '11.0'
  s.ios.resource_bundle   = { 'ProcessOut' => 'Sources/ProcessOut/Resources/**/*' }
  s.source_files          = 'Sources/ProcessOut/**/*.swift'
end
