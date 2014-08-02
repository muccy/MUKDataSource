#import "MUKDataSource+TableView.h"
#import "MUKDataSource_Private.h"

@interface MUKDataSource (TableView_Private)
@property (nonatomic, readonly) MUKDataSource *tableViewDataSource;
@end

@implementation MUKDataSource (TableView_Private)
@dynamic tableViewDataSource;

- (MUKDataSource *)tableViewDataSource {
    MUKDataSource *dataSource;
    
    if (self.hasChildDataSources && !self.items) {
        // I contain sections
        dataSource = self;
    }
    else if (self.items && self.parentDataSource && !self.parentDataSource.items)
    {
        // I contain rows and my dad contains sections
        dataSource = self.parentDataSource;
    }
    else if (self.items) {
        // I contain rows and I have not a dad (mono-section)
        dataSource = self;
    }
    else {
        dataSource = nil;
    }
    
    return dataSource;
}

@end

@implementation MUKDataSource (TableView)

- (NSInteger)childDataSourceIndexFromTableViewSection:(NSInteger)section checkingBounds:(BOOL)checkBounds
{
    if (checkBounds && (section < 0 || section >= [self.childDataSources count]))
    {
        return NSNotFound;
    }
    
    return section;
}

- (NSInteger)itemIndexFromTableViewRow:(NSInteger)row checkingBounds:(BOOL)checkBounds
{
    if (checkBounds && (row < 0 || row >= [self.items count])) {
        return NSNotFound;
    }
    
    return row;
}

- (NSIndexPath *)itemIndexPathFromTableViewIndexPath:(NSIndexPath *)tableIndexPath checkingBounds:(BOOL)checkBounds
{
    MUKDataSource *const tableViewDataSource = self.tableViewDataSource;
    if (!tableViewDataSource) {
        return nil;
    }
    
    // Get section
    NSInteger section;
    MUKDataSource *sectionDataSource;
    if (tableViewDataSource.hasChildDataSources) {
        section = [tableViewDataSource childDataSourceIndexFromTableViewSection:tableIndexPath.section checkingBounds:checkBounds];
        sectionDataSource = [tableViewDataSource childDataSourceAtIndex:section];
    }
    else {
        section = 0; // Mono-section
        sectionDataSource = self;
    }
    
    if (section == NSNotFound || !sectionDataSource) {
        return nil;
    }
    
    // Get row
    NSInteger row = [sectionDataSource itemIndexFromTableViewRow:tableIndexPath.row checkingBounds:checkBounds];
    
    if (row == NSNotFound) {
        return nil;
    }
    
    // Compose index path
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (NSIndexPath *)tableViewIndexPathFromItemIndex:(NSInteger)itemIndex checkingBounds:(BOOL)checkBounds
{
    if (checkBounds && (itemIndex < 0 || itemIndex >= [self.items count])) {
        return nil;
    }
    
    MUKDataSource *const tableViewDataSource = self.tableViewDataSource;
    if (!tableViewDataSource) {
        return nil;
    }
    
    NSInteger dataSourceIndex = tableViewDataSource == self ? 0 : [tableViewDataSource.childDataSources indexOfObject:self];
    if (dataSourceIndex == NSNotFound) {
        return nil;
    }
    
    return [NSIndexPath indexPathForRow:itemIndex inSection:dataSourceIndex];
}

- (NSArray *)tableViewIndexPathsFromItemIndexes:(NSArray *)itemIndexes checkingBounds:(BOOL)checkBounds
{
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    for (NSNumber *itemIndexNumber in itemIndexes) {
        NSIndexPath *indexPath = [self tableViewIndexPathFromItemIndex:[itemIndexNumber integerValue] checkingBounds:checkBounds];
        
        if (indexPath) {
            [indexPaths addObject:indexPath];
        }
    } // for
    
    return [indexPaths copy];
}

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
                [self removeItemAtIndex:itemIndex eventOrigin:MUKDataSourceEventOriginUserInteraction];
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
        MUKDataSource *const destinationDataSource = [self.tableViewDataSource childDataSourceForTableViewSection:destinationIndexPath.section] ?: self;

        NSInteger const sourceIndex = [self itemIndexFromTableViewRow:sourceIndexPath.row checkingBounds:YES];
        NSInteger const destinationIndex = sourceDataSource != destinationDataSource ? [destinationDataSource itemIndexFromTableViewRow:destinationIndexPath.row checkingBounds:NO] : [destinationDataSource itemIndexFromTableViewRow:destinationIndexPath.row checkingBounds:YES];
        
        if (sourceIndex != NSNotFound && destinationIndex != NSNotFound) {
            [sourceDataSource moveItemAtIndex:sourceIndex toDataSource:destinationDataSource atIndex:destinationIndex eventOrigin:MUKDataSourceEventOriginUserInteraction];
        }
    }
}

@end
