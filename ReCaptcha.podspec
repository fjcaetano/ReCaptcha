#
# Be sure to run `pod lib lint ReCaptcha.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ReCaptcha'
  s.version          = '0.1.0'
  s.summary          = 'ReCaptcha for iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Add Google invisible ReCaptcha to your app
                       DESC

  s.homepage         = 'https://github.com/fjcaetano/ReCaptcha'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fjcaetano' => 'flavio@vieiracaetano.com' }
  s.source           = { :git => 'https://github.com/fjcaetano/ReCaptcha.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/flavio_caetano'

  s.ios.deployment_target = '8.0'
  s.default_subspecs = 'Core'
  
# s.resource_bundles = {
#   'ReCaptcha' => ['ReCaptcha/Assets/*']
# }

  s.subspec 'Core' do |core|
    core.source_files = 'ReCaptcha/Classes/*'
    core.frameworks = 'WebKit'
    core.dependency 'Result', '~> 3.0'
  end

  s.subspec 'RxSwift' do |rx|
    rx.source_files = 'ReCaptcha/Classes/Rx/**/*'
    rx.dependency 'ReCaptcha/Core'
    rx.dependency 'RxSwift', '~> 3.0'
  end
end
