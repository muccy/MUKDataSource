Pod::Spec.new do |s|
  s.name             = "MUKDataSource"
  s.version          = "1.1.0"
  s.summary          = "A central point to store, organize and load data on iOS. Ready to be your UITableView data source."
  s.description      = <<-DESC
                        A class designed to provide data (it's not too surprising, I think). It has been hugely inspired by [Apple WWDC 2014 Session 232](https://developer.apple.com/videos/wwdc/2014/?id=232), Advanced User Interfaces with Collection Views.

                        Each data source can contain items, which are model object to be displayed. What is more it can have child data sources, in order to create a hierarchy.

                        Every data source manage items and child data sources, notifying changes to parent data source and delegate objects.

                        Loading, refreshing, appending and displaying of content is backed by a [state machine](https://github.com/blakewatters/TransitionKit) and it is completely agnostic (you can load data with Cocoa APIs, [AFNetworking](https://github.com/AFNetworking/AFNetworking) or what you prefer).

                        MUKDataSource is ready to back a UITableView instance: just assign a MUKDataSource instance to tableView.dataSource and observe changes to apply. Otherwise you could use MUKTableViewController, which is a ready to use UITableViewController subclass.
                       DESC
  s.homepage         = "https://github.com/muccy/MUKDataSource"
  s.license          = 'MIT'
  s.author           = { "Marco Muccinelli" => "muccymac@gmail.com" }
  s.source           = { :git => "https://github.com/muccy/MUKDataSource.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes', 'Pod/Classes/**/*.{h,m}'
  s.private_header_files = 'Pod/Classes/Private/*.h'
  s.compiler_flags  = '-Wdocumentation'
  
  s.dependency 'TransitionKit', '~> 2.1'
end
