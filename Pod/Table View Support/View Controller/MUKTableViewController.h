#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKDataSource.h>
#import <MUKDataSource/MUKDataSourceContentPlaceholder.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Simple table view controller which holds a data source
 */
@interface MUKTableViewController<__covariant ItemType> : UITableViewController
/**
 @brief         Data source
 @discussion    When you assign a data source it is also assigned to 
                self.tableView.dataSource. It also calls 
                registerReusableViewsForTableView: on it.
 */
@property (nonatomic, nullable) __kindof MUKDataSource<ItemType> *dataSource;
@end

@interface MUKTableViewController (ContentPlaceholder)
/**
 @param placeholder Placeholder set as data source content
 @returns View to display when a placeholder is set. You can return nil not to
 show a view. By default it returns a MUKDataSourceContentPlaceholderView instance.
 */
- (nullable __kindof UIView *)viewForContentPlaceholder:(__kindof MUKDataSourceContentPlaceholder *)placeholder;
@end

NS_ASSUME_NONNULL_END
