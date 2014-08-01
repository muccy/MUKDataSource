#import <UIKit/UIKit.h>

@interface MUKDataSource : NSObject <UITableViewDataSource>
@property (nonatomic, copy) NSString *title;
@end

@interface MUKDataSource (Contents)
@property (nonatomic, copy) NSArray *items;
- (id)itemAtIndex:(NSInteger)idx;
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface MUKDataSource (Containment)
@property (nonatomic, readonly) NSArray *childDataSources;
@property (nonatomic, weak, readonly) MUKDataSource *parentDataSource;
- (void)addChildDataSource:(MUKDataSource *)dataSource;
- (void)removeDataSource:(MUKDataSource *)dataSource;
@end

@interface MUKDataSource (TableView)
- (void)registerReusableViewsForTableView:(UITableView *)tableView;
- (UITableViewCell *)dequeueOrCreateCellForRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;
- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;
@end
