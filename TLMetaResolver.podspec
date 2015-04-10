#
# Be sure to run `pod lib lint TLMetaResolver.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "TLMetaResolver"
  s.version          = "0.1.3"
  s.summary          = "TLMetaResolver is an extension to UIWebView that adds the ability to parse the meta tags in the loaded web page."
  s.homepage         = "https://github.com/tryolabs/TLMetaResolver"
  s.license          = 'MIT'
  s.author           = { "BrunoBerisso" => "bruno@tryolabs.com" }
  s.source           = { :git => "https://github.com/tryolabs/TLMetaResolver.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.ios.deployment_target = '8.0'

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'TLMetaResolver' => ['Pod/Assets/**/*']
  }
end
