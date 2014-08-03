#import "MUKDataSourceArrayDelta.h"

@interface MUKDataSourceArrayDelta ()
@property (nonatomic, readwrite) NSIndexSet *insertedIndexes, *deletedIndexes;
@property (nonatomic, readwrite) NSArray *movementIndexPaths; // [(src, dst), (src, dst), ...]
@end

@implementation MUKDataSourceArrayDelta
@dynamic deletedObjects, insertedObjects;

- (instancetype)initWithSourceArray:(NSArray *)sourceArray destinationArray:(NSArray *)destinationArray
{
    self = [super init];
    if (self) {
        _sourceArray = [sourceArray copy];
        _destinationArray = [destinationArray copy];
        [self buildDeltaInfos];
    }
    
    return self;
}

#pragma mark - Methods

- (NSArray *)deletedObjects {
    return [self.sourceArray objectsAtIndexes:self.deletedIndexes];
}

- (NSArray *)insertedObjects {
    return [self.destinationArray objectsAtIndexes:self.insertedIndexes];
}

- (void)enumerateMovementsUsingBlock:(void (^)(NSInteger, NSInteger, BOOL *))enumerationBlock
{
    if (!enumerationBlock) {
        return;
    }
    
    [self.movementIndexPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        enumerationBlock([obj indexAtPosition:0], [obj indexAtPosition:1], stop);
    }];
}

#pragma mark - Private

- (void)buildDeltaInfos {
    // Find deleted and movement together
    NSMutableIndexSet *consumedDestinationIndexes = [[NSMutableIndexSet alloc] init];
    NSMutableIndexSet *deletedIndexes = [[NSMutableIndexSet alloc] init];
    NSMutableArray *movementIndexPaths = [[NSMutableArray alloc] init];
    
    [self.sourceArray enumerateObjectsUsingBlock:^(id sourceObject, NSUInteger idx, BOOL *stop)
    {
        NSInteger const fromIndex = idx;
        NSInteger const toIndex = [self.destinationArray indexOfObjectPassingTest:^BOOL(id destinationObject, NSUInteger idx, BOOL *stop)
        {
            // Get index for object that match and it has not been used before
            if (![consumedDestinationIndexes containsIndex:idx] &&
                [sourceObject isEqual:destinationObject])
            {
                *stop = YES;
                return YES;
            }
            
            return NO;
        }]; // indexOfObjectPassingTest
        
        if (fromIndex != toIndex) {
            if (toIndex == NSNotFound) {
                // Object deleted
                [deletedIndexes addIndex:fromIndex];
            }
            else {
                // Object moved
                NSIndexPath *movementPath = MovementIndexPath(fromIndex, toIndex);
                
                // Does inverse path exist?
                NSIndexPath *inverseMovementPath = MovementIndexPath(toIndex, fromIndex);
                
                if (![movementIndexPaths containsObject:inverseMovementPath]) {
                    // Ok, move is right
                    [movementIndexPaths addObject:movementPath];
                } // if
            }
        } // it
        
        // Mark as consumed
        if (toIndex != NSNotFound) {
            [consumedDestinationIndexes addIndex:toIndex];
        }
    }]; // enumerateObjectsAtIndexes
    
    // Store them
    self.deletedIndexes = [deletedIndexes copy];
    self.movementIndexPaths = [movementIndexPaths copy];
    
    // Find inserted indexes
    self.insertedIndexes = [self.destinationArray indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
    {
        return ![self.sourceArray containsObject:obj];
    }];
}

static inline NSIndexPath *MovementIndexPath(NSInteger fromIndex, NSInteger toIndex)
{
    NSUInteger const indexes[2] = { (NSUInteger)fromIndex, (NSUInteger)toIndex };
    return [NSIndexPath indexPathWithIndexes:indexes length:2];
}

@end
