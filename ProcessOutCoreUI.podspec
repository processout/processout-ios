Pod::Spec.new do |s|
  s.name                  = 'ProcessOutCoreUI'
  s.version               = '4.24.1'
  s.swift_versions        = ['5.10']
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.homepage              = 'https://github.com/processout/processout-ios'
  s.author                = 'ProcessOut'
  s.summary               = 'Reusable UI components and logic. Pod is meant to be used only with other ProcessOut pods.'
  s.source                = { :git => 'https://github.com/processout/processout-ios.git', :tag => s.version.to_s }
  s.frameworks            = 'Foundation', 'SwiftUI'
  s.ios.deployment_target = '14.0'
  s.ios.resources         = 'Sources/ProcessOutCoreUI/Resources/**/*'
  s.source_files          = 'Sources/ProcessOutCoreUI/**/*.swift'
  s.dependency            'ProcessOut' # todo(andrii-vysotskyi): vendor cmark_gfm.xcframework instead after UI migration is completed
end
