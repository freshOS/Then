Pod::Spec.new do |s|
  s.name             = 'thenPromise'
  s.version          = "1.2.1"
  s.summary          = "Elegant Async code for Swift"
  s.homepage         = "https://github.com/s4cha/then"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = 'S4cha'
  s.platform         = :ios
  s.source           = { :git => "https://github.com/s4cha/then.git",
                         :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/sachadso'
  s.source_files     = "Source/*.swift"
  s.requires_arc     = true
  s.ios.deployment_target = "8.0"
  s.description  = "Elegant Async code for Swift 🎬- Async code finally readable by a human being"
end
