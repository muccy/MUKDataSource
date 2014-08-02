#import <MUKDataSource/MUKDataSource_Main.h>

@interface MUKDataSource (TableView) <UITableViewDataSource>
// Conversions
- (NSInteger)childDataSourceIndexFromTableViewSection:(NSInteger)section checkingBounds:(BOOL)checkBounds;
- (NSInteger)itemIndexFromTableViewRow:(NSInteger)row checkingBounds:(BOOL)checkBounds;
- (NSIndexPath *)itemIndexPathFromTableViewIndexPath:(NSIndexPath *)tableIndexPath checkingBounds:(BOOL)checkBounds;

- (NSIndexPath *)tableViewIndexPathFromItemIndex:(NSInteger)itemIndex checkingBounds:(BOOL)checkBounds;
- (NSArray *)tableViewIndexPathsFromItemIndexes:(NSArray *)itemIndexes checkingBounds:(BOOL)checkBounds;

// How many rows this data source represents?
// section is informative
- (NSInteger)numberOfRowsForSection:(NSInteger)section inTableView:(UITableView *)tableView;

- (void)registerReusableViewsForTableView:(UITableView *)tableView;
- (UITableViewCell *)dequeueOrCreateCellForRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView;
- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView;

- (NSString *)titleForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView;
- (NSString *)titleForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView;

- (BOOL)canEditRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView;
- (BOOL)canMoveRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView;
@end
