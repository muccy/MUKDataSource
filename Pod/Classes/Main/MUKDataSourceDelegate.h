#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceEventOrigin.h>

@class MUKDataSource;
@protocol MUKDataSourceDelegate <NSObject>
@optional
- (void)dataSource:(MUKDataSource *)dataSource didMoveItemFromDataSource:(MUKDataSource *)sourceDataSource atIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)dataSource:(MUKDataSource *)dataSource didRemoveItems:(NSArray *)items atIndexes:(NSArray *)indexes fromDataSource:(MUKDataSource *)originatingDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
@end
