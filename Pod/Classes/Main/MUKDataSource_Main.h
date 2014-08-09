#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKDataSourceDelegate.h>
#import <MUKDataSource/MUKDataSourceContentLoading.h>
#import <MUKDataSource/MUKDataSourceContentLoadState.h>

@interface MUKDataSource : NSObject
@property (nonatomic, weak) id<MUKDataSourceDelegate> delegate;
@property (nonatomic, copy) NSString *title;

- (void)requestBatchUpdate:(dispatch_block_t)updateBlock;
@end

@interface MUKDataSource (Contents)
// KVC compliant for mutable changes via -mutableArrayValueForKey:
@property (nonatomic, copy) NSArray *items;
- (void)setItems:(NSArray *)items animated:(BOOL)animated;

- (id)itemAtIndex:(NSInteger)idx;
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

- (NSUInteger)childDataSourcesItemCount;

- (void)insertItem:(id)item atIndex:(NSInteger)idx;
- (void)removeItemAtIndex:(NSInteger)idx;
- (void)replaceItemAtIndex:(NSInteger)idx withItem:(id)newItem;
- (void)moveItemAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex;
@end

@interface MUKDataSource (Containment)
@property (nonatomic, weak, readonly) MUKDataSource *parentDataSource;

// KVC compliant for mutable changes via -mutableArrayValueForKey:
@property (nonatomic, copy) NSArray *childDataSources;
- (void)setChildDataSources:(NSArray *)childDataSources animated:(BOOL)animated;

- (MUKDataSource *)childDataSourceAtIndex:(NSInteger)idx;
- (MUKDataSource *)childDataSourceAtIndexPath:(NSIndexPath *)indexPath;

- (void)appendChildDataSource:(MUKDataSource *)dataSource;
- (void)insertChildDataSource:(MUKDataSource *)dataSource atIndex:(NSInteger)idx;
- (void)removeChildDataSource:(MUKDataSource *)dataSource;
- (void)removeChildDataSourceAtIndex:(NSInteger)idx;
- (void)replaceChildDataSourceAtIndex:(NSInteger)idx withDataSource:(MUKDataSource *)newDataSource;
- (void)moveChildDataSourceAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex;
@end

@interface MUKDataSource (ContentLoading)
@property (nonatomic, readonly) NSString *loadingState;
- (BOOL)canTransitionToLoadingState:(NSString *)loadingState;

- (void)setNeedsLoadContent;
- (void)setNeedsAppendContent;

- (MUKDataSourceContentLoading *)newContentLoadingForState:(NSString *)state;
@end

@interface MUKDataSource (Callbacks)
- (void)didInsertChildDataSourcesAtIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)didRemoveChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)didReplaceChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)dataSource;
- (void)didMoveChildDataSourceFromDataSource:(MUKDataSource *)sourceDataSource atIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)didRefreshChildDataSourcesAtIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)dataSource;

- (void)didInsertItemsAtIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)didRemoveItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)didReplaceItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)dataSource;
- (void)didMoveItemFromDataSource:(MUKDataSource *)sourceDataSource atIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;

- (void)didReloadDataInDataSource:(MUKDataSource *)dataSource;
- (void)didRequestBatchUpdate:(dispatch_block_t)updateBlock fromDataSource:(MUKDataSource *)dataSource;

- (void)willTransitionToContentLoadingState:(NSString *)state inDataSource:(MUKDataSource *)dataSource;
- (void)didTransitionFromContentLoadingState:(NSString *)state inDataSource:(MUKDataSource *)dataSource;

- (void)willLoadContent:(MUKDataSourceContentLoading *)contentLoading;
- (void)didLoadContent:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error;
@end
