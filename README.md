# MUKDataSource

[![CI Status](http://img.shields.io/travis/muccy/MUKDataSource.svg?style=flat)](https://travis-ci.org/muccy/MUKDataSource)
[![Version](https://img.shields.io/cocoapods/v/MUKDataSource.svg?style=flat)](http://cocoadocs.org/docsets/MUKDataSource)
[![License](https://img.shields.io/cocoapods/l/MUKDataSource.svg?style=flat)](http://cocoadocs.org/docsets/MUKDataSource)
[![Platform](https://img.shields.io/cocoapods/p/MUKDataSource.svg?style=flat)](http://cocoadocs.org/docsets/MUKDataSource)

`MUKDataSource` is class designed to provide data (it's not too surprising, I think). It gives a structure to provide immutable data to your views. When you change data you get update to apply.

`MUKDataSource` is ready to back a `UITableView`, `UICollectionView` or `UIPageViewController` instance out of the box but it is designed to hold any kind of data for every kind of usage.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS 7 SDK.
* Minimum deployment target: iOS 7.

## Installation

`MUKDataSource` is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "MUKDataSource"
	
## Example

Say you want to download and show a list of flowers in you table view.

You can download data how you want but [MUKContentFetch](https://github.com/muccy/MUKContentFetch) is a good candidate. Once you have data you set sections and you get an update to apply to your table view. Applying an update means to insert, delete, reload, move sections and items with pretty animations.

```objective-c
// FlowersFetch contains download+parse logic
MUKContentFetchRequest *request = [[MUKContentFetchRequest alloc] init];
MUKContentFetch *fetch = [[FlowersFetch alloc] initWithRequest:request];
[fetch startWithCompletionHandler:^(MUKContentFetchResponse *response) {
	if (response.resultType == MUKContentFetchResultTypeSuccess) {
		MUKDataSourceContentSection *section = [[MUKDataSourceContentSection alloc] initWithIdentifier:@"flowers" items:response.object header:@"Flowers" footer:nil];
		MUKDataSourceTableUpdate *update = [self.dataSource setTableSections:@[section]];
		[update applyToTableView:self.tableView withAnimation:[MUKDataSourceTableUpdateAnimation automaticAnimation]];
	}
	else if (response.resultType == MUKContentFetchResultTypeFailed) {
		MUKDataSourceContentPlaceholder *placeholder = [[MUKDataSourceContentPlaceholder alloc] initWithTitle:@"Error" subtitle:[response.error localizedDescription] image:nil];
		self.dataSource.content = placeholder;
	}
}];
```

Data source to show items in table view is trivial because you only need to provide cells.

```objective-c
@interface FlowersDataSource : MUKDataSource
@end

@implementation FlowersDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *const kCellIdentifier = @"FlowerCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
	}
	
	Flower *flower = [self itemAtIndexPath:indexPath];
	cell.textLabel.text = flower.name;
	
	return cell;
}

@end
```
If you subclass `MUKTableViewController` you only need to set data source which automatically attached to table view.

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

## Author

Marco Muccinelli, muccymac@gmail.com

## License

`MUKDataSource` is available under the MIT license. See the LICENSE file for more info.
