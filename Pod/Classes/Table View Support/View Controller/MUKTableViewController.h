#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKDataSource.h>

/**
 A table view controller configured to host a data source and to respond to its
 messages properly.
 */
@interface MUKTableViewController : UITableViewController <MUKDataSourceDelegate>
/**
 The data source backing table view.
 When you set this property it automatically becomes table view data source,
 it sets dataSource delegate to self and it tries to register reusable views.
 */
@property (nonatomic) MUKDataSource *dataSource;
/**
 Tells if refresh control should be added/removed.
 Default: YES.
 When you use refresh control and data source gets to loading/refreshing state
 progress is shown automatically.
 */
@property (nonatomic) BOOL usesRefreshControl;
/**
 Tells if setNeedsLoadContent should be called on dataSouce at first viewWillAppear: 
 invocation.
 Default: YES.
 */
@property (nonatomic) BOOL automaticallySetNeedsLoadContentAtViewWillAppear;
@end
