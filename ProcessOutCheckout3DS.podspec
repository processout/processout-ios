Pod::Spec.new do |s|
  s.name                  = 'ProcessOutCheckout3DS'
  s.version               = '4.7.0'
  s.swift_versions        = ['5.9']
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage              = 'https://github.com/processout/processout-ios'
  s.author                = 'ProcessOut'
  s.summary               = 'Integration with Checkout.com 3D Secure (3DS) mobile SDK.'
  s.source                = { :git => 'https://github.com/processout/processout-ios.git', :tag => s.version.to_s }
  s.frameworks            = 'Foundation'
  s.requires_arc          = true
  s.ios.deployment_target = '12.0'
  s.source_files          = 'Sources/ProcessOutCheckout3DS/**/*.swift'
  s.dependency            'ProcessOut', s.version.to_s
  s.dependency            'Checkout3DS', '3.2.1'
end
