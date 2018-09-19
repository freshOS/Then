Pod::Spec.new do |s|
  s.name             = 'thenPromise'
  s.version          = "4.2.0"
  s.summary          = "Elegant Promises for Swift"
  s.homepage         = "https://github.com/freshOS/then"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = 'S4cha'
  s.source           = { :git => "https://github.com/freshOS/then.git",
                           :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.social_media_url = 'https://twitter.com/sachadso'
  s.source_files     = "Source/*.swift"
  s.requires_arc     = true
  s.description  = "Elegant Async code for Swift 🎬- Async code finally readable by a human being"
  s.module_name = 'then'
end
