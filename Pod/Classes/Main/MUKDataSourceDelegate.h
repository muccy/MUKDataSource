#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceEventOrigin.h>

@class MUKDataSource;
@protocol MUKDataSourceDelegate <NSObject>
@optional
- (void)dataSource:(MUKDataSource *)dataSource didMoveItemFromDataSource:(MUKDataSource *)sourceDataSource atIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)dataSource:(MUKDataSource *)dataSource didRemoveItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)originatingDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)dataSource:(MUKDataSource *)dataSource didInsertItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)targetDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)dataSource:(MUKDataSource *)dataSource didReplaceItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes withItems:(NSArray *)newItems inDataSource:(MUKDataSource *)originatingDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;

- (void)dataSource:(MUKDataSource *)dataSource didRequestBatchUpdate:(dispatch_block_t)updateBlock fromDataSource:(MUKDataSource *)originatingDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
@end
