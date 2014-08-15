#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceContentLoadingResultType.h>

@class MUKDataSource;
/**
 An object which encapsulates a single content loading for data source.
 */
@interface MUKDataSourceContentLoading : NSObject
/**
 The loading state of data source when content loading is created.
 */
@property (nonatomic, copy, readonly) NSString *sourceState;
/**
 The data source which has requested content loading creation.
 */
@property (nonatomic, weak, readonly) MUKDataSource *dataSource;
/**
 YES if this content loading is still actual.
 You should test against this property to know if it's proper to abort early.
 */
@property (nonatomic, readonly, getter = isValid) BOOL valid;
/**
 A block which contains content loading logic.
 It is executed by data source.
 */
@property (nonatomic, copy) dispatch_block_t job;
/**
 Finishes content loading.
 You should call this method inside job block in order to finish and update data
 source.
 You can also call this method with MUKDataSourceContentLoadingResultTypeCancelled
 to cancel a content loading.
 @param resultType Tells data source how content loading has finished. This is used
 to know next loadingState.
 @param error Content loading completion error.
 @param updateHandler A block executed when state is transitioning to new loading
 state (before it is set). In this block you should setup new data source contents,
 like items and childDataSources.
 */
- (void)finishWithResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error update:(dispatch_block_t)updateHandler;
@end