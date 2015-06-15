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
    return [NSString stringWithFormat:@"%@ – %lu -> %lu", [super description], (unsigned long)self.sourceIndex, (unsigned long)self.destinationIndex];
}

@end

#pragma mark - 

@implementation MUKDataSourceTableUpdateRowMovement

- (instancetype)initWithSourceIndex:(NSIndexPath *)sourceIndexPath destinationIndex:(NSIndexPath *)destinationIndexPath
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
        [self buildSectionUpdatesWithDelta:sectionsDelta];
        
        // TODO
    }
    
    return self;
}

- (void)applyToTableView:(UITableView *)tableView animated:(BOOL)animated {
    UITableViewRowAnimation const animation = animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone;
    
    [tableView beginUpdates];
    
    [tableView insertSections:self.insertedSectionIndexes withRowAnimation:animation];
    [tableView deleteSections:self.deletedSectionIndexes withRowAnimation:animation];
    
    for (MUKDataSourceTableUpdateSectionMovement *movement in self.sectionMovements)
    {
        [tableView moveSection:movement.sourceIndex toSection:movement.destinationIndex];
    } // for
    
    [tableView endUpdates];
    
    [tableView beginUpdates];
    [tableView reloadSections:self.reloadedSectionIndexes withRowAnimation:animation];
    [tableView endUpdates];
}

#pragma mark - Private

- (void)buildSectionUpdatesWithDelta:(MUKArrayDelta *)delta {
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
    NSMutableIndexSet *reloadedSectionDestinationIndexes = [NSMutableIndexSet indexSet];
    for (MUKArrayDeltaMatch *match in delta.changes) {
        [reloadedSectionDestinationIndexes addIndex:match.destinationIndex];
    } // for
    _reloadedSectionIndexes = [reloadedSectionDestinationIndexes copy];
}

/*
- (BOOL)hasMultipleUpdatesToApply {
    NSUInteger updateCount = 0;
    
    updateCount += self.sectionsDelta.insertedIndexes.count + self.sectionsDelta.deletedIndexes.count + self.sectionsDelta.changedIndexes.count + self.sectionsDelta.movements.count;
    
    if (updateCount > 1) {
        return YES;
    }
    
    // TODO
    
    return NO;
}
*/
- (void)applySectionUpdatesToTableView:(UITableView *)tableView animated:(BOOL)animated
{
    /*
    MUKArrayDelta *const delta = self.sectionsDelta;
    UITableViewRowAnimation const animation = animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone;
    
    [tableView beginUpdates];
    [tableView insertSections:delta.insertedIndexes withRowAnimation:animation];
    [tableView deleteSections:delta.deletedIndexes withRowAnimation:animation];
    [tableView endUpdates];
    
    NSMutableIndexSet *changedIndexes = [NSMutableIndexSet indexSet];
    NSArray *const orderedMovements = [[delta.movements allObjects] sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(sourceIndex)) ascending:YES] ]];
    
    for (MUKArrayDeltaMatch *movement in orderedMovements) {
        NSUInteger const sourceIndex = [delta intermediateDestinationIndexForMovement:movement];

        if (movement.type == MUKArrayDeltaMatchTypeChange) {
            [changedIndexes addIndex:sourceIndex];
            [changedIndexes addIndex:movement.destinationIndex];
        }
        else {
            [tableView moveSection:sourceIndex toSection:movement.destinationIndex];
        }
    } // for
    
    [tableView beginUpdates];

    for (MUKArrayDeltaMatch *change in self.sectionsDelta.changes) {
        [changedIndexes addIndex:change.destinationIndex];
    } // for
    
    [tableView reloadSections:changedIndexes withRowAnimation:animation];
    
    [tableView endUpdates];
    */

                                                                                             
    
    /*
    [tableView beginUpdates];
    [tableView insertSections:self.sectionsDelta.insertedIndexes withRowAnimation:animation];
    [tableView deleteSections:self.sectionsDelta.deletedIndexes withRowAnimation:animation];
    [tableView endUpdates];
    
    [tableView beginUpdates];
    for (MUKArrayDeltaMovement *movement in self.sectionsDelta.movements) {
        NSUInteger const sourceIndex = movement.sourceIndex + [self.sectionsDelta.insertedIndexes countOfIndexesInRange:NSMakeRange(0, movement.sourceIndex)] - [self.sectionsDelta.deletedIndexes countOfIndexesInRange:NSMakeRange(0, movement.sourceIndex)];
        NSUInteger const destinationIndex = movement.destinationIndex;
        
        [tableView moveSection:sourceIndex toSection:destinationIndex];
    } // for
    [tableView endUpdates];
    
    [tableView beginUpdates];
    [self.sectionsDelta.changedIndexes enumerateIndexesUsingBlock:^(NSUInteger changedIndex, BOOL *stop)
    {
        NSUInteger const destinationIndex = changedIndex + [self.sectionsDelta.insertedIndexes countOfIndexesInRange:NSMakeRange(0, changedIndex)] - [self.sectionsDelta.deletedIndexes countOfIndexesInRange:NSMakeRange(0, changedIndex)];
    }];
    [tableView endUpdates];
*/
    
    /*
    NSMutableIndexSet *changedIndexes = [self.sectionsDelta.changedIndexes mutableCopy];

    [tableView beginUpdates];
    
    for (MUKArrayDeltaMovement *movement in self.sectionsDelta.movements) {
        BOOL movementAborted = NO;
        
        NSInteger const normalizedDestinationIndex = movement.destinationIndex - [self.sectionsDelta.insertedIndexes countOfIndexesInRange:NSMakeRange(0, movement.destinationIndex)] + [self.sectionsDelta.deletedIndexes countOfIndexesInRange:NSMakeRange(0, movement.destinationIndex)];
        
        if ([changedIndexes containsIndex:movement.sourceIndex] ||
            [changedIndexes containsIndex:normalizedDestinationIndex])
        {
            movementAborted = YES;
            [changedIndexes addIndex:movement.sourceIndex];
            [changedIndexes addIndex:normalizedDestinationIndex];
        }
        
        if (!movementAborted) {
            [tableView moveSection:movement.sourceIndex toSection:movement.destinationIndex];
        }
    } // for
    
    
    
    
    
    [tableView insertSections:self.sectionsDelta.insertedIndexes withRowAnimation:animation];
    [tableView deleteSections:self.sectionsDelta.deletedIndexes withRowAnimation:animation];
    
    [changedIndexes removeIndexes:self.sectionsDelta.insertedIndexes];
    [changedIndexes removeIndexes:self.sectionsDelta.deletedIndexes];
    [tableView reloadSections:changedIndexes withRowAnimation:animated];
    
    [tableView endUpdates];
     */
}

@end
