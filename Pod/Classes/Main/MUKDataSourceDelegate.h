#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceEventOrigin.h>
#import <MUKDataSource/MUKDataSourceContentLoadingResultType.h>

@class MUKDataSource, MUKDataSourceContentLoading;
/**
 Data source delegate palys an important role: it is delegated to reflect data
 source events and contents inside a presentation layer.
 */
@protocol MUKDataSourceDelegate <NSObject>
@optional
/**
 Child data sources have been inserted into graph.
 @param dataSource Data source which has sent this message to its delegate.
 @param indexes Inserted child data sources indexes.
 @param targetDataSource Data source which received the event.
 @param eventOrigin If the event has been fired programmatically or by user
 interaction.
 */
- (void)dataSource:(MUKDataSource *)dataSource didInsertChildDataSourcesAtIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)targetDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
/**
 Child data sources have been removed from graph.
 @param dataSource Data source which has sent this message to its delegate.
 @param childDataSources Removed child data sources.
 @param indexes Removed child data source indexes.
 @param originatingDataSource Data source which received the event.
 @param eventOrigin If the event has been fired programmatically or by user
 interaction.
 */
- (void)dataSource:(MUKDataSource *)dataSource didRemoveChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)originatingDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
/**
 Child data sources have been replaced inside graph.
 @param dataSource Data source which has sent this message to its delegate.
 @param childDataSource Child data sources that are no more inside graph.
 @param indexes Replaced child data source indexes.
 @param originatingDataSource Data source which received the event.
 */
- (void)dataSource:(MUKDataSource *)dataSource didReplaceChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)originatingDataSource;
/**
 Child data source has been moved inside graph.
 @param dataSource Data source which has sent this message to its delegate.
 @param sourceDataSource The data source which has lost the child data source.
 @param sourceIndex Moved child data source index inside sourceDataSource.
 @param destinationDataSource The data which has acquired the child data source.
 Note that it could be equal to sourceDataSource.
 @param destinationIndex Moved child data source new index inside
 destinationDataSource.
 @param eventOrigin If the event has been fired programmatically or by user
 interaction.
 */
- (void)dataSource:(MUKDataSource *)dataSource didMoveChildDataSourceFromDataSource:(MUKDataSource *)sourceDataSource atIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
/**
 Entire child data source content has been refreshed inside graph.
 This happens when you invoked setItems:animated: without animation: callback is
 invoked relatively to parentDataSource.
 @param dataSource Data source which has sent this message to its delegate.
 @param index Refreshed child data source index.
 @param originatingDataSource Data source which received the event.
 */
- (void)dataSource:(MUKDataSource *)dataSource didRefreshChildDataSourceAtIndex:(NSInteger)idx inDataSource:(MUKDataSource *)originatingDataSource;
/**
 Items have been inserted into graph.
 @param dataSource Data source which has sent this message to its delegate.
 @param indexes Inserted items indexes.
 @param targetDataSource Data source which received the event.
 @param eventOrigin If the event has been fired programmatically or by user
 interaction.
 */
- (void)dataSource:(MUKDataSource *)dataSource didInsertItemsAtIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)targetDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
/**
 Items have been removed from graph.
 @param dataSource Data source which has sent this message to its delegate.
 @param items Removed items.
 @param indexes Removed items indexes.
 @param originatingDataSource Data source which received the event.
 @param eventOrigin If the event has been fired programmatically or by user
 interaction.
 */
- (void)dataSource:(MUKDataSource *)dataSource didRemoveItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)originatingDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
/**
 Items have been replaced inside graph.
 @param dataSource Data source which has sent this message to its delegate.
 @param items Items that are no more inside graph.
 @param indexes Replaced items indexes.
 @param originatingDataSource Data source which received the event.
 */
- (void)dataSource:(MUKDataSource *)dataSource didReplaceItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)originatingDataSource;
/**
 Item has been moved inside graph.
 @param dataSource Data source which has sent this message to its delegate.
 @param sourceDataSource The data source which has lost the item.
 @param sourceIndex Moved item index inside sourceDataSource.
 @param destinationDataSource The data which has acquired the item. Note that it
 could be equal to sourceDataSource.
 @param destinationIndex Moved item new index inside destinationDataSource.
 @param eventOrigin If the event has been fired programmatically or by user
 interaction.
 */
- (void)dataSource:(MUKDataSource *)dataSource didMoveItemFromDataSource:(MUKDataSource *)sourceDataSource atIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
/**
 Child data sources have been refreshed inside graph.
 This happens when you invoked setChildDataSources:animated: without animation.
 @param dataSource Data source which has sent this message to its delegate.
 @param originatingDataSource Data source which received the event.
 */
- (void)dataSource:(MUKDataSource *)dataSource didReloadDataInDataSource:(MUKDataSource *)originatingDataSource;
/**
 Batch update has been requested inside graph.
 @param dataSource Data source which has sent this message to its delegate.
 @param updateBlock The block which should be invoked (typically from delegate)
 to perform the batch update.
 @param originatingDataSource Data source which received the event.
 */
- (void)dataSource:(MUKDataSource *)dataSource didRequestBatchUpdate:(dispatch_block_t)updateBlock fromDataSource:(MUKDataSource *)originatingDataSource;
/**
 Data source is transitioning to new content loading state.
 @param dataSource Data source which has sent this message to its delegate.
 @param state New state.
 @param originatingDataSource Data source which received the event.
 */
- (void)dataSource:(MUKDataSource *)dataSource willTransitionToContentLoadingState:(NSString *)state inDataSource:(MUKDataSource *)originatingDataSource;
/**
 Data source has transitioned to new content loading state.
 @param dataSource Data source which has sent this message to its delegate.
 @param state Old state.
 @param originatingDataSource Data source which received the event.
 */
- (void)dataSource:(MUKDataSource *)dataSource didTransitionFromContentLoadingState:(NSString *)state inDataSource:(MUKDataSource *)originatingDataSource;
/**
 Data source is about to execute content loading job.
 You can inspect contentLoading object to discover which data source has generated
 this event.
 @param dataSource Data source which has sent this message to its delegate.
 @param contentLoading The content loading that is starting.
 */
- (void)dataSource:(MUKDataSource *)dataSource willLoadContent:(MUKDataSourceContentLoading *)contentLoading;
/**
 Data source has finished content loading. At the time this
 method is invoked, loadingState has been already updated.
 You can inspect contentLoading object to discover which data source has generated
 this event.
 @param dataSource Data source which has sent this message to its delegate.
 @param contentLoading The content loading that has finished.
 */
- (void)dataSource:(MUKDataSource *)dataSource didLoadContent:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error;
@end
