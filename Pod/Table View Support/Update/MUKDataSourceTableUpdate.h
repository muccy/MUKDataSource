#import <MUKDataSource/MUKDataSourceSectionedContentUpdate.h>
#import <MUKDataSource/MUKDataSourceTableUpdateAnimation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 How table should be updated to reflect the transition from source sections
 to destination sections.
 @note This subclass uses destination indexes due the nature of 
 applyToTableView:withAnimation: both in
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
                moves table components. Then it attempts various reloads. This is
                necessary because table views don't like to mix movements and 
                reloads.
 @param tableView   Table view instance to affect with update
 @param animation   Animation to apply to table view. If you pass nil, table view
                    data will be reloaded with -reloadData.
 */
- (void)applyToTableView:(UITableView *)tableView withAnimation:(MUKDataSourceTableUpdateAnimation *__nullable)animation;
/**
 Reload sections in a table view.
 You may want to override this method when default behavior to call
 table view's reloadSections:withRowAnimation: is not proper for you.
 @param tableView   Table view instance to affect with update
 @param indexes     Indexes to reload
 @param animation   Animation to apply
 */
- (void)reloadTableView:(UITableView *)tableView sectionsAtIndexes:(NSIndexSet *)indexes withRowAnimation:(UITableViewRowAnimation)animation;
/**
 Reload rows in a table view.
 You may want to override this method when default behavior to call
 table view's reloadRowsAtIndexPaths:withRowAnimation: is not proper for you.
 @param tableView   Table view instance to affect with update
 @param indexPaths  Index paths to reload
 @param animation   Animation to apply
 */
- (void)reloadTableView:(UITableView *)tableView rowsAtIndexPaths:(NSSet *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
@end

NS_ASSUME_NONNULL_END
