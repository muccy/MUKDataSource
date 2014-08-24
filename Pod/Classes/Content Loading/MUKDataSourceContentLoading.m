#import "MUKDataSourceContentLoading.h"
#import "MUKDataSourceContentLoading_Private.h"
#import "MUKDataSource_Private.h"

@interface MUKDataSourceContentLoading ()
@end

@implementation MUKDataSourceContentLoading

- (id)init {
    self = [super init];
    if (self) {
        _valid = YES;
    }
    
    return self;
}

- (void)performJob {
    if (self.job) {
        self.job();
    }
}

- (void)finishWithResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error update:(dispatch_block_t)updateHandler
{
    [self.dataSource didFinishContentLoading:self withResultType:resultType error:error update:updateHandler];
}

- (void)invalidate {
    self.valid = NO;
}

@end
