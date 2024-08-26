#
#  Be sure to run `pod spec lint GXSegmentPageView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name          = "GXSegmentPageView"
  s.version       = "1.1.1"
  s.swift_version = "5.0"
  s.summary       = "Swift版分段分页组件，（网易新闻、腾讯新闻、新浪微博、今日头条等Tab效果）"
  s.homepage      = "https://github.com/gsyhei/GXSegmentPageView"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "Gin" => "279694479@qq.com" }
  s.platform      = :ios, "12.0"
  s.source        = { :git => "https://github.com/gsyhei/GXSegmentPageView.git", :tag => "1.1.1" }
  s.requires_arc  = true
  s.source_files  = "GXSegmentPageView"
 #s.resources     = 'GXSegmentPageView/Resource/**/*'
  s.frameworks    = "UIKit"

end
