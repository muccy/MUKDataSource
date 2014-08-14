#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKDataSource.h>

@interface MUKTableViewController : UITableViewController <MUKDataSourceDelegate>
@property (nonatomic) MUKDataSource *dataSource;
@property (nonatomic) BOOL usesRefreshControl;
@property (nonatomic) BOOL automaticallySetNeedsLoadContentAtViewWillAppear;
@end
