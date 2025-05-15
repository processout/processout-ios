Pod::Spec.new do |s|
  s.name                  = 'ProcessOutNetcetera3DS'
  s.version               = '4.29.0'
  s.swift_versions        = ['5.10']
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage              = 'https://github.com/processout/processout-ios'
  s.author                = 'ProcessOut'
  s.summary               = 'Integration with Netcetera 3D Secure (3DS) mobile SDK.'
  s.source                = { :git => 'https://github.com/processout/processout-ios.git', :tag => s.version.to_s }
  s.frameworks            = 'Foundation'
  s.ios.deployment_target = '13.0'
  s.vendored_frameworks   = "Vendor/NetceteraShim.xcframework"
  s.ios.resources         = 'Sources/ProcessOutNetcetera3DS/Resources/**/*'
  s.source_files          = 'Sources/ProcessOutNetcetera3DS/**/*.swift'
  s.dependency            'ProcessOut', s.version.to_s
  s.dependency            'ThreeDS_SDK', '2.5.22'
end
