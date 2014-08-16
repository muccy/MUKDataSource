# MUKDataSource

[![CI Status](http://img.shields.io/travis/muccy/MUKDataSource.svg?style=flat)](https://travis-ci.org/muccy/MUKDataSource)
[![Version](https://img.shields.io/cocoapods/v/MUKDataSource.svg?style=flat)](http://cocoadocs.org/docsets/MUKDataSource)
[![License](https://img.shields.io/cocoapods/l/MUKDataSource.svg?style=flat)](http://cocoadocs.org/docsets/MUKDataSource)
[![Platform](https://img.shields.io/cocoapods/p/MUKDataSource.svg?style=flat)](http://cocoadocs.org/docsets/MUKDataSource)

`MUKDataSource` is class designed to provide data (it's not too surprising, I think). It has been hugely inspired by [Apple WWDC 2014 Session 232](https://developer.apple.com/videos/wwdc/2014/?id=232), Advanced User Interfaces with Collection Views.
 
Each data source can contain items, which are model object to be displayed. What is more it can have child data sources, in order to create a hierarchy.

Every data source manage items and child data sources, notifying changes to parent data source and delegate objects.

Loading, refreshing, appending and displaying of content is backed by a [state machine](https://github.com/blakewatters/TransitionKit) and it is completely agnostic (you can load data with Cocoa APIs, [AFNetworking](https://github.com/AFNetworking/AFNetworking) or what you prefer).

`MUKDataSource` is ready to back a `UITableView` instance: just assign a `MUKDataSource` instance to `tableView.dataSource` and observe changes to apply. Otherwise you could use `MUKTableViewController`, which is a ready to use `UITableViewController` subclass.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS 7 SDK.
* Minimum deployment target: iOS 7.

## Installation

`MUKDataSource` is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "MUKDataSource"
	
## Walkthrough

With this walkthough I would like to guide you to fundamental features. Let's build a table of flowers!

### Structure

Basically we need two kind of data sources: a data source which manage table and a child data source which displays contents in a section.

```objective-c
@interface FlowersDataSource : MUKDataSource
@end

@implementation FlowersDataSource 

- (id)init {
	self = [super init];
	if (self) {
		self.childDataSources = @[ [[FlowersSectionDataSource alloc] init] ];
	}
	
	return self;
}

@end
```

```objective-c
@interface FlowersSectionDataSource : MUKDataSource
@end

@implementation FlowersSectionDataSource

- (UITableViewCell *)dequeueOrCreateCellForRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
	[super configureCell:cell forRowAtIndexPath:tableIndexPath inTableView:tableView];

    NSInteger itemIndex = [self itemIndexFromTableViewRow:tableIndexPath.row checkingBounds:YES];
    Flower *flower = [self itemAtIndex:itemIndex];

    cell.textLabel.text = flower.name;
    cell.detailTextLabel.text = flower.botanicalName;
}

@end
```

At this point we have a table with one empty section, ready to display flowers.

### Content Loading

Root data source should be ready to load contents.

```objective-c
- (MUKDataSourceContentLoading *)newContentLoadingForState:(NSString *)state {
    MUKDataSourceContentLoading *contentLoading = [[MUKDataSourceContentLoading alloc] init];
    __weak MUKDataSourceContentLoading *weakContentLoading = contentLoading;
    __weak FlowersDataSource *weakSelf = self;
 
    if ([state isEqualToString:MUKDataSourceContentLoadStateLoading] ||
		[state isEqualToString:MUKDataSourceContentLoadStateRefreshing])
	{
        contentLoading.job = ^{
            FlowersDataSource *strongSelf = weakSelf;
            MUKDataSourceContentLoading *strongContentLoading = weakContentLoading;
            			
            [Florist flowersFromIndex:0 count:20 completion:^(NSArray *flowers, NSError *error)
            {
                MUKDataSourceContentLoadingResultType resultType;
				if ([flowers count]) {
					resultType = MUKDataSourceContentLoadingResultTypeComplete;
				}
				else if (!error) {
					resultType = MUKDataSourceContentLoadingResultTypeEmpty;
				}
				else {
					resultType = MUKDataSourceContentLoadingResultTypeError;
				}
     
                [strongContentLoading finishWithResultType:resultType error:error update:^
                {
                    [strongSelf childDataSourceAtIndex:0].items = flowers;
                }];
            }];
        }; // job
    }
    else {
        contentLoading = nil;
    }
    
    return contentLoading;
}
```

Ok. Content loading logic is ready to be called whenever `-setNeedsLoadContent` is invoked.

### Attach to User Interface

The quickest way to get a table view is to subclass `MUKTableViewController`.

```objective-c
@interface FlowersTableViewController : MUKTableViewController
@end

@implementation FlowersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [[FlowersDataSource alloc] init];
}

@end
```

### More features?

Yes, of course. Read documentation and check example project for caching, restoration, appending and placeholder.
Remind `MUKDataSource` can be used with every kind of view or view controllers. Feel free to write code to extend built-in support to other views — like `UICollectionView` — or view controllers — like `UIPageViewController`.

## Author

Marco Muccinelli, muccymac@gmail.com

## License

`MUKDataSource` is available under the MIT license. See the LICENSE file for more info.
