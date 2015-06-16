//
//  MUKDataSourceSectionedContentUpdate.m
//  
//
//  Created by Marco on 16/06/15.
//
//

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

- (BOOL)shouldReloadSection:(id<MUKDataSourceContentSection>)section changedFromSection:(id<MUKDataSourceContentSection>)oldSection
{
    return NO;
}

#pragma mark Private

- (void)buildUpdateInfosWithDelta:(MUKArrayDelta *)delta {
    _insertedSectionIndexes = delta.insertedIndexes;
    _deletedSectionIndexes = delta.deletedIndexes;
    
    NSMutableSet *sectionMovements = [NSMutableSet setWithCapacity:delta.movements.count];
    for (MUKArrayDeltaMatch *match in delta.movements) {
        MUKDataSourceContentSectionMovement *const movement = [[MUKDataSourceContentSectionMovement alloc] initWithSourceIndex:match.sourceIndex destinationIndex:match.destinationIndex];
        [sectionMovements addObject:movement];
    } // for
    _sectionMovements = [sectionMovements copy];
    
    /*
     I reload destination indexes because table/collection views don't like to move 
     a section which is reloaded.
     If you reload a section index which is a source index of a movement, table
     will throw a "attempt to perform a delete and a move from the same section".
     If you reload a section index which is a destionation index of a movement, table
     will throw a "attempt to perform an insert and a move to the same section".
     To solve this problem I break update into two block of updates:
     1) insertion+deletion+move
     2) reload
     */
    NSMutableIndexSet *const reloadedSectionDestinationIndexes = [NSMutableIndexSet indexSet];
    NSMutableSet *const unresolvedSectionChanges = [NSMutableSet set];
    
    for (MUKArrayDeltaMatch *match in delta.changes) {
        id<MUKDataSourceContentSection> const sourceSection = delta.sourceArray[match.sourceIndex];
        id<MUKDataSourceContentSection> const destinationSection = delta.destinationArray[match.destinationIndex];
        
        if (![sourceSection.items isEqualToArray:destinationSection.items]) {
            [unresolvedSectionChanges addObject:match];
        }
        
        if ([self shouldReloadSection:destinationSection changedFromSection:sourceSection])
        {
            [reloadedSectionDestinationIndexes addIndex:match.destinationIndex];
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
            NSIndexPath *const indexPath = [NSIndexPath indexPathForRow:idx inSection:sectionMatch.destinationIndex];
            [insertedItemIndexPaths addObject:indexPath];
        }];
        
        // Get deleted index paths
        [sectionDelta.deletedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
        {
            NSIndexPath *const indexPath = [NSIndexPath indexPathForRow:idx inSection:sectionMatch.sourceIndex];
            [deletedItemIndexPaths addObject:indexPath];
        }];
        
        // Get movements inside the section
        [sectionDelta.movements enumerateObjectsUsingBlock:^(MUKArrayDeltaMatch *movement, BOOL *stop)
        {
            NSIndexPath *const sourceIndexPath = [NSIndexPath indexPathForRow:movement.sourceIndex inSection:sectionMatch.destinationIndex];
            NSIndexPath *const destinationIndexPath = [NSIndexPath indexPathForRow:movement.destinationIndex inSection:sectionMatch.destinationIndex];
            
            MUKDataSourceContentSectionItemMovement *const itemMovement = [[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:sourceIndexPath destinationIndexPath:destinationIndexPath];
            [itemMovements addObject:itemMovement];
        }];
        
        // Get reloaded index paths (I get destination index paths for the same
        // reason I've got section destination indexes before)
        [sectionDelta.changes enumerateObjectsUsingBlock:^(MUKArrayDeltaMatch *change, BOOL *stop)
        {
            NSIndexPath *const indexPath = [NSIndexPath indexPathForRow:change.destinationIndex inSection:sectionMatch.destinationIndex];
            [reloadedItemIndexPaths addObject:indexPath];
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
