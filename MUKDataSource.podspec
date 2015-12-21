Pod::Spec.new do |s|
  s.name             = "MUKDataSource"
  s.version          = "2.5.6"
  s.summary          = "A structure to provide immutable data to your views. Ready to be your UITableView, UICollectionView, UIPageViewController data source."
  s.description      = <<-DESC
                        A class designed to provide data (it's not too surprising, I think). It gives a structure to provide immutable data to your views. When you change data you get update to apply. It is ready to back a `UITableView`, `UICollectionView` or a `UIPageViewController` instance out of the box but it is designed to hold any kind of data for every kind of usage.
                       DESC
  s.homepage         = "https://github.com/muccy/MUKDataSource"
  s.license          = 'MIT'
  s.author           = { "Marco Muccinelli" => "muccymac@gmail.com" }
  s.source           = { :git => "https://github.com/muccy/MUKDataSource.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/**/*.{h,m}'
  s.compiler_flags  = '-Wdocumentation'
  
  s.dependency  'KVOController', '~> 1.0.3'
  s.dependency  'MUKArrayDelta', '~> 1.2.0'
end
