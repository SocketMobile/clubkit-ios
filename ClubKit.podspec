#
# Be sure to run `pod lib lint ClubKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ClubKit'
  s.version          = '0.1.18'
  s.summary          = 'A framework for managing membership'
  s.swift_versions    = ['4.0', '5.0']

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Combines the SKTCapture framework with an API for managing users. Users are represented by Apple mobile passes and RFID cards
                       DESC

  s.homepage         = 'http://www.socketmobile.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { "Socket" => "developers@socketmobile.com" }
  s.source           = { :git => 'https://github.com/SocketMobile/clubkit-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  # Minimum target of 9.3 is required for 'SKTCapture'
  s.ios.deployment_target = '9.3'
  s.platform = :ios, "9.3"

  s.source_files = 'Classes/*.{h,m,swift}'
  
  # s.resource_bundles = {
  #   'ClubKit' => ['ClubKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SKTCapture', '~>1.2'
  s.dependency 'RealmSwift', '~>4.4'
end
