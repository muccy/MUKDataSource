#import "MUKDataSource+TableView.h"
#import "MUKDataSource_Private.h"

@implementation MUKDataSource (TableView_Conversions)

- (NSInteger)childDataSourceIndexFromTableViewSection:(NSInteger)section checkingBounds:(BOOL)checkBounds
{
    NSInteger childDataSourceIndex = section;
    
    if (checkBounds && (childDataSourceIndex < 0 || childDataSourceIndex >= [self.childDataSources count]))
    {
        return NSNotFound;
    }
    
    return childDataSourceIndex;
}

- (NSInteger)itemIndexFromTableViewRow:(NSInteger)row checkingBounds:(BOOL)checkBounds
{
    NSInteger itemIndex = row;
    
    if (checkBounds && (itemIndex < 0 || itemIndex >= [self.items count])) {
        return NSNotFound;
    }
    
    return itemIndex;
}

- (NSIndexPath *)itemIndexPathFromTableViewIndexPath:(NSIndexPath *)tableIndexPath checkingBounds:(BOOL)checkBounds
{
    NSInteger const childDataSourceIndex = [self childDataSourceIndexFromTableViewSection:tableIndexPath.section checkingBounds:checkBounds];
    if (childDataSourceIndex == NSNotFound) {
        return nil;
    }
    
    MUKDataSource *const itemsDataSource = [self childDataSourceAtIndex:childDataSourceIndex] ?: self;
    NSInteger const itemIndex = [itemsDataSource itemIndexFromTableViewRow:tableIndexPath.row checkingBounds:checkBounds];
    if (itemIndex == NSNotFound) {
        return nil;
    }
    
    NSUInteger const indexes[2] = { (NSUInteger)childDataSourceIndex, (NSUInteger)itemIndex };
    return [NSIndexPath indexPathWithIndexes:indexes length:2];
}

- (NSInteger)tableViewSectionFromChildDataSourceIndex:(NSInteger)childDataSourceIndex checkingBounds:(BOOL)checkBounds
{
    if (checkBounds && (childDataSourceIndex < 0 || childDataSourceIndex >= [self.childDataSources count]))
    {
        return NSNotFound;
    }
    
    return childDataSourceIndex;
}

- (NSIndexSet *)tableViewSectionsFromChildDataSourceIndexes:(NSIndexSet *)childDataSourceIndexes checkingBounds:(BOOL)checkBounds
{
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    
    [childDataSourceIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop)
    {
        NSInteger section = [self tableViewSectionFromChildDataSourceIndex:idx checkingBounds:checkBounds];
        
        if (section != NSNotFound) {
            [indexSet addIndex:section];
        }
    }];
    
    return [indexSet copy];
}

- (NSInteger)tableViewRowFromItemIndex:(NSInteger)itemIndex checkingBounds:(BOOL)checkBounds
{
    if (checkBounds && (itemIndex < 0 || itemIndex >= [self.items count])) {
        return NSNotFound;
    }
    
    return itemIndex;
}

- (NSIndexPath *)tableViewIndexPathFromItemIndexPath:(NSIndexPath *)itemIndexPath checkingBounds:(BOOL)checkBounds
{
    NSInteger const childDataSourceIndex = [itemIndexPath indexAtPosition:0];
    NSInteger const section = [self tableViewSectionFromChildDataSourceIndex:childDataSourceIndex checkingBounds:checkBounds];
    if (section == NSNotFound) {
        return nil;
    }
    
    MUKDataSource *const itemsDataSource = [self childDataSourceAtIndex:childDataSourceIndex] ?: self;
    NSInteger const itemIndex = [itemIndexPath indexAtPosition:1];
    NSInteger const row = [itemsDataSource tableViewRowFromItemIndex:itemIndex checkingBounds:checkBounds];
    if (row == NSNotFound) {
        return nil;
    }

    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (NSIndexPath *)tableViewIndexPathFromItemIndex:(NSInteger)itemIndex checkingBounds:(BOOL)checkBounds
{
    NSUInteger const indexes[2] = { [self.parentDataSource.childDataSources indexOfObject:self], itemIndex };
    NSIndexPath *const itemIndexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
    return [self.parentDataSource tableViewIndexPathFromItemIndexPath:itemIndexPath checkingBounds:checkBounds];
}

- (NSArray *)tableViewIndexPathsFromItemIndexes:(NSIndexSet *)itemIndexes checkingBounds:(BOOL)checkBounds
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    [itemIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [self tableViewIndexPathFromItemIndex:idx checkingBounds:checkBounds];
        
        if (indexPath) {
            [indexPaths addObject:indexPath];
        }
    }];
 
    return [indexPaths copy];
}

@end

@implementation MUKDataSource (TableView)

- (NSInteger)numberOfRowsForSection:(NSInteger)section inTableView:(UITableView *)tableView
{
    return [self.items count];
}

- (void)registerReusableViewsForTableView:(UITableView *)tableView {
    for (MUKDataSource *childDataSource in self.childDataSources) {
        [childDataSource registerReusableViewsForTableView:tableView];
    } // for
}

- (UITableViewCell *)dequeueOrCreateCellForRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    return nil;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    //
}

- (NSString *)titleForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView
{
    return self.title;
}

- (NSString *)titleForFooterInSection:(NSInteger)section tableView:(UITableView *)tableView
{
    return nil;
}

- (BOOL)canEditRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    return NO;
}

- (BOOL)canMoveRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    return NO;
}

- (id)newItemToInsertByCommittingRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    return nil;
}

- (NSInteger)destinationIndexForItem:(id)item toInsertByCommittingRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    return [self.items count];
}

#pragma mark - Private

- (MUKDataSource *)childDataSourceForTableViewSection:(NSInteger)section {
    NSInteger idx = [self childDataSourceIndexFromTableViewSection:section checkingBounds:YES];
    return [self childDataSourceAtIndex:idx];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.childDataSources count] ?: 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count;
    
    MUKDataSource *const childDataSource = [self childDataSourceForTableViewSection:section];
    if (childDataSource) {
        count = [childDataSource tableView:tableView numberOfRowsInSection:section];
    }
    else {
        count = [self numberOfRowsForSection:section inTableView:tableView];
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    MUKDataSource *const childDataSource = [self childDataSourceForTableViewSection:indexPath.section];
    if (childDataSource) {
        cell = [childDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    else {
        cell = [self dequeueOrCreateCellForRowAtIndexPath:indexPath inTableView:tableView];
        [self configureCell:cell forRowAtIndexPath:indexPath inTableView:tableView];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    
    MUKDataSource *const childDataSource = [self childDataSourceForTableViewSection:section];
    if (childDataSource) {
        title = [childDataSource tableView:tableView titleForHeaderInSection:section];
    }
    else {
        title = [self titleForHeaderInSection:section tableView:tableView];
    }
    
    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title;
    
    MUKDataSource *const childDataSource = [self childDataSourceForTableViewSection:section];
    if (childDataSource) {
        title = [childDataSource tableView:tableView titleForFooterInSection:section];
    }
    else {
        title = [self titleForFooterInSection:section tableView:tableView];
    }
    
    return title;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canEdit;
    
    MUKDataSource *const childDataSource = [self childDataSourceForTableViewSection:indexPath.section];
    if (childDataSource) {
        canEdit = [childDataSource tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    else {
        canEdit = [self canEditRowAtIndexPath:indexPath inTableView:tableView];
    }
    
    return canEdit;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canMove;
    
    MUKDataSource *const childDataSource = [self childDataSourceForTableViewSection:indexPath.section];
    if (childDataSource) {
        canMove = [childDataSource tableView:tableView canMoveRowAtIndexPath:indexPath];
    }
    else {
        canMove = [self canMoveRowAtIndexPath:indexPath inTableView:tableView];
    }
    
    return canMove;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([self childDataSourceForTableViewSection:index]) {
        return index;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MUKDataSource *const childDataSource = [self childDataSourceForTableViewSection:indexPath.section];
    
    if (childDataSource) {
        [childDataSource tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
    else {
        if (UITableViewCellEditingStyleDelete == editingStyle) {
            NSInteger itemIndex = [self itemIndexFromTableViewRow:indexPath.row checkingBounds:YES];
            if (itemIndex != NSNotFound) {
                [self removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:itemIndex] eventOrigin:MUKDataSourceEventOriginUserInteraction];
            }
        }
        else if (UITableViewCellEditingStyleInsert == editingStyle) {
            id newItem = [self newItemToInsertByCommittingRowAtIndexPath:indexPath inTableView:tableView];
            
            if (newItem) {
                NSInteger idx = [self destinationIndexForItem:newItem toInsertByCommittingRowAtIndexPath:indexPath inTableView:tableView];
                
                if (idx != NSNotFound) {
                    [self insertItems:@[newItem] atIndexes:[NSIndexSet indexSetWithIndex:idx] eventOrigin:MUKDataSourceEventOriginUserInteraction];
                }
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    MUKDataSource *const childSourceDataSource = [self childDataSourceForTableViewSection:sourceIndexPath.section];
    
    if (childSourceDataSource) {
        [childSourceDataSource tableView:tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
    else {
        MUKDataSource *const sourceDataSource = self;
        MUKDataSource *const destinationDataSource = [self.parentDataSource childDataSourceForTableViewSection:destinationIndexPath.section] ?: self;

        NSInteger const sourceIndex = [self itemIndexFromTableViewRow:sourceIndexPath.row checkingBounds:YES];
        NSInteger const destinationIndex = sourceDataSource != destinationDataSource ? [destinationDataSource itemIndexFromTableViewRow:destinationIndexPath.row checkingBounds:NO] : [destinationDataSource itemIndexFromTableViewRow:destinationIndexPath.row checkingBounds:YES];
        
        if (sourceIndex != NSNotFound && destinationIndex != NSNotFound) {
            [sourceDataSource moveItemAtIndex:sourceIndex toDataSource:destinationDataSource atIndex:destinationIndex eventOrigin:MUKDataSourceEventOriginUserInteraction];
        }
    }
}

@end
