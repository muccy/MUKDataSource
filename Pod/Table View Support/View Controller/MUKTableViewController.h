#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKDataSource.h>

/**
 Simple table view controller which holds a data source
 */
@interface MUKTableViewController : UITableViewController
/**
 @brief         Data source
 @discussion    When you assign a data source it is also assigned to 
                self.tableView.dataSource. It also calls 
                registerReusableViewsForTableView: on it.
 */
@property (nonatomic, nullable) MUKDataSource *dataSource;
@end
