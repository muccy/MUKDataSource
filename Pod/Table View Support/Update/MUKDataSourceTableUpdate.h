#import <MUKDataSource/MUKDataSourceSectionedContentUpdate.h>

/**
 How table should be updated to reflect the transition from source sections
 to destination sections.
 This subclass adds detection for section reloads. It uses destination indexes
 due the nature of applyToTableView:animated: both in 
 reloadedSectionIndexForDelta:change: and 
 reloadedItemIndexPathForDelta:change:sectionMatch:
 */
@interface MUKDataSourceTableUpdate : MUKDataSourceSectionedContentUpdate
/**
 YES when only calling reloadData is a safe path to apply transition
 */
@property (nonatomic, readonly) BOOL needsReloadData;
/**
 @brief         Apply update to a table view
 @discussion    Update is applied in two steps. First it inserts, deletes and 
                moves table components. Then it attempt various reloads. This is
                necessary because table views don't like to mix movements and 
                reloads.
 @param tableView   Table view instance to affect with update
 @param animated    If YES transition will be animated
 */
- (void)applyToTableView:(UITableView *)tableView animated:(BOOL)animated;
/**
 Reload sections in a table view.
 You may want to override this method when default behavior to call
 table view's reloadSections:withRowAnimation: is not proper for you.
 @param tableView   Table view instance to affect with update
 @param indexes     Indexes to reload
 @param animated    If YES transition will be animated
 */
- (void)reloadTableView:(UITableView *)tableView sectionsAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated;
/**
 Reload rows in a table view.
 You may want to override this method when default behavior to call
 table view's reloadRowsAtIndexPaths:withRowAnimation: is not proper for you.
 @param tableView   Table view instance to affect with update
 @param indexPaths  Index paths to reload
 @param animated    If YES transition will be animated
 */
- (void)reloadTableView:(UITableView *)tableView rowsAtIndexPaths:(NSSet *)indexPaths animated:(BOOL)animated;
@end
