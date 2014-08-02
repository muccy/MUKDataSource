#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKDataSourceDelegate.h>

@interface MUKDataSource : NSObject
@property (nonatomic, weak) id<MUKDataSourceDelegate> delegate;
@property (nonatomic, copy) NSString *title;
@end

@interface MUKDataSource (Contents)
@property (nonatomic, copy) NSArray *items;
- (id)itemAtIndex:(NSInteger)idx;
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)indexOfItem:(id)item;
- (NSIndexPath *)indexPathOfItem:(id)item;

- (void)moveItemAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex;
- (void)removeItemAtIndex:(NSInteger)idx;
- (void)insertItem:(id)item atIndex:(NSInteger)idx;
@end

@interface MUKDataSource (Containment)
@property (nonatomic, readonly) NSArray *childDataSources;
@property (nonatomic, weak, readonly) MUKDataSource *parentDataSource;
- (void)addChildDataSource:(MUKDataSource *)dataSource;
- (void)removeDataSource:(MUKDataSource *)dataSource;
@end

@interface MUKDataSource (Callbacks)
- (void)didMoveItemFromDataSource:(MUKDataSource *)sourceDataSource atIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)didRemoveItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)didInsertItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
@end
