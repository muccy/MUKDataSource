//
//  MUKDataSourceTableSectionsUpdate.m
//  
//
//  Created by Marco on 11/06/15.
//
//

#import "MUKDataSourceTableUpdate.h"
#import "MUKDataSourceTableSection.h"
#import <MUKArrayDelta/MUKArrayDelta.h>

static MUKDataSourceTableUpdateSectionMovement *MovementWithDestinationIndex(NSUInteger idx, NSSet *movements)
{
    for (MUKDataSourceTableUpdateSectionMovement *movement in movements) {
        if (movement.destinationIndex == idx) {
            return movement;
        }
    } // for
    
    return nil;
}

static MUKDataSourceTableUpdateSectionMovement *MovementWithSourceIndex(NSUInteger idx, NSSet *movements)
{
    for (MUKDataSourceTableUpdateSectionMovement *movement in movements) {
        if (movement.sourceIndex == idx) {
            return movement;
        }
    } // for
    
    return nil;
}

static inline NSString *IndexPathDescription(NSIndexPath *indexPath) {
    return [NSString stringWithFormat:@"(%lu, %lu)", (unsigned long)indexPath.section, (unsigned long)indexPath.row];
}

#pragma mark -

@implementation MUKDataSourceTableUpdateSectionMovement

- (instancetype)initWithSourceIndex:(NSUInteger)sourceIndex destinationIndex:(NSUInteger)destinationIndex
{
    self = [super init];
    if (self) {
        _sourceIndex = sourceIndex;
        _destinationIndex = destinationIndex;
    }
    
    return self;
}

- (BOOL)isEqualToTableUpdateSectionMovement:(MUKDataSourceTableUpdateSectionMovement *)movement
{
    return self.sourceIndex == movement.sourceIndex && self.destinationIndex == movement.destinationIndex;
}

#pragma mark Overrides

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self isEqualToTableUpdateSectionMovement:object];
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

@implementation MUKDataSourceTableUpdateRowMovement

- (instancetype)initWithSourceIndexPath:(NSIndexPath *)sourceIndexPath destinationIndexPath:(NSIndexPath *)destinationIndexPath
{
    self = [super init];
    if (self) {
        _sourceIndexPath = sourceIndexPath;
        _destinationIndexPath = destinationIndexPath;
    }
    
    return self;
}

- (BOOL)isEqualToTableUpdateRowMovement:(MUKDataSourceTableUpdateRowMovement *)movement
{
    return [self.sourceIndexPath isEqual:movement.sourceIndexPath] && [self.destinationIndexPath isEqual:movement.destinationIndexPath];
}

#pragma mark Overrides

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self isEqualToTableUpdateRowMovement:object];
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

@interface MUKDataSourceTableUpdate ()
@end

@implementation MUKDataSourceTableUpdate

- (instancetype)initWithSourceTableSections:(NSArray *)sourceSections destinationTableSections:(NSArray *)destinationSections
{
    self = [super init];
    if (self) {
        _sourceTableSections = [sourceSections copy];
        _destinationTableSections = [destinationSections copy];
        
        MUKArrayDelta *const sectionsDelta = [[MUKArrayDelta alloc] initWithSourceArray:sourceSections destinationArray:destinationSections matchTest:^MUKArrayDeltaMatchType(MUKDataSourceTableSection *section1, MUKDataSourceTableSection *section2)
        {
            if ([section1 isEqualToDataSourceTableSection:section2])
            {
                return MUKArrayDeltaMatchTypeEqual;
            }
            else if ([section1.identifier isEqual:section2.identifier])
            {
                return MUKArrayDeltaMatchTypeChange;
            }
            
            return MUKArrayDeltaMatchTypeNone;
        }];
        
        [self buildUpdateInfosWithDelta:sectionsDelta];
    }
    
    return self;
}

- (void)applyToTableView:(UITableView *)tableView animated:(BOOL)animated {
    if (self.needsReloadData) {
        [tableView reloadData];
        return;
    }
    
    UITableViewRowAnimation const animation = animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone;
    
    [tableView beginUpdates];
    {
        [tableView insertSections:self.insertedSectionIndexes withRowAnimation:animation];
        [tableView deleteSections:self.deletedSectionIndexes withRowAnimation:animation];
        
        for (MUKDataSourceTableUpdateSectionMovement *movement in self.sectionMovements)
        {
            [tableView moveSection:movement.sourceIndex toSection:movement.destinationIndex];
        } // for
        
        [tableView insertRowsAtIndexPaths:[self.insertedRowIndexPaths allObjects] withRowAnimation:animation];
        [tableView deleteRowsAtIndexPaths:[self.deletedRowIndexPaths allObjects] withRowAnimation:animation];
        
        for (MUKDataSourceTableUpdateRowMovement *movement in self.rowMovements)
        {
            [tableView moveRowAtIndexPath:movement.sourceIndexPath toIndexPath:movement.destinationIndexPath];
        } // for
    }
    [tableView endUpdates];
    
    [tableView beginUpdates];
    {
        [tableView reloadSections:self.reloadedSectionIndexes withRowAnimation:animation];
        [tableView reloadRowsAtIndexPaths:[self.reloadedRowIndexPaths allObjects] withRowAnimation:animation];
    }
    [tableView endUpdates];
}

#pragma mark Private

- (void)buildUpdateInfosWithDelta:(MUKArrayDelta *)delta {
    _insertedSectionIndexes = delta.insertedIndexes;
    _deletedSectionIndexes = delta.deletedIndexes;
    
    NSMutableSet *sectionMovements = [NSMutableSet setWithCapacity:delta.movements.count];
    for (MUKArrayDeltaMatch *match in delta.movements) {
        MUKDataSourceTableUpdateSectionMovement *const movement = [[MUKDataSourceTableUpdateSectionMovement alloc] initWithSourceIndex:match.sourceIndex destinationIndex:match.destinationIndex];
        [sectionMovements addObject:movement];
    } // for
    _sectionMovements = [sectionMovements copy];

    /*
     I reload destination indexes because table views don't like to move a section
     which is reloaded.
     If you reload a section index which is a source index of a movement, table
     will throw a "attempt to perform a delete and a move from the same section".
     If you reload a section index which is a destionation index of a movement, table
     will throw a "attempt to perform an insert and a move to the same section".
     To solve this problem I break update into two block of beginUpdates-endUpdates:
     1) insertion+deletion+move
     2) reload
     */
    NSMutableIndexSet *const reloadedSectionDestinationIndexes = [NSMutableIndexSet indexSet];
    NSMutableSet *const unresolvedSectionChanges = [NSMutableSet set];
    
    for (MUKArrayDeltaMatch *match in delta.changes) {
        MUKDataSourceTableSection *const sourceSection = delta.sourceArray[match.sourceIndex];
        MUKDataSourceTableSection *const destinationSection = delta.destinationArray[match.destinationIndex];
        
        if (![sourceSection.items isEqualToArray:destinationSection.items]) {
            [unresolvedSectionChanges addObject:match];
        }
        
        if ([[self class] shouldReloadWholeSection:destinationSection changedFromSection:sourceSection])
        {
            [reloadedSectionDestinationIndexes addIndex:match.destinationIndex];
        }
    } // for
    _reloadedSectionIndexes = [reloadedSectionDestinationIndexes copy];
    
    // Now cycle through all not resolved changes looking for their deltas and
    // compose rows update
    NSMutableArray *insertedRowIndexPaths = [NSMutableArray array];
    NSMutableArray *deletedRowIndexPaths = [NSMutableArray array];
    NSMutableSet *reloadedRowIndexPaths = [NSMutableSet set];
    NSMutableSet *rowMovements = [NSMutableSet set];
    
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
        MUKDataSourceTableSection *const sourceSection = delta.sourceArray[sectionMatch.sourceIndex];
        MUKDataSourceTableSection *const destinationSection = delta.destinationArray[sectionMatch.destinationIndex];
        
        // Get delta of this section change
        MUKArrayDelta *const sectionDelta = [[MUKArrayDelta alloc] initWithSourceArray:sourceSection.items destinationArray:destinationSection.items matchTest:itemsMatchTest];
        
        // Get inserted index paths
        [sectionDelta.insertedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
        {
            NSIndexPath *const indexPath = [NSIndexPath indexPathForRow:idx inSection:sectionMatch.destinationIndex];
            [insertedRowIndexPaths addObject:indexPath];
        }];
        
        // Get deleted index paths
        [sectionDelta.deletedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
         {
             NSIndexPath *const indexPath = [NSIndexPath indexPathForRow:idx inSection:sectionMatch.sourceIndex];
             [deletedRowIndexPaths addObject:indexPath];
         }];
        
        // Get movements inside the section
        [sectionDelta.movements enumerateObjectsUsingBlock:^(MUKArrayDeltaMatch *movement, BOOL *stop)
        {
            NSIndexPath *const sourceIndexPath = [NSIndexPath indexPathForRow:movement.sourceIndex inSection:sectionMatch.destinationIndex];
            NSIndexPath *const destinationIndexPath = [NSIndexPath indexPathForRow:movement.destinationIndex inSection:sectionMatch.destinationIndex];
            
            MUKDataSourceTableUpdateRowMovement *const rowMovement = [[MUKDataSourceTableUpdateRowMovement alloc] initWithSourceIndexPath:sourceIndexPath destinationIndexPath:destinationIndexPath];
            [rowMovements addObject:rowMovement];
        }];
        
        // Get reloaded index paths (I get destination index paths for the same
        // reason I've got section destination indexes before)
        [sectionDelta.changes enumerateObjectsUsingBlock:^(MUKArrayDeltaMatch *change, BOOL *stop)
        {
            NSIndexPath *const indexPath = [NSIndexPath indexPathForRow:change.destinationIndex inSection:sectionMatch.destinationIndex];
            [reloadedRowIndexPaths addObject:indexPath];
        }];
    } // for
    
    // But it's not over because some rows could be moved between sections: in that
    // case we would have detected false insertion-deletion
    NSMutableIndexSet *validDeletedRowIndexPathIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, deletedRowIndexPaths.count)];
    NSMutableIndexSet *validInsertedRowIndexPathIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, insertedRowIndexPaths.count)];
    
    [deletedRowIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *deletedIndexPath, NSUInteger deletedIndexPathIndex, BOOL *stop)
    {
        MUKDataSourceTableSection *const deletedItemSection = delta.sourceArray[deletedIndexPath.section];
        id<MUKDataSourceIdentifiable> const deletedItem = deletedItemSection.items[deletedIndexPath.row];
        
        [insertedRowIndexPaths enumerateObjectsAtIndexes:validInsertedRowIndexPathIndexes options:0 usingBlock:^(NSIndexPath *insertedIndexPath, NSUInteger insertedIndexPathIndex, BOOL *stop)
        {
            MUKDataSourceTableSection *const insertedItemSection = delta.destinationArray[insertedIndexPath.section];
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
                MUKDataSourceTableUpdateRowMovement *const rowMovement = [[MUKDataSourceTableUpdateRowMovement alloc] initWithSourceIndexPath:deletedIndexPath destinationIndexPath:insertedIndexPath];
                [rowMovements addObject:rowMovement];
                
                // If it's a change, row should be reloaded too
                if (matchType == MUKArrayDeltaMatchTypeChange) {
                    [reloadedRowIndexPaths addObject:insertedIndexPath];
                }
                
                // Exclude those index paths
                [validDeletedRowIndexPathIndexes removeIndex:deletedIndexPathIndex];
                [validInsertedRowIndexPathIndexes removeIndex:insertedIndexPathIndex];
                
                // We are done with this deleted item
                *stop = YES;
            }
        }]; // insertedRowIndexPaths enumerateObjectsAtIndexes:
    }]; // deletedRowIndexPaths enumerateObjectsUsingBlock:
    
    // Store filtered values now
    _insertedRowIndexPaths = [NSSet setWithArray:[insertedRowIndexPaths objectsAtIndexes:validInsertedRowIndexPathIndexes]];
    _deletedRowIndexPaths = [NSSet setWithArray:[deletedRowIndexPaths objectsAtIndexes:validDeletedRowIndexPathIndexes]];
    _reloadedRowIndexPaths = [reloadedRowIndexPaths copy];
    _rowMovements = [rowMovements copy];
    
    // Unfortunately there are case when -reloadData is compulsory (also for
    // some unresolved bugs in UITableView)
    if ([self needsToForceReloadData]) {
        _insertedSectionIndexes = _deletedSectionIndexes = _reloadedSectionIndexes = nil;
        _sectionMovements = _insertedRowIndexPaths = _deletedRowIndexPaths = _reloadedRowIndexPaths = _rowMovements = nil;
        _needsReloadData = YES;
    }
}

+ (BOOL)shouldReloadWholeSection:(MUKDataSourceTableSection *)section changedFromSection:(MUKDataSourceTableSection *)originalSection
{
    BOOL const sameHeaderTitle = (!section.headerTitle && !section.headerTitle) || [section.headerTitle isEqualToString:originalSection.headerTitle];
    BOOL const sameFooterTitle = (!section.footerTitle && !section.footerTitle) || [section.footerTitle isEqualToString:originalSection.footerTitle];
    return !sameHeaderTitle || !sameFooterTitle;
}

- (BOOL)needsToForceReloadData {
    for (NSIndexPath *indexPath in self.insertedRowIndexPaths) {
        if (MovementWithDestinationIndex(indexPath.section, self.sectionMovements))
        {
            // Throws "-[__NSArrayM insertObject:atIndex:]: object cannot be nil"
            // when you insert a row in a moved section
            return YES;
        } // if
    } // for
    
    for (NSIndexPath *indexPath in self.deletedRowIndexPaths) {
        if (MovementWithSourceIndex(indexPath.section, self.sectionMovements))
        {
            // Throws "-[__NSArrayM insertObject:atIndex:]: object cannot be nil"
            // when you delete a row in a moved section
            return YES;
        } // if
    } // for
    
    for (MUKDataSourceTableUpdateRowMovement *rowMovement in self.rowMovements) {
        if (MovementWithDestinationIndex(rowMovement.destinationIndexPath.section, self.sectionMovements))
        {
            // Throws "-[__NSArrayM insertObject:atIndex:]: object cannot be nil"
            // when you move a row to a moved section
            return YES;
        }
    } // for
    
    // There other errors managed in code, like:
    // - moving a row to newly inserted section
    // - moving a row from a deleted section
    
    return NO;
}

@end
