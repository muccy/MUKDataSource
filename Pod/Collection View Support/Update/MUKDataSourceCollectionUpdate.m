//
//  MUKDataSourceCollectionUpdate.m
//  
//
//  Created by Marco on 16/06/15.
//
//

#import "MUKDataSourceCollectionUpdate.h"
#import "MUKDataSourceCollectionSection.h"
#import <MUKArrayDelta/MUKArrayDelta.h>

static MUKDataSourceContentSectionMovement *MovementWithDestinationIndex(NSUInteger idx, NSSet *movements)
{
    for (MUKDataSourceContentSectionMovement *movement in movements) {
        if (movement.destinationIndex == idx) {
            return movement;
        }
    } // for
    
    return nil;
}

static MUKDataSourceContentSectionMovement *MovementWithSourceIndex(NSUInteger idx, NSSet *movements)
{
    for (MUKDataSourceContentSectionMovement *movement in movements) {
        if (movement.sourceIndex == idx) {
            return movement;
        }
    } // for
    
    return nil;
}

@implementation MUKDataSourceCollectionUpdate

- (instancetype)initWithSourceSections:(NSArray *)sourceSections destinationSections:(NSArray *)destinationSections
{
    self = [super initWithSourceSections:sourceSections destinationSections:destinationSections];
    if (self) {
        // Unfortunately there are case when -reloadData is compulsory (also for
        // some unresolved bugs in UICollectionView)
        if ([self needsToForceReloadData]) {
            _needsReloadData = YES;
        }
    }
    
    return self;
}

- (void)applyToCollectionView:(UICollectionView *)collectionView completion:(void (^)(BOOL))completionHandler
{
    if (self.needsReloadData) {
        [collectionView reloadData];
        
        if (completionHandler) {
            completionHandler(YES);
        }
        
        return;
    }
    
    [collectionView performBatchUpdates:^{
        [collectionView insertSections:self.insertedSectionIndexes];
        [collectionView deleteSections:self.deletedSectionIndexes];

        for (MUKDataSourceContentSectionMovement *movement in self.sectionMovements)
        {
            [collectionView moveSection:movement.sourceIndex toSection:movement.destinationIndex];
        } // for
        
        [collectionView insertItemsAtIndexPaths:[self.insertedItemIndexPaths allObjects]];
        [collectionView deleteItemsAtIndexPaths:[self.deletedItemIndexPaths allObjects]];

        for (MUKDataSourceContentSectionItemMovement *movement in self.itemMovements)
        {
            [collectionView moveItemAtIndexPath:movement.sourceIndexPath toIndexPath:movement.destinationIndexPath];
        } // for
    } completion:^(BOOL finished) {
        [collectionView performBatchUpdates:^{
            [collectionView reloadSections:self.reloadedSectionIndexes];
            [collectionView reloadItemsAtIndexPaths:[self.reloadedItemIndexPaths allObjects]];
        } completion:completionHandler];
    }];
}

#pragma mark - Overrides

/*
 I reload destination indexes because collection views don't like to move
 a section which is reloaded.
 If you reload a section index which is a source index of a movement, table
 will throw a "attempt to perform a delete and a move from the same section".
 If you reload a section index which is a destionation index of a movement, table
 will throw a "attempt to perform an insert and a move to the same section".
 
 To solve this problem I break update into two block of updates:
 1) insertion+deletion+move
 2) reload
 */

- (NSIndexPath *)reloadedItemIndexPathForDelta:(MUKArrayDelta *)delta change:(MUKArrayDeltaMatch *)change sectionMatch:(MUKArrayDeltaMatch *)sectionMatch
{
    return [NSIndexPath indexPathForRow:change.destinationIndex inSection:sectionMatch.destinationIndex];
}

#pragma mark - Private

- (BOOL)needsToForceReloadData {
    // Insert an item in a moved section (wrong update)
    for (NSIndexPath *indexPath in self.insertedItemIndexPaths) {
        if (MovementWithDestinationIndex(indexPath.section, self.sectionMovements))
        {
            return YES;
        } // if
    } // for
    
    // Delete an item in a moved section (collection view freezes)
    for (NSIndexPath *indexPath in self.deletedItemIndexPaths) {
        if (MovementWithSourceIndex(indexPath.section, self.sectionMovements))
        {
            return YES;
        } // if
    } // for
    
    // Move a row to a moved section (sometimes causes EXC_BAD_ACCESS)
    for (MUKDataSourceContentSectionItemMovement *itemMovement in self.itemMovements) {
        if (MovementWithDestinationIndex(itemMovement.destinationIndexPath.section, self.sectionMovements))
        {
            // Throws "-[__NSArrayM insertObject:atIndex:]: object cannot be nil"
            // when you m
            return YES;
        }
    } // for
    
    return NO;
}

@end
