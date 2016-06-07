#import "MUKDataSourceTableUpdate.h"
#import <MUKArrayDelta/MUKArrayDelta.h>

static MUKDataSourceContentSectionMovement *SectionMovementWithDestinationIndex(NSUInteger idx, NSSet<MUKDataSourceContentSectionMovement *> *movements)
{
    for (MUKDataSourceContentSectionMovement *movement in movements) {
        if (movement.destinationIndex == idx) {
            return movement;
        }
    } // for
    
    return nil;
}

static MUKDataSourceContentSectionMovement *SectionMovementWithSourceIndex(NSUInteger idx, NSSet<MUKDataSourceContentSectionMovement *> *movements)
{
    for (MUKDataSourceContentSectionMovement *movement in movements) {
        if (movement.sourceIndex == idx) {
            return movement;
        }
    } // for
    
    return nil;
}

static MUKDataSourceContentSectionItemMovement *ItemMovementWithDestinationIndexPath(NSIndexPath *indexPath, NSSet<MUKDataSourceContentSectionItemMovement *> *movements)
{
    for (MUKDataSourceContentSectionItemMovement *movement in movements) {
        if ([movement.destinationIndexPath isEqual:indexPath]) {
            return movement;
        }
    } // for
    
    return nil;
}

@implementation MUKDataSourceTableUpdate

- (instancetype)initWithSourceSections:(NSArray<MUKDataSourceContentSection *> *)sourceSections destinationSections:(NSArray<MUKDataSourceContentSection *> *)destinationSections
{
    self = [super initWithSourceSections:sourceSections destinationSections:destinationSections];
    if (self) {
        // Unfortunately there are case when -reloadData is compulsory (also for
        // some unresolved bugs in UITableView)
        if ([self needsToForceReloadData]) {
            _needsReloadData = YES;
        }
    }
    
    return self;
}

- (void)applyToTableView:(UITableView *)tableView withAnimation:(MUKDataSourceTableUpdateAnimation * __nullable)animation
{
    if (self.needsReloadData || !animation) {
        [tableView reloadData];
        return;
    }
    
    if (self.isEmpty) {
        return;
    }
    
    @try {
        [tableView beginUpdates];
        {
            [tableView insertSections:self.insertedSectionIndexes withRowAnimation:animation.sectionsInsertionAnimation];
            [tableView deleteSections:self.deletedSectionIndexes withRowAnimation:animation.sectionsDeletionAnimation];
            
            for (MUKDataSourceContentSectionMovement *movement in self.sectionMovements)
            {
                [tableView moveSection:movement.sourceIndex toSection:movement.destinationIndex];
            } // for
            
            [tableView insertRowsAtIndexPaths:[self.insertedItemIndexPaths allObjects] withRowAnimation:animation.rowsInsertionAnimation];
            [tableView deleteRowsAtIndexPaths:[self.deletedItemIndexPaths allObjects] withRowAnimation:animation.rowsDeletionAnimation];
            
            for (MUKDataSourceContentSectionItemMovement *movement in self.itemMovements)
            {
                [tableView moveRowAtIndexPath:movement.sourceIndexPath toIndexPath:movement.destinationIndexPath];
            } // for
        }
        [tableView endUpdates];
        
        [tableView beginUpdates];
        {
            [self reloadTableView:tableView sectionsAtIndexes:self.reloadedSectionIndexes withRowAnimation:animation.sectionsReloadAnimation];
            [self reloadTableView:tableView rowsAtIndexPaths:self.reloadedItemIndexPaths withRowAnimation:animation.rowsReloadAnimation];
        }
        [tableView endUpdates];
    }
    @catch (NSException *exception) {
        // Build a more explainatory exception
        [NSException raise:MUKDataSourceSectionedContentUpdateException format:@"Table view exception: %@ ('%@')\n\nUpdate description:\n%@", exception.name, exception.reason, self.prettyDescription];
    }
}

- (void)reloadTableView:(UITableView *)tableView sectionsAtIndexes:(NSIndexSet *)indexes withRowAnimation:(UITableViewRowAnimation)animation
{
    [tableView reloadSections:indexes withRowAnimation:animation];
}

- (void)reloadTableView:(UITableView *)tableView rowsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [tableView reloadRowsAtIndexPaths:indexPaths.allObjects withRowAnimation:animation];
}

#pragma mark Overrides

/*
 I reload destination indexes because table views don't like to move
 a section which is reloaded.
 If you reload a section index which is a source index of a movement, table
 will throw a "attempt to perform a delete and a move from the same section".
 If you reload a section index which is a destionation index of a movement, table
 will throw a "attempt to perform an insert and a move to the same section".
 
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
    for (NSIndexPath *indexPath in self.insertedItemIndexPaths) {
        if (SectionMovementWithDestinationIndex(indexPath.section, self.sectionMovements))
        {
            // Throws "-[__NSArrayM insertObject:atIndex:]: object cannot be nil"
            // when you insert a row in a moved section
            return YES;
        } // if
    } // for
    
    for (NSIndexPath *indexPath in self.deletedItemIndexPaths) {
        if (SectionMovementWithSourceIndex(indexPath.section, self.sectionMovements))
        {
            // Throws "-[__NSArrayM insertObject:atIndex:]: object cannot be nil"
            // when you delete a row in a moved section
            return YES;
        } // if
    } // for
    
    for (MUKDataSourceContentSectionItemMovement *itemMovement in self.itemMovements) {
        if (SectionMovementWithDestinationIndex(itemMovement.destinationIndexPath.section, self.sectionMovements))
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
