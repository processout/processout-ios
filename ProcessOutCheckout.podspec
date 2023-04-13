Pod::Spec.new do |s|
  s.name                  = 'ProcessOutCheckout'
  s.version               = '3.2.0'
  s.swift_versions        = ['5.7']
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage              = 'https://github.com/processout/processout-ios'
  s.author                = 'ProcessOut'
  s.summary               = 'The smart router for payments. Smartly route each transaction to the relevant payment providers.'
  s.source                = { :git => 'https://github.com/processout/processout-ios.git', :tag => s.version.to_s }
  s.frameworks            = 'Foundation'
  s.requires_arc          = true
  s.ios.deployment_target = '12.0'
  s.source_files          = 'Sources/ProcessOutCheckout/**/*.swift'
  
  # todo(andrii-vysotskyi): remove before merge
  s.dependency 'ProcessOut'
  s.dependency 'JOSESwift', '2.2.1'
  s.dependency 'CheckoutEventLoggerKit', '1.2.3'
  s.vendored_frameworks = 'Sources/ProcessOutCheckout/Frameworks/Checkout3DS.xcframework'
end
