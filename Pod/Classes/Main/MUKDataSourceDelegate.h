#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceEventOrigin.h>
#import <MUKDataSource/MUKDataSourceContentLoadingResultType.h>

@class MUKDataSource, MUKDataSourceContentLoading;
@protocol MUKDataSourceDelegate <NSObject>
@optional
- (void)dataSource:(MUKDataSource *)dataSource didInsertChildDataSourcesAtIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)targetDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)dataSource:(MUKDataSource *)dataSource didRemoveChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)originatingDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)dataSource:(MUKDataSource *)dataSource didReplaceChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)originatingDataSource;
- (void)dataSource:(MUKDataSource *)dataSource didMoveChildDataSourceFromDataSource:(MUKDataSource *)sourceDataSource atIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)dataSource:(MUKDataSource *)dataSource didRefreshChildDataSourceAtIndex:(NSInteger)idx inDataSource:(MUKDataSource *)originatingDataSource;

- (void)dataSource:(MUKDataSource *)dataSource didInsertItemsAtIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)targetDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)dataSource:(MUKDataSource *)dataSource didRemoveItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)originatingDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)dataSource:(MUKDataSource *)dataSource didReplaceItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)originatingDataSource;
- (void)dataSource:(MUKDataSource *)dataSource didMoveItemFromDataSource:(MUKDataSource *)sourceDataSource atIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)dataSource:(MUKDataSource *)dataSource didReloadDataInDataSource:(MUKDataSource *)originatingDataSource;

- (void)dataSource:(MUKDataSource *)dataSource didRequestBatchUpdate:(dispatch_block_t)updateBlock fromDataSource:(MUKDataSource *)originatingDataSource;

- (void)dataSource:(MUKDataSource *)dataSource willTransitionToContentLoadingState:(NSString *)state inDataSource:(MUKDataSource *)originatingDataSource;
- (void)dataSource:(MUKDataSource *)dataSource didTransitionFromContentLoadingState:(NSString *)state inDataSource:(MUKDataSource *)originatingDataSource;

- (void)dataSource:(MUKDataSource *)dataSource willLoadContent:(MUKDataSourceContentLoading *)contentLoading;
- (void)dataSource:(MUKDataSource *)dataSource didLoadContent:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error;
@end
