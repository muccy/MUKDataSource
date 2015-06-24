#import "MUKDataSourceSectionedContentUpdate.h"
#import <MUKArrayDelta/MUKArrayDelta.h>
#import "MUKDataSourceContentSection.h"

static inline NSString *IndexPathDescription(NSIndexPath *indexPath) {
    return [NSString stringWithFormat:@"(%lu, %lu)", (unsigned long)indexPath.section, (unsigned long)indexPath.row];
}

#pragma mark -

@implementation MUKDataSourceContentSectionMovement

- (instancetype)initWithSourceIndex:(NSUInteger)sourceIndex destinationIndex:(NSUInteger)destinationIndex
{
    self = [super init];
    if (self) {
        _sourceIndex = sourceIndex;
        _destinationIndex = destinationIndex;
    }
    
    return self;
}

- (BOOL)isEqualToContentSectionMovement:(MUKDataSourceContentSectionMovement *)movement
{
    return self.sourceIndex == movement.sourceIndex && self.destinationIndex == movement.destinationIndex;
}

#pragma mark Overrides

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self isEqualToContentSectionMovement:object];
    }
    
    return NO;
}

- (NSUInteger)hash {
    return 4290 ^ self.sourceIndex ^ self.destinationIndex;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %lu -> %lu", [super description], (unsigned long)self.sourceIndex, (unsigned long)self.destinationIndex];
}

@end

#pragma mark -

@implementation MUKDataSourceContentSectionItemMovement

- (instancetype)initWithSourceIndexPath:(NSIndexPath *)sourceIndexPath destinationIndexPath:(NSIndexPath *)destinationIndexPath
{
    self = [super init];
    if (self) {
        _sourceIndexPath = sourceIndexPath;
        _destinationIndexPath = destinationIndexPath;
    }
    
    return self;
}

- (BOOL)isEqualToContentSectionItemMovement:(MUKDataSourceContentSectionItemMovement *)movement
{
    return [self.sourceIndexPath isEqual:movement.sourceIndexPath] && [self.destinationIndexPath isEqual:movement.destinationIndexPath];
}

#pragma mark Overrides

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self isEqualToContentSectionItemMovement:object];
    }
    
    return NO;
}

- (NSUInteger)hash {
    return 903 ^ [self.sourceIndexPath hash] ^ [self.destinationIndexPath hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ -> %@", [super description], IndexPathDescription(self.sourceIndexPath), IndexPathDescription(self.destinationIndexPath)];
}

@end

#pragma mark -

@implementation MUKDataSourceSectionedContentUpdate

- (instancetype)initWithSourceSections:(NSArray *)sourceSections destinationSections:(NSArray *)destinationSections
{
    self = [super init];
    if (self) {
        _sourceSections = [sourceSections copy];
        _destinationSections = [destinationSections copy];
        
        MUKArrayDelta *const sectionsDelta = [[MUKArrayDelta alloc] initWithSourceArray:sourceSections destinationArray:destinationSections matchTest:^MUKArrayDeltaMatchType(id<MUKDataSourceContentSection> section1, id<MUKDataSourceContentSection> section2)
        {
            if ([section1 isEqual:section2]) {
                return MUKArrayDeltaMatchTypeEqual;
            }
            else if ([section1 respondsToSelector:@selector(identifier)] &&
                     [section2 respondsToSelector:@selector(identifier)] &&
                     [section1.identifier isEqual:section2.identifier])
            {
                return MUKArrayDeltaMatchTypeChange;
            }
            
            return MUKArrayDeltaMatchTypeNone;
        }];
        
        [self buildUpdateInfosWithDelta:sectionsDelta];
    }
    
    return self;
}

#pragma mark Build

- (NSIndexSet *)insertedSectionIndexesFromDelta:(MUKArrayDelta *)delta {
    return delta.insertedIndexes;
}

- (NSIndexSet *)deletedSectionIndexesFromDelta:(MUKArrayDelta *)delta {
    return delta.deletedIndexes;
}

- (MUKDataSourceContentSectionMovement *)sectionMovementForDelta:(MUKArrayDelta *)delta movement:(MUKArrayDeltaMatch *)movement
{
    return [[MUKDataSourceContentSectionMovement alloc] initWithSourceIndex:movement.sourceIndex destinationIndex:movement.destinationIndex];
}

- (NSUInteger)reloadedSectionIndexForDelta:(MUKArrayDelta *)delta change:(MUKArrayDeltaMatch *)change
{
    return NSNotFound;
}

- (NSIndexPath *)insertedItemIndexPathForDelta:(MUKArrayDelta *)delta insertedIndex:(NSUInteger)idx sectionMatch:(MUKArrayDeltaMatch *)sectionMatch
{
    return [NSIndexPath indexPathForItem:idx inSection:sectionMatch.destinationIndex];
}

- (NSIndexPath *)deletedItemIndexPathForDelta:(MUKArrayDelta *)delta deletedIndex:(NSUInteger)idx sectionMatch:(MUKArrayDeltaMatch *)sectionMatch
{
    return [NSIndexPath indexPathForItem:idx inSection:sectionMatch.sourceIndex];
}

- (MUKDataSourceContentSectionItemMovement *)itemMovementForDelta:(MUKArrayDelta *)delta movement:(MUKArrayDeltaMatch *)movement sectionMatch:(MUKArrayDeltaMatch *)sectionMatch
{
    NSIndexPath *const sourceIndexPath = [NSIndexPath indexPathForRow:movement.sourceIndex inSection:sectionMatch.sourceIndex];
    NSIndexPath *const destinationIndexPath = [NSIndexPath indexPathForRow:movement.destinationIndex inSection:sectionMatch.destinationIndex];
    
    return [[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:sourceIndexPath destinationIndexPath:destinationIndexPath];
}

- (NSIndexPath *)reloadedItemIndexPathForDelta:(MUKArrayDelta *)delta change:(MUKArrayDeltaMatch *)change sectionMatch:(MUKArrayDeltaMatch *)sectionMatch
{
    return [NSIndexPath indexPathForRow:change.sourceIndex inSection:sectionMatch.sourceIndex];
}

#pragma mark Private

- (void)buildUpdateInfosWithDelta:(MUKArrayDelta *)delta {
    _insertedSectionIndexes = [self insertedSectionIndexesFromDelta:delta];
    _deletedSectionIndexes = [self deletedSectionIndexesFromDelta:delta];
    
    NSMutableSet *sectionMovements = [NSMutableSet setWithCapacity:delta.movements.count];
    for (MUKArrayDeltaMatch *match in delta.movements) {
        MUKDataSourceContentSectionMovement *const movement = [self sectionMovementForDelta:delta movement:match];
        if (movement) {
            [sectionMovements addObject:movement];
        }
    } // for
    _sectionMovements = [sectionMovements copy];
    
    NSMutableIndexSet *const reloadedSectionDestinationIndexes = [NSMutableIndexSet indexSet];
    NSMutableSet *const unresolvedSectionChanges = [NSMutableSet set];
    
    for (MUKArrayDeltaMatch *match in delta.changes) {
        id<MUKDataSourceContentSection> const sourceSection = delta.sourceArray[match.sourceIndex];
        id<MUKDataSourceContentSection> const destinationSection = delta.destinationArray[match.destinationIndex];
        
        if (![sourceSection.items isEqualToArray:destinationSection.items]) {
            [unresolvedSectionChanges addObject:match];
        }
        
        NSUInteger const reloadedIndex = [self reloadedSectionIndexForDelta:delta change:match];
        if (reloadedIndex != NSNotFound) {
            [reloadedSectionDestinationIndexes addIndex:reloadedIndex];
        }
    } // for
    _reloadedSectionIndexes = [reloadedSectionDestinationIndexes copy];
    
    // Now cycle through all not resolved changes looking for their deltas and
    // compose rows update
    NSMutableArray *insertedItemIndexPaths = [NSMutableArray array];
    NSMutableArray *deletedItemIndexPaths = [NSMutableArray array];
    NSMutableSet *reloadedItemIndexPaths = [NSMutableSet set];
    NSMutableSet *itemMovements = [NSMutableSet set];
    
    MUKArrayDeltaMatchTest const itemsMatchTest = ^MUKArrayDeltaMatchType(id<MUKDataSourceIdentifiable> object1, id<MUKDataSourceIdentifiable> object2)
    {
        if ([object1 isEqual:object2]) {
            return MUKArrayDeltaMatchTypeEqual;
        }
        else if ([object1 respondsToSelector:@selector(identifier)] &&
                 [object2 respondsToSelector:@selector(identifier)] &&
                 [object1.identifier isEqual:object2.identifier])
        {
            return MUKArrayDeltaMatchTypeChange;
        }
        
        return MUKArrayDeltaMatchTypeNone;
    };
    
    for (MUKArrayDeltaMatch *const sectionMatch in unresolvedSectionChanges) {
        // Get involved sections
        id<MUKDataSourceContentSection> const sourceSection = delta.sourceArray[sectionMatch.sourceIndex];
        id<MUKDataSourceContentSection> const destinationSection = delta.destinationArray[sectionMatch.destinationIndex];
        
        // Get delta of this section change
        MUKArrayDelta *const sectionDelta = [[MUKArrayDelta alloc] initWithSourceArray:sourceSection.items destinationArray:destinationSection.items matchTest:itemsMatchTest];
        
        // Get inserted index paths
        [sectionDelta.insertedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
        {
            NSIndexPath *const indexPath = [self insertedItemIndexPathForDelta:sectionDelta insertedIndex:idx sectionMatch:sectionMatch];
            if (indexPath) {
                [insertedItemIndexPaths addObject:indexPath];
            }
        }];
        
        // Get deleted index paths
        [sectionDelta.deletedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
        {
            NSIndexPath *const indexPath = [self deletedItemIndexPathForDelta:sectionDelta deletedIndex:idx sectionMatch:sectionMatch];
            if (indexPath) {
                [deletedItemIndexPaths addObject:indexPath];
            }
        }];
        
        // Get movements inside the section
        [sectionDelta.movements enumerateObjectsUsingBlock:^(MUKArrayDeltaMatch *match, BOOL *stop)
        {
            MUKDataSourceContentSectionItemMovement *const movement = [self itemMovementForDelta:sectionDelta movement:match sectionMatch:sectionMatch];
            if (movement) {
                [itemMovements addObject:movement];
            }
        }];
        
        // Get reloaded index paths (I get destination index paths for the same
        // reason I've got section destination indexes before)
        [sectionDelta.changes enumerateObjectsUsingBlock:^(MUKArrayDeltaMatch *change, BOOL *stop)
        {
            NSIndexPath *const indexPath = [self reloadedItemIndexPathForDelta:sectionDelta change:change sectionMatch:sectionMatch];
            if (indexPath) {
                [reloadedItemIndexPaths addObject:indexPath];
            }
        }];
    } // for
    
    // But it's not over because some items could be moved between sections: in that
    // case we would have detected false insertion-deletion
    NSMutableIndexSet *validDeletedItemIndexPathIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, deletedItemIndexPaths.count)];
    NSMutableIndexSet *validInsertedItemIndexPathIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, insertedItemIndexPaths.count)];
    
    [deletedItemIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *deletedIndexPath, NSUInteger deletedIndexPathIndex, BOOL *stop)
    {
        id<MUKDataSourceContentSection> const deletedItemSection = delta.sourceArray[deletedIndexPath.section];
        id<MUKDataSourceIdentifiable> const deletedItem = deletedItemSection.items[deletedIndexPath.row];
        
        [insertedItemIndexPaths enumerateObjectsAtIndexes:validInsertedItemIndexPathIndexes options:0 usingBlock:^(NSIndexPath *insertedIndexPath, NSUInteger insertedIndexPathIndex, BOOL *stop)
        {
            id<MUKDataSourceContentSection> const insertedItemSection = delta.destinationArray[insertedIndexPath.section];
            if ([insertedItemSection.identifier isEqual:deletedItemSection.identifier])
            {
                // Same section: do not inspect this case
                return;
            }
            
            // Test deleted and inserted items
            id<MUKDataSourceIdentifiable> const insertedItem = insertedItemSection.items[insertedIndexPath.row];
            MUKArrayDeltaMatchType const matchType = itemsMatchTest(deletedItem, insertedItem);
            
            if (matchType != MUKArrayDeltaMatchTypeNone) {
                // If there is a match it means it's a movement
                MUKDataSourceContentSectionItemMovement *const itemMovement = [[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:deletedIndexPath destinationIndexPath:insertedIndexPath];
                [itemMovements addObject:itemMovement];
                
                // If it's a change, row should be reloaded too
                if (matchType == MUKArrayDeltaMatchTypeChange) {
                    [reloadedItemIndexPaths addObject:insertedIndexPath];
                }
                
                // Exclude those index paths
                [validDeletedItemIndexPathIndexes removeIndex:deletedIndexPathIndex];
                [validInsertedItemIndexPathIndexes removeIndex:insertedIndexPathIndex];
                
                // We are done with this deleted item
                *stop = YES;
            }
        }]; // insertedItemIndexPaths enumerateObjectsAtIndexes:
    }]; // deletedItemIndexPaths enumerateObjectsUsingBlock:
    
    // Store filtered values now
    _insertedItemIndexPaths = [NSSet setWithArray:[insertedItemIndexPaths objectsAtIndexes:validInsertedItemIndexPathIndexes]];
    _deletedItemIndexPaths = [NSSet setWithArray:[deletedItemIndexPaths objectsAtIndexes:validDeletedItemIndexPathIndexes]];
    _reloadedItemIndexPaths = [reloadedItemIndexPaths copy];
    _itemMovements = [itemMovements copy];
}

@end
