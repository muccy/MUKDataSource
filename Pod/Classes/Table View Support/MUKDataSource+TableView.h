#import <MUKDataSource/MUKDataSource_Main.h>

@interface MUKDataSource (TableView_Conversions)
/**
 Converts table view section into child data source index.
 Each child data source represents a table view section.
 You should call this method on table view data source.
 @param section Table view section.
 @param checkBounds If YES returned index is validated against childDataSources array.
 @return Child data source index which represents table view section. It may 
 return NSNotFound if checkBounds is YES.
 */
- (NSInteger)childDataSourceIndexFromTableViewSection:(NSInteger)section checkingBounds:(BOOL)checkBounds;
/**
 Converts table view row into item index.
 Each item represents a table view row.
 You should call this method on section data source.
 @param row Table view row.
 @param checkBounds If YES returned index is validated against items array.
 @return Item index which represents table view row. It may return NSNotFound if 
 checkBounds is YES.
 */
- (NSInteger)itemIndexFromTableViewRow:(NSInteger)row checkingBounds:(BOOL)checkBounds;
/**
 Converts table view index path into item index path.
 Each item represents a table view row and each child data source represents a 
 table view section.
 You should call this method on table view data source.
 @param indexPath Table view index path.
 @param checkBounds If YES returned index path is validated against childDataSources
 and items arrays.
 @return Item index path which represents table view index path. It may return nil 
 if check bounds is YES.
 */
- (NSIndexPath *)itemIndexPathFromTableViewIndexPath:(NSIndexPath *)tableIndexPath checkingBounds:(BOOL)checkBounds;
/**
 Converts child data source index into table view section.
 Each child data source represents a table view section.
 You should call this method on table view data source.
 @param childDataSourceIndex Child data source index.
 @param checkBounds If YES returned index is validated against childDataSources array.
 @return Table view section represented by child data source index. It may
 return NSNotFound if checkBounds is YES.
 */
- (NSInteger)tableViewSectionFromChildDataSourceIndex:(NSInteger)childDataSourceIndex checkingBounds:(BOOL)checkBounds;
/**
 Converts child data source indexes into table view sections.
 Each child data source represents a table view section.
 You should call this method on table view data source.
 @param childDataSourceIndexes Child data source indexes.
 @param checkBounds If YES returned indexes are validated against childDataSources
 array.
 @return Table view sections represented by child data source indexs. It may
 return nil or an incomplete index set if checkBounds is YES.
 */
- (NSIndexSet *)tableViewSectionsFromChildDataSourceIndexes:(NSIndexSet *)childDataSourceIndexes checkingBounds:(BOOL)checkBounds;
/**
 Converts item index into table view row.
 Each item represents a table view row.
 You should call this method on section data source.
 @param itemIndex Item index.
 @param checkBounds If YES returned index is validated against items array.
 @return Table view row represented by item index. It may return NSNotFound if
 checkBounds is YES.
 */
- (NSInteger)tableViewRowFromItemIndex:(NSInteger)itemIndex checkingBounds:(BOOL)checkBounds;
/**
 Converts item index path into table view index path.
 Each item represents a table view row and each child data source represents a
 table view section.
 You should call this method on table view data source.
 @param itemIndexPath Item index path.
 @param checkBounds If YES returned index path is validated against childDataSources
 and items arrays.
 @return Table view index path represented by item index path. It may return nil if
 check bounds is YES.
 */
- (NSIndexPath *)tableViewIndexPathFromItemIndexPath:(NSIndexPath *)itemIndexPath checkingBounds:(BOOL)checkBounds;
/**
 Converts item index into table view index path using implicit parent data
 source index.
 Each item represents a table view row and each child data source represents a
 table view section.
 You should call this method on section data source.
 @param itemIndex Item index.
 @param checkBounds If YES returned index path is validated against childDataSources
 and items arrays.
 @return Table view index path represented by item index and and child data source
 index in parent data source. It may return NSNotFound if checkBounds is YES.
 */
- (NSIndexPath *)tableViewIndexPathFromItemIndex:(NSInteger)itemIndex checkingBounds:(BOOL)checkBounds;
/**
 Converts item indexes into table view index paths using implicit parent data
 source index.
 Each item represents a table view row and each child data source represents a
 table view section.
 You should call this method on section data source.
 @param itemIndexes Item indexes.
 @param checkBounds If YES returned index is validated against items array.
 @return Table view index paths represented by item indexes and and child data source
 index in parent data source. It may return NSNotFound if checkBounds is YES.
 */
- (NSArray *)tableViewIndexPathsFromItemIndexes:(NSIndexSet *)itemIndexes checkingBounds:(BOOL)checkBounds;
@end

/**
 It implements all UITableViewDataSource methods.
 */
@interface MUKDataSource (TableView) <UITableViewDataSource>
/**
 Tells how many rows this data source represents.
 @param section Table view section. This is purely informative.
 @param tableView The table view which is requesting data.
 @return Number of rows.
 */
- (NSInteger)numberOfRowsForSection:(NSInteger)section inTableView:(UITableView *)tableView;
/**
 Registers reusable views for a table view.
 @param tableView The table view which is registering reusable views.
 */
- (void)registerReusableViewsForTableView:(UITableView *)tableView;
/**
 Dequeues or create new cells.
 You must return a valid cell from here. Default returns nil.
 @param tableIndexPath Table view index path for cell.
 @param tableView The table view which is requesting data.
 @return Created cell.
 */
- (UITableViewCell *)dequeueOrCreateCellForRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView;
/**
 Configures already created or dequeued cells.
 @param cell The cell that should be configured.
 @param tableIndexPath Table view index path for cell.
 @param tableView The table view which is requesting data.
 */
- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView;
/**
 Tells the title for table view section header.
 By default it returns data source title.
 @param section Table view section. This is purely informative. You have to return
 a title for the header of section represented for this data source.
 @param tableView The table view which is requesting data.
 @return Header title.
 */
- (NSString *)titleForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView;
/**
 Tells the title for table view section footer.
 @param section Table view section. This is purely informative. You have to return
 a title for the footer of section represented for this data source.
 @param tableView The table view which is requesting data.
 @return Footer title.
 */
- (NSString *)titleForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView;
/**
 Tells if a table view row can be edited.
 By default it returns NO.
 @param tableIndexPath Table view index path.
 @param tableView The table view which is requesting data.
 @return YES if row can be edited.
 */
- (BOOL)canEditRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView;
/**
 Tells if a table view row can be moved.
 By default it returns NO.
 @param tableIndexPath Table view index path.
 @param tableView The table view which is requesting data.
 @return YES if row can be moved.
 */
- (BOOL)canMoveRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView;
/**
 New item to insert when UITableViewCellEditingStyleInsert is committed.
 By default it returns nil.
 @param tableIndexPath Committed row table view index path.
 @param tableView The table view which is requesting data.
 @return New item.
 */
- (id)newItemToInsertByCommittingRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView;
/**
 Where new item should be inserted when UITableViewCellEditingStyleInsert is
 committed.
 By default it tries to append item.
 @param item New item.
 @param tableIndexPath Committed row table view index path.
 @param tableView The table view which is requesting data.
 @return Insertion index.
 */
- (NSInteger)destinationIndexForItem:(id)item toInsertByCommittingRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView;
@end
