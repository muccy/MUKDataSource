#import <MUKDataSource/MUKDataSource_Main.h>

@interface MUKDataSource (TableView_Conversions)
// Table -> Items
- (NSInteger)childDataSourceIndexFromTableViewSection:(NSInteger)section checkingBounds:(BOOL)checkBounds;
- (NSInteger)itemIndexFromTableViewRow:(NSInteger)row checkingBounds:(BOOL)checkBounds;
- (NSIndexPath *)itemIndexPathFromTableViewIndexPath:(NSIndexPath *)tableIndexPath checkingBounds:(BOOL)checkBounds;

// Items -> Table
- (NSInteger)tableViewSectionFromChildDataSourceIndex:(NSInteger)childDataSourceIndex checkingBounds:(BOOL)checkBounds;
- (NSIndexSet *)tableViewSectionsFromChildDataSourceIndexes:(NSIndexSet *)childDataSourceIndexes checkingBounds:(BOOL)checkBounds;
- (NSInteger)tableViewRowFromItemIndex:(NSInteger)itemIndex checkingBounds:(BOOL)checkBounds;
- (NSIndexPath *)tableViewIndexPathFromItemIndexPath:(NSIndexPath *)itemIndexPath checkingBounds:(BOOL)checkBounds;

// Uses implicit parent data source index for section
- (NSIndexPath *)tableViewIndexPathFromItemIndex:(NSInteger)itemIndex checkingBounds:(BOOL)checkBounds;
- (NSArray *)tableViewIndexPathsFromItemIndexes:(NSIndexSet *)itemIndexes checkingBounds:(BOOL)checkBounds;
@end

@interface MUKDataSource (TableView) <UITableViewDataSource>
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

- (id)newItemToInsertByCommittingRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView;
- (NSInteger)destinationIndexForItem:(id)item toInsertByCommittingRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView;
@end
