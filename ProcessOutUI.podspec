Pod::Spec.new do |s|
  s.name                  = 'ProcessOutUI'
  s.version               = '4.12.0'
  s.swift_versions        = ['5.9']
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage              = 'https://github.com/processout/processout-ios'
  s.author                = 'ProcessOut'
  s.summary               = 'ProcessOut prebuilt UI.'
  s.source                = { :git => 'https://github.com/processout/processout-ios.git', :tag => s.version.to_s }
  s.frameworks            = 'Foundation', 'SwiftUI'
  s.ios.deployment_target = '14.0'
  s.ios.resources         = 'Sources/ProcessOutUI/Resources/**/*'
  s.source_files          = 'Sources/ProcessOutUI/**/*.swift'
  s.pod_target_xcconfig   = { 'OTHER_SWIFT_FLAGS' => '-Xfrontend -module-interface-preserve-types-as-written' }
  s.dependency            'ProcessOut', s.version.to_s
  s.dependency            'ProcessOutCoreUI', s.version.to_s
end
