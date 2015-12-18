#import "MUKDataSourceCollectionUpdate.h"
#import <MUKArrayDelta/MUKArrayDelta.h>

static MUKDataSourceContentSectionMovement *MovementWithDestinationIndex(NSUInteger idx, NSSet<MUKDataSourceContentSectionMovement *> *movements)
{
    for (MUKDataSourceContentSectionMovement *movement in movements) {
        if (movement.destinationIndex == idx) {
            return movement;
        }
    } // for
    
    return nil;
}

static MUKDataSourceContentSectionMovement *MovementWithSourceIndex(NSUInteger idx, NSSet<MUKDataSourceContentSectionMovement *> *movements)
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

- (void)applyToCollectionView:(UICollectionView *)collectionView completion:(void (^ _Nullable)(BOOL finished))completionHandler
{
    if (self.needsReloadData) {
        [collectionView reloadData];
        
        if (completionHandler) {
            completionHandler(YES);
        }
        
        return;
    }
    
    if (self.isEmpty) {
        return;
    }
    
    @try {
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
                [self reloadCollectionView:collectionView sectionsAtIndexes:self.reloadedSectionIndexes];
                [self reloadCollectionView:collectionView itemsAtIndexPaths:self.reloadedItemIndexPaths];
            } completion:completionHandler];
        }];
    }
    @catch (NSException *exception) {
        // Build a more explainatory exception
        [NSException raise:MUKDataSourceSectionedContentUpdateException format:@"Collection view exception: %@ ('%@')\n\nUpdate description:\n%@", exception.name, exception.reason, self.prettyDescription];
    }
}

- (void)reloadCollectionView:(UICollectionView *)collectionView sectionsAtIndexes:(NSIndexSet *)indexes
{
    [collectionView reloadSections:indexes];
}

- (void)reloadCollectionView:(UICollectionView *)collectionView itemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    [collectionView reloadItemsAtIndexPaths:indexPaths.allObjects];
}

#pragma mark - Overrides

/*
 I reload destination indexes because collection views don't like to move
 a section which is reloaded.

 To solve this problem I break update into two block of updates:
 1) insertion+deletion+move
 2) reload
 */

- (NSUInteger)reloadedSectionIndexForDelta:(MUKArrayDelta *)delta change:(MUKArrayDeltaMatch *)change
{
    NSUInteger const idx = [super reloadedSectionIndexForDelta:delta change:change];
    if (idx != NSNotFound) {
        return change.destinationIndex;
    }
    
    return idx;
}

- (NSIndexPath *)reloadedItemIndexPathForDelta:(MUKArrayDelta *)delta change:(MUKArrayDeltaMatch *)change sectionMatch:(MUKArrayDeltaMatch *)sectionMatch
{
    NSIndexPath *const indexPath = [super reloadedItemIndexPathForDelta:delta change:change sectionMatch:sectionMatch];
    if (indexPath) {
        return [NSIndexPath indexPathForRow:change.destinationIndex inSection:sectionMatch.destinationIndex];
    }
    
    return indexPath;
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
            return YES;
        }
    } // for
    
    return NO;
}

@end
