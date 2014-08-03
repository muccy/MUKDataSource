#import <Foundation/Foundation.h>

@interface MUKDataSourceArrayDelta : NSObject
@property (nonatomic, copy, readonly) NSArray *sourceArray, *destinationArray;
@property (nonatomic, readonly) NSIndexSet *insertedIndexes, *deletedIndexes;
@property (nonatomic, readonly) NSArray *movementIndexPaths; // [(src, dst), (src, dst), ...]

@property (nonatomic, readonly) NSArray *deletedObjects, *insertedObjects;

- (instancetype)initWithSourceArray:(NSArray *)sourceArray destinationArray:(NSArray *)destinationArray;
- (void)enumerateMovementsUsingBlock:(void (^)(NSInteger fromIndex, NSInteger toIndex, BOOL *stop))enumerationBlock;
@end
