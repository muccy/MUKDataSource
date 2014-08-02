#import <Foundation/Foundation.h>

@interface MUKDataSourceBatch : NSObject
@property (nonatomic, readonly) NSArray *blocks;
- (void)addBlock:(dispatch_block_t)block;
- (void)performAllBlocks;
@end
