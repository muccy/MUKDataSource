#import "MUKDataSourceTableUpdate.h"
#import "MUKDataSourceTableSection.h"
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

@implementation MUKDataSourceTableUpdate

- (instancetype)initWithSourceSections:(NSArray *)sourceSections destinationSections:(NSArray *)destinationSections
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

- (void)applyToTableView:(UITableView *)tableView animated:(BOOL)animated {
    if (self.needsReloadData) {
        [tableView reloadData];
        return;
    }
    
    if (self.isEmpty) {
        return;
    }
    
    UITableViewRowAnimation const animation = animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone;
    
    [tableView beginUpdates];
    {
        [tableView insertSections:self.insertedSectionIndexes withRowAnimation:animation];
        [tableView deleteSections:self.deletedSectionIndexes withRowAnimation:animation];
        
        for (MUKDataSourceContentSectionMovement *movement in self.sectionMovements)
        {
            [tableView moveSection:movement.sourceIndex toSection:movement.destinationIndex];
        } // for
        
        [tableView insertRowsAtIndexPaths:[self.insertedItemIndexPaths allObjects] withRowAnimation:animation];
        [tableView deleteRowsAtIndexPaths:[self.deletedItemIndexPaths allObjects] withRowAnimation:animation];
        
        for (MUKDataSourceContentSectionItemMovement *movement in self.itemMovements)
        {
            [tableView moveRowAtIndexPath:movement.sourceIndexPath toIndexPath:movement.destinationIndexPath];
        } // for
    }
    [tableView endUpdates];
    
    [tableView beginUpdates];
    {
        [self reloadTableView:tableView sectionsAtIndexes:self.reloadedSectionIndexes animated:animated];
        [self reloadTableView:tableView rowsAtIndexPaths:self.reloadedItemIndexPaths animated:animated];
    }
    [tableView endUpdates];
}

- (void)reloadTableView:(UITableView *)tableView sectionsAtIndexes:(NSIndexSet *)indexes animated:(BOOL)animated
{
    UITableViewRowAnimation const animation = animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone;
    [tableView reloadSections:indexes withRowAnimation:animation];
}

- (void)reloadTableView:(UITableView *)tableView rowsAtIndexPaths:(NSSet *)indexPaths animated:(BOOL)animated
{
    UITableViewRowAnimation const animation = animated ? UITableViewRowAnimationAutomatic : UITableViewRowAnimationNone;
    [tableView reloadRowsAtIndexPaths:[indexPaths allObjects] withRowAnimation:animation];
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
    MUKDataSourceTableSection *const sourceSection = delta.sourceArray[change.sourceIndex];
    MUKDataSourceTableSection *const destinationSection = delta.destinationArray[change.destinationIndex];
    
    BOOL const sameHeaderTitle = (!destinationSection.headerTitle && !sourceSection.headerTitle) || [destinationSection.headerTitle isEqualToString:sourceSection.headerTitle];
    BOOL const sameFooterTitle = (!destinationSection.footerTitle && !sourceSection.footerTitle) || [destinationSection.footerTitle isEqualToString:sourceSection.footerTitle];
    BOOL const shouldReload = !sameHeaderTitle || !sameFooterTitle;
    
    if (shouldReload) {
        return change.destinationIndex;
    }
    
    return NSNotFound;
}

- (NSIndexPath *)reloadedItemIndexPathForDelta:(MUKArrayDelta *)delta change:(MUKArrayDeltaMatch *)change sectionMatch:(MUKArrayDeltaMatch *)sectionMatch
{
    return [NSIndexPath indexPathForRow:change.destinationIndex inSection:sectionMatch.destinationIndex];
}

#pragma mark - Private

- (BOOL)needsToForceReloadData {
    for (NSIndexPath *indexPath in self.insertedItemIndexPaths) {
        if (MovementWithDestinationIndex(indexPath.section, self.sectionMovements))
        {
            // Throws "-[__NSArrayM insertObject:atIndex:]: object cannot be nil"
            // when you insert a row in a moved section
            return YES;
        } // if
    } // for
    
    for (NSIndexPath *indexPath in self.deletedItemIndexPaths) {
        if (MovementWithSourceIndex(indexPath.section, self.sectionMovements))
        {
            // Throws "-[__NSArrayM insertObject:atIndex:]: object cannot be nil"
            // when you delete a row in a moved section
            return YES;
        } // if
    } // for
    
    for (MUKDataSourceContentSectionItemMovement *itemMovement in self.itemMovements) {
        if (MovementWithDestinationIndex(itemMovement.destinationIndexPath.section, self.sectionMovements))
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
