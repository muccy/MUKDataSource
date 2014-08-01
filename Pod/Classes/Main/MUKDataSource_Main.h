#import <UIKit/UIKit.h>

@interface MUKDataSource : NSObject <UITableViewDataSource>
@property (nonatomic, copy) NSString *title;
@end

@interface MUKDataSource (Contents)
@property (nonatomic, copy) NSArray *items;
- (id)itemAtIndex:(NSInteger)idx;
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

- (void)moveItemAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex;
@end

@interface MUKDataSource (Containment)
@property (nonatomic, readonly) NSArray *childDataSources;
@property (nonatomic, weak, readonly) MUKDataSource *parentDataSource;
- (void)addChildDataSource:(MUKDataSource *)dataSource;
- (void)removeDataSource:(MUKDataSource *)dataSource;
@end

@interface MUKDataSource (ChildCallbacks)
- (void)childDataSource:(MUKDataSource *)sourceDataSource didMoveItemAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex;
@end

@interface MUKDataSource (TableView)
- (NSInteger)numberOfRowsForTableView:(UITableView *)tableView inSection:(NSInteger)section;

- (void)registerReusableViewsForTableView:(UITableView *)tableView;
- (UITableViewCell *)dequeueOrCreateCellForRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;

- (NSString *)titleForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView;
- (NSString *)titleForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView;

- (BOOL)canEditRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;
- (BOOL)canMoveRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView;


@end
