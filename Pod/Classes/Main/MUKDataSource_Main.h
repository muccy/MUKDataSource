#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKDataSourceDelegate.h>
#import <MUKDataSource/MUKDataSourceContentLoading.h>
#import <MUKDataSource/MUKDataSourceContentLoadState.h>
#import <MUKDataSource/MUKDataSourceSnapshot.h>

/**
 Data source is an object which — not surprisingly — provides data.
 Each data source can contain items, which are model object to be displayed.
 What is more it can have child data sources, in order to create a hierarchy.
 Every data source manage items and child data sources, notifying changes to
 parent data source and delegate objects.
 Loading, refreshing, appending and displaying of content is backed by a state
 machine and it is completely agnostic (you can load data with Cocoa APIs, 
 AFNetworking or what you prefer).
 MUKDataSource conforms NSSecureCoding but you should not archive an instance
 directly: you are strongly encouraged to use snapshotting API.
 
 MUKDataSource is ready to back a UITableView instance. Just assign a
 MUKDataSource instance to tableView.dataSource and observe changes to apply.
 */
@interface MUKDataSource : NSObject <NSSecureCoding>
/**
 The object which acts as delegate.
 */
@property (nonatomic, weak) id<MUKDataSourceDelegate> delegate;
/**
 The title of data source.
*/
@property (nonatomic, copy) NSString *title;
/**
 Request a complex update.
 @param updateBlock The block which contains the complex update.
 */
- (void)requestBatchUpdate:(dispatch_block_t)updateBlock;
/**
 Compare two data sources.
 I can't compare items and child data source because I may want parallel
 data sources.
 
 @param dataSource The data source to compare.
 @return YES if dataSource is identic to self.
 */
- (BOOL)isEqualToDataSource:(MUKDataSource *)dataSource;
@end

@interface MUKDataSource (Contents)
/**
 The items.
 This property is KVC compliant for mutable changes via mutableArrayValueForKey:.
 Assigning items via this property is equivalent to call setItems:animated: 
 without animation.
 */
@property (nonatomic, copy) NSArray *items;
/**
 Copy items to self.items.
 If you request animation this method calculates a delta between items and 
 it requests a proper batch update.
 @param items New items.
 @param animated If YES you would like to animate insertions, deletions and moves.
 */
- (void)setItems:(NSArray *)items animated:(BOOL)animated;
/**
 Get an item.
 @param idx Index of requested item.
 @return The item or nil if idx is out of bounds.
 */
- (id)itemAtIndex:(NSInteger)idx;
/**
 Get an item traversing child data sources.
 @param indexPath Index path to reach desired item. If you have an index path 
 containing n indexes, first n-1 indexes are child data source indexes and last
 one is item index in last traversed child data source.
 @return The item or nil if indexPath is out of bounds.
 */
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
/**
 Insert an item.
 @param item The item to insert. If it is nil nothing happens.
 @param idx The index where item should be inserted. Becareful to pass a valid
 index not to raise an exception.
 */
- (void)insertItem:(id)item atIndex:(NSInteger)idx;
/**
 Remove an item.
 @param idx The index of item to be removed. Becareful to pass a valid index
 not to raise an exception.
 */
- (void)removeItemAtIndex:(NSInteger)idx;
/**
 Replace an item with another one.
 @param idx The index of existing item. Becareful to pass a valid index not to
 raise an exception.
 @param newItem The item that should be inserted. If it is nil nothing happens.
 */
- (void)replaceItemAtIndex:(NSInteger)idx withItem:(id)newItem;
/**
 Move an item.
 @param sourceIndex The index of item to be moved. Becareful to pass a valid
 index not to raise an exception.
 @param destinationDataSource Data source where item should be moved. You can
 pass the source data source in order to move the item inside the same collection
 of items. If it is nil nothing happens.
 @param destinationIndex The index where item should be moved. Becareful to pass
 a valid index not to raise an exception.
 */
- (void)moveItemAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex;
@end

@interface MUKDataSource (Containment)
/**
 Parent data source.
 This reference is automatically assigned when you add the data source as child.
 */
@property (nonatomic, weak, readonly) MUKDataSource *parentDataSource;
/**
 The child data sources.
 This property is KVC compliant for mutable changes via mutableArrayValueForKey:.
 Assigning items via this property is equivalent to call 
 setChildDataSources:animated: without animation.
 */
@property (nonatomic, copy) NSArray *childDataSources;
/**
 Copy child data sources to self.childDataSource.
 If you request animation this method calculates a delta between child data 
 sources and it requests a proper batch update.
 Note that, despite child date sources are stored inside an array, duplicates
 are not allowed.
 @param childDataSources New child data source.
 @param animated If YES you would like to animate insertions, deletions and moves.
 */
- (void)setChildDataSources:(NSArray *)childDataSources animated:(BOOL)animated;
/**
 Get a child data source.
 @param idx Index of requested child data source.
 @return The child data source or nil if idx is out of bounds.
 */
- (MUKDataSource *)childDataSourceAtIndex:(NSInteger)idx;
/**
 Get a child data source traversing child data sources.
 @param indexPath Index path to reach desired child data source.
 @return The child data source or nil if indexPath is out of bounds.
 */
- (MUKDataSource *)childDataSourceAtIndexPath:(NSIndexPath *)indexPath;
/**
 Append child data source.
 @param dataSource The data source to insert. If it is nil nothing happens.
 */
- (void)appendChildDataSource:(MUKDataSource *)dataSource;
/**
 Insert child data source.
 @param dataSource The data source to insert. If it is nil nothing happens.
 @param idx The index where dataSource should be inserted. Becareful to pass a
 valid index not to raise an exception.
 */
- (void)insertChildDataSource:(MUKDataSource *)dataSource atIndex:(NSInteger)idx;
/**
 Remove a child data source by object.
 @param dataSource The data source which will be removed. If it is nil nothing 
 happens.
 */
- (void)removeChildDataSource:(MUKDataSource *)dataSource;
/**
 Remove a child data source by index.
 @param idx The index of child data source to be removed. Becareful to pass a
 valid index not to raise an exception.
 */
- (void)removeChildDataSourceAtIndex:(NSInteger)idx;
/**
 Replace a child data source with another one.
 @param idx The index of existing child data source. Becareful to pass a valid 
 index not to raise an exception.
 @param newDataSource The child data source that should be inserted. If it is nil 
 nothing happens.
 */
- (void)replaceChildDataSourceAtIndex:(NSInteger)idx withDataSource:(MUKDataSource *)newDataSource;
/**
 Move a child data source.
 @param sourceIndex The index of child data source to be moved. Becareful to pass
 a valid index not to raise an exception.
 @param destinationDataSource Data source where child data source should be 
 moved. You can pass the source data source in order to move the item inside the 
 same collection of child data sources. If it is nil nothing happens.
 @param destinationIndex The index where child data source should be moved. 
 Becareful to pass a valid index not to raise an exception.
 */
- (void)moveChildDataSourceAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex;
@end

@interface MUKDataSource (ContentLoading)
/**
 Current content loading state.
 States are:
 * MUKDataSourceContentLoadStateInitial, the initial state.
 * MUKDataSourceContentLoadStateLoading, the first load.
 * MUKDataSourceContentLoadStateRefreshing, the reloads subsequent the first.
 * MUKDataSourceContentLoadStateAppending, the addition of content to existing.
 * MUKDataSourceContentLoadStateLoaded, when content is loaded and displayable.
 * MUKDataSourceContentLoadStateEmpty, when no content is available for display.
 * MUKDataSourceContentLoadStateError, when error blocks content display.
 */
@property (nonatomic, readonly) NSString *loadingState;
/**
 Current content loading.
 When a content loading is in progress this object is not nil.
 */
@property (nonatomic, readonly) MUKDataSourceContentLoading *currentContentLoading;
/**
 Tell data source new content should be loaded.
 MUKDataSourceContentLoadStateLoading or MUKDataSourceContentLoadStateLoading
 target states are chosen automatically.
 */
- (void)setNeedsLoadContent;
/**
 Tell data source new content should be appended.
 */
- (void)setNeedsAppendContent;
/**
 Create content loading transitioning to state.
 You should override this method (it returns nil by default).
 @param state The loading state which caused new content loading.
 @return New content loading ready to be executed.
 */
- (MUKDataSourceContentLoading *)newContentLoadingForState:(NSString *)state;
/**
 Tell data source contents are loaded without a content loading.
 It is useful when you have static data or you have an empty data source and
 you add data locally (e.g.: an empty todo list when you add new item).
 */
- (void)setNeedsDeclareLoaded;
/**
 Tell data source contents are empty without a content loading.
 It is useful when you have static data or you have a loaded data source and
 you remove data locally (e.g.: a todo list when you remove last item).
 */
- (void)setNeedsDeclareEmpty;
@end

@interface MUKDataSource (Callbacks)
/**
 Callback invoked when child data sources have been inserted into graph.
 By default it passes the message to parentDataSource and invokes delegate.
 @param indexes Inserted child data sources indexes.
 @param dataSource Data source which received the event.
 @param eventOrigin If the event has been fired programmatically or by user
 interaction.
 */
- (void)didInsertChildDataSourcesAtIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
/**
 Callback invoked when child data sources have been removed from graph.
 By default it passes the message to parentDataSource and invokes delegate.
 @param childDataSources Removed child data sources.
 @param indexes Removed child data source indexes.
 @param dataSource Data source which received the event.
 @param eventOrigin If the event has been fired programmatically or by user
 interaction.
 */
- (void)didRemoveChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
/**
 Callback invoked when child data sources have been replaced inside graph.
 By default it passes the message to parentDataSource and invokes delegate.
 @param childDataSources Child data sources that are no more inside graph.
 @param indexes Replaced child data source indexes.
 @param dataSource Data source which received the event.
 */
- (void)didReplaceChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)dataSource;
/**
 Callback invoked when child data source has been moved inside graph.
 By default it passes the message to parentDataSource and invokes delegate.
 @param sourceDataSource The data source which has lost the child data source.
 @param sourceIndex Moved child data source index inside sourceDataSource.
 @param destinationDataSource The data which has acquired the child data source.
 Note that it could be equal to sourceDataSource.
 @param destinationIndex Moved child data source new index inside
 destinationDataSource.
 @param eventOrigin If the event has been fired programmatically or by user
 interaction.
 */
- (void)didMoveChildDataSourceFromDataSource:(MUKDataSource *)sourceDataSource atIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
/**
 Callback invoked when entire child data source content has been refreshed
 inside graph.
 This happens when you invoked setItems:animated: without animation: callback is 
 invoked relatively to parentDataSource.
 By default it passes the message to parentDataSource and invokes delegate.
 @param idx Refreshed child data source index.
 @param dataSource Data source which received the event.
 */
- (void)didRefreshChildDataSourceAtIndex:(NSInteger)idx inDataSource:(MUKDataSource *)dataSource;
/**
 Callback invoked when items have been inserted into graph.
 By default it passes the message to parentDataSource and invokes delegate.
 @param indexes Inserted items indexes.
 @param dataSource Data source which received the event.
 @param eventOrigin If the event has been fired programmatically or by user
 interaction.
 */
- (void)didInsertItemsAtIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
/**
 Callback invoked when items have been removed from graph.
 By default it passes the message to parentDataSource and invokes delegate.
 @param items Removed items.
 @param indexes Removed items indexes.
 @param dataSource Data source which received the event.
 @param eventOrigin If the event has been fired programmatically or by user
 interaction.
 */
- (void)didRemoveItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
/**
 Callback invoked when items have been replaced inside graph.
 By default it passes the message to parentDataSource and invokes delegate.
 @param items Items that are no more inside graph.
 @param indexes Replaced items indexes.
 @param dataSource Data source which received the event.
 */
- (void)didReplaceItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)dataSource;
/**
 Callback invoked when item has been moved inside graph.
 By default it passes the message to parentDataSource and invokes delegate.
 @param sourceDataSource The data source which has lost the item.
 @param sourceIndex Moved item index inside sourceDataSource.
 @param destinationDataSource The data which has acquired the item. Note that it 
 could be equal to sourceDataSource.
 @param destinationIndex Moved item new index inside destinationDataSource.
 @param eventOrigin If the event has been fired programmatically or by user
 interaction.
 */
- (void)didMoveItemFromDataSource:(MUKDataSource *)sourceDataSource atIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
/**
 Callback invoked when child data sources have been refreshed inside graph.
 This happens when you invoked setChildDataSources:animated: without animation.
 By default it passes the message to parentDataSource and invokes delegate.
 @param dataSource Data source which received the event.
 */
- (void)didReloadDataInDataSource:(MUKDataSource *)dataSource;
/**
 Callback invoked when a batch update has been requested inside graph.
 By default it passes the message to parentDataSource and invokes delegate.
 @param updateBlock The block which should be invoked (typically from delegate)
 to perform the batch update.
 @param dataSource Data source which received the event.
 */
- (void)didRequestBatchUpdate:(dispatch_block_t)updateBlock fromDataSource:(MUKDataSource *)dataSource;
/**
 Callback invoked when data source is transitioning to new content loading state.
 By default it passes the message to parentDataSource and invokes delegate.
 @param state New state.
 @param dataSource Data source which received the event.
 */
- (void)willTransitionToContentLoadingState:(NSString *)state inDataSource:(MUKDataSource *)dataSource;
/**
 Callback invoked when data source has transitioned to new content loading state.
 By default it passes the message to parentDataSource and invokes delegate.
 @param state Old state.
 @param dataSource Data source which received the event.
 */
- (void)didTransitionFromContentLoadingState:(NSString *)state inDataSource:(MUKDataSource *)dataSource;
/**
 Callback invoked when data source is about to execute content loading job.
 By default it passes the message to parentDataSource and invokes delegate.
 You can inspect contentLoading object to discover which data source has generated
 this event.
 @param contentLoading The content loading that is starting.
 */
- (void)willLoadContent:(MUKDataSourceContentLoading *)contentLoading;
/**
 Callback invoked when data source has finished content loading. At the time this
 method is invoked, loadingState has been already updated.
 By default it passes the message to parentDataSource and invokes delegate.
 You can inspect contentLoading object to discover which data source has generated
 this event.
 @param contentLoading The content loading that has finished.
 */
- (void)didLoadContent:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error;
@end

@interface MUKDataSource (Snaphotting)
/**
 Tells you if you should snapshot the data source.
 By default it checks data source is in a valid state (not loading, refreshing
 or appending). It checks also whether child data sources should be snapshotted. 
 You should always check this method before to call newSnapshot.
 @return YES if you should snapshot this data source.
 */
- (BOOL)shouldBeSnapshotted;
/**
 Creates new snapshot.
 Should always check shouldBeSnapshotted before to call this method.
 @return A new snapnot of this data source. Becareful that returned object 
 has a strong reference to self.
 */
- (MUKDataSourceSnapshot *)newSnapshot;
/**
 Tells you if snapshot is valid for restoration.
 By default it checks if data source is in a valid state (loading or refreshing).
 It also checks that snapshotted data source is in a valid state (not loading,
 refreshing or appending). 
 You should always check this method before to call restoreFromSnapshot:.
 @param snapshot Snapshot to check.
 @return YES if you can use snapshot to restore this data source.
 */
- (BOOL)shouldBeRestoredFromSnapshot:(MUKDataSourceSnapshot *)snapshot;
/**
 Restores contents with snapshot.
 By default it sets title, items and childDataSources with the ones contained 
 inside snapshot.
 You should always check shouldBeRestoredFromSnapshot: before to call this method.
 @param snapshot The snaphot used for restoration.
 */
- (void)restoreFromSnapshot:(MUKDataSourceSnapshot *)snapshot;
@end
