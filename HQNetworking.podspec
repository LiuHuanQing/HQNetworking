#
#  Be sure to run `pod spec lint HQNetworking.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "HQNetworking"
  s.version      = "1.0.0"
  s.summary      = "网络层"
  s.description  = <<-DESC
  网络抽象层
                   DESC

  s.homepage     = "https://github.com/LiuHuanQing/HQNetworking"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "刘欢庆" => "liu-lhq@163.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/LiuHuanQing/HQNetworking.git", :tag => s.version.to_s }
  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
  s.frameworks = "AFNetworking", "YYModel"
  s.dependency 'YYModel', '~> 1.0.4'
  s.dependency 'AFNetworking/NSURLSession', '~> 3.1.0'
end
