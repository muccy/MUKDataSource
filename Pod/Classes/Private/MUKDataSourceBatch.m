#import "MUKDataSourceBatch.h"

@interface MUKDataSourceBatch ()
@property (nonatomic, readwrite) NSMutableArray *mutableBlockArray;
@end

@implementation MUKDataSourceBatch
@dynamic blocks;

- (id)init {
    self = [super init];
    if (self) {
        _mutableBlockArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addBlock:(dispatch_block_t)block {
    if (block) {
        [self.mutableBlockArray addObject:[block copy]];
    }
}

- (void)performAllBlocks {
    for (dispatch_block_t block in self.blocks) {
        block();
    }
}

- (NSArray *)blocks {
    return [self.mutableBlockArray copy];
}

@end
