#
# Be sure to run `pod lib lint ProcessOut.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ProcessOut'
  s.version          = '2.13.0'
  s.summary          = 'The smart router for payments. Smartly route each transaction to the relevant payment providers.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This pod allows you to generate card tokens from clear card information. 
This token can then be used and stored on your backend to charge customers.
                       DESC

  s.homepage         = 'https://github.com/processout/processout-ios'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jeremy Lejoux' => 'jeremy@processout.com' }
  s.source           = { :git => 'https://github.com/processout/processout-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/processout'

  s.ios.deployment_target = '9.0'

  s.source_files = 'ProcessOut/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ProcessOut' => ['ProcessOut/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
end
