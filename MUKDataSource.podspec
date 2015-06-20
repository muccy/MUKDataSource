Pod::Spec.new do |s|
  s.name             = "MUKDataSource"
  s.version          = "2.0.0"
  s.summary          = "A central point to store, organize and load data on iOS. Ready to be your UITableView data source."
  s.description      = "A class designed to provide data."
  s.homepage         = "https://github.com/muccy/MUKDataSource"
  s.license          = 'MIT'
  s.author           = { "Marco Muccinelli" => "muccymac@gmail.com" }
  s.source           = { :git => "https://github.com/muccy/MUKDataSource.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/**/*.{h,m}'
  s.compiler_flags  = '-Wdocumentation'
  
  s.dependency  'KVOController', '~> 1.0.3'
  s.dependency  'MUKArrayDelta', '~> 1.1.2'
end
