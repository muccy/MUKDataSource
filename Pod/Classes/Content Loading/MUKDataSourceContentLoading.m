#import "MUKDataSourceContentLoading.h"
#import "MUKDataSourceContentLoading_Private.h"
#import "MUKDataSource_Private.h"

@interface MUKDataSourceContentLoading ()
@end

@implementation MUKDataSourceContentLoading

- (void)cancel {
    self.cancelled = YES;
}

- (void)finishWithResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error update:(dispatch_block_t)updateHandler
{
    [self.dataSource didFinishContentLoading:self withResultType:resultType error:error update:updateHandler];
}

@end
