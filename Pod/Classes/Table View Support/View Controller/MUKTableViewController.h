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

@interface MUKTableViewController (RowAnimation)
/**
 Row animation used to insert sections.
 @param sections Inserted sections.
 @param indexes Matching child data source indexes.
 @return Kind of animation. Default: UITableViewRowAnimationAutomatic.
 */
- (UITableViewRowAnimation)rowAnimationToInsertSections:(NSIndexSet *)sections forChildDataSourcesAtIndexes:(NSIndexSet *)indexes;
/**
 Row animation used to delete sections.
 @param sections Deleted sections.
 @param childDataSources Removed child data sources.
 @param indexes Matching child data source indexes.
 @return Kind of animation. Default: UITableViewRowAnimationAutomatic.
 */
- (UITableViewRowAnimation)rowAnimationToDeleteSections:(NSIndexSet *)sections forChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes;
/**
 Row animation used to reload sections when child data sources are replaced.
 @param sections Reloaded sections.
 @param childDataSources Removed child data sources.
 @param indexes Matching child data source indexes.
 @return Kind of animation. Default: UITableViewRowAnimationAutomatic.
 */
- (UITableViewRowAnimation)rowAnimationToReloadSections:(NSIndexSet *)sections toReplaceChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes;
/**
 Row animation used to reload section when contents are refreshed.
 @param section Reloaded section.
 @param idx Matching child data source index.
 @return Kind of animation. Default: UITableViewRowAnimationAutomatic.
 */
- (UITableViewRowAnimation)rowAnimationToReloadSection:(NSInteger)section toRefreshChildDataSourcesAtIndex:(NSInteger)idx;
/**
 Row animation used to insert rows.
 @param indexPaths Inserted rows index paths.
 @param indexes Matching item indexes.
 @param dataSource Originating data source.
 @return Kind of animation. Default: UITableViewRowAnimationAutomatic.
 */
- (UITableViewRowAnimation)rowAnimationToInsertRowsAtIndexPaths:(NSArray *)indexPaths forItemsAtIndexes:(NSIndexSet *)indexes inChildDataSource:(MUKDataSource *)dataSource;
/**
 Row animation used to delete rows.
 @param indexPaths Deleted rows index paths.
 @param items Deleted items.
 @param indexes Matching item indexes.
 @param dataSource Originating data source.
 @return Kind of animation. Default: UITableViewRowAnimationAutomatic.
 */
- (UITableViewRowAnimation)rowAnimationToDeleteRowsAtIndexPaths:(NSArray *)indexPaths forItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes inChildDataSource:(MUKDataSource *)dataSource;
/**
 Row animation used to reload rows.
 @param indexPaths Reloaded row index paths.
 @param items Replaced items.
 @param indexes Matching item indexes.
 @param dataSource Originating data source.
 @return Kind of animation. Default: UITableViewRowAnimationAutomatic.
 */
- (UITableViewRowAnimation)rowAnimationToReloadRowsAtIndexPaths:(NSArray *)indexPaths toReplaceItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)dataSource;
@end
