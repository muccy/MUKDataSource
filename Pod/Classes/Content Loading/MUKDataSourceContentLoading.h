#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceContentLoadingResultType.h>

@class MUKDataSource;
@interface MUKDataSourceContentLoading : NSObject
@property (nonatomic, copy, readonly) NSString *sourceState;
@property (nonatomic, weak, readonly) MUKDataSource *dataSource;
@property (nonatomic, readonly, getter = isCancelled) BOOL cancelled;
@property (nonatomic, copy) dispatch_block_t job;

- (void)cancel;
- (void)finishWithResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error update:(dispatch_block_t)updateHandler;

@end