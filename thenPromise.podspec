Pod::Spec.new do |s|
  s.name             = 'thenPromise'
  s.version          = "1.4.2"
  s.summary          = "Elegant Promises for Swift"
  s.homepage         = "https://github.com/freshOS/then"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = 'S4cha'
  s.platform         = :ios
  s.source           = { :git => "https://github.com/freshOS/then.git",
                         :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/sachadso'
  s.source_files     = "Source/*.swift"
  s.requires_arc     = true
  s.ios.deployment_target = "8.0"
  s.description  = "Elegant Async code for Swift 🎬- Async code finally readable by a human being"
  s.module_name = 'then'
end
