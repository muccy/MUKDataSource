#import "MUKDataSource_Main.h"

@interface MUKDataSource ()
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, readwrite) NSArray *childDataSources;
@property (nonatomic, weak, readwrite) MUKDataSource *parentDataSource;
@end

@implementation MUKDataSource

#pragma mark - Contents

- (id)itemAtIndex:(NSInteger)idx {
    if (idx < 0 || idx >= [self.items count]) {
        return nil;
    }
    
    return self.items[idx];
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return [self itemAtIndexPath:indexPath usingIndexAtPosition:0];
}

- (void)moveItemAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex
{
    if (self == destinationDataSource) {
        // Simple swap
        NSMutableArray *items = [self.items mutableCopy];
        [items exchangeObjectAtIndex:sourceIndex withObjectAtIndex:destinationIndex];
        self.items = [items copy];
    }
    else {
        NSMutableArray *items = [self.items mutableCopy];
        id item = items[sourceIndex];
        [items removeObjectAtIndex:sourceIndex];
        
        NSMutableArray *destinationItems = [destinationDataSource.items mutableCopy];
        [destinationItems insertObject:item atIndex:destinationIndex];
        
        self.items = [items copy];
        destinationDataSource.items = [destinationItems copy];
    }
    
    // Notify to parent
    [self.parentDataSource childDataSource:self didMoveItemAtIndex:sourceIndex toDataSource:destinationDataSource atIndex:destinationIndex];
}

#pragma mark - Containment

- (void)addChildDataSource:(MUKDataSource *)dataSource {
    if (!dataSource) {
        return;
    }
    
    // Create if still nil
    NSArray *childDataSources = self.childDataSources ?: [NSArray array];
    
    // No duplicates
    if ([childDataSources indexOfObject:dataSource] != NSNotFound) {
        return;
    }
    
    dataSource.parentDataSource = self;
    self.childDataSources = [childDataSources arrayByAddingObject:dataSource];
}

- (void)removeDataSource:(MUKDataSource *)dataSource {
    if (!dataSource || !self.childDataSources) {
        return;
    }
    
    NSMutableArray *childDataSources = [self.childDataSources mutableCopy];
    [childDataSources removeObject:dataSource];
    self.childDataSources = [childDataSources copy];
    
    if (dataSource.parentDataSource == self) {
        dataSource.parentDataSource = nil;
    }
}

#pragma mark - Child Callbacks

- (void)childDataSource:(MUKDataSource *)sourceDataSource didMoveItemAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex
{
    // Forward up
    [self.parentDataSource childDataSource:sourceDataSource didMoveItemAtIndex:sourceIndex toDataSource:destinationDataSource atIndex:destinationIndex];
}

#pragma mark - Table View

- (NSInteger)numberOfRowsForTableView:(UITableView *)tableView inSection:(NSInteger)section
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

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
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

#pragma mark - Private - Contents

- (id)itemAtIndexPath:(NSIndexPath *)indexPath usingIndexAtPosition:(NSUInteger)position
{
    if (!indexPath || position >= indexPath.length) {
        return nil;
    }
    
    NSUInteger const idx = [indexPath indexAtPosition:position];
    BOOL const lastAvailablePosition = position == indexPath.length - 1;
    
    id item;
    if (lastAvailablePosition) {
        item = [self itemAtIndex:idx];
    }
    else {
        item = [[self childDataSourceAtIndex:idx] itemAtIndexPath:indexPath usingIndexAtPosition:position+1];
    }
    
    return item;
}

#pragma mark - Private - Containment

- (BOOL)hasChildDataSources {
    return [self.childDataSources count] > 0;
}

- (MUKDataSource *)childDataSourceAtIndex:(NSInteger)idx {
    if (idx < 0 || idx >= [self.childDataSources count]) {
        return nil;
    }
    
    return self.childDataSources[idx];
}

- (MUKDataSource *)childDataSourceForTableViewSection:(NSInteger)idx {
    return [self childDataSourceAtIndex:idx];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self hasChildDataSources] ? [self.childDataSources count] : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count;
    
    if ([self hasChildDataSources]) {
        count = [[self childDataSourceForTableViewSection:section] tableView:tableView numberOfRowsInSection:section];
    }
    else {
        count = [self numberOfRowsForTableView:tableView inSection:section];
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self dequeueOrCreateCellForRowAtIndexPath:indexPath inTableView:tableView];
    [self configureCell:cell forRowAtIndexPath:indexPath inTableView:tableView];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    if ([self hasChildDataSources]) {
        title = [[self childDataSourceForTableViewSection:section] tableView:tableView titleForHeaderInSection:section];
    }
    else {
        title = [self titleForHeaderInSection:section tableView:tableView];
    }
    
    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title;
    if ([self hasChildDataSources]) {
        title = [[self childDataSourceForTableViewSection:section] tableView:tableView titleForFooterInSection:section];
    }
    else {
        title = [self titleForFooterInSection:section tableView:tableView];
    }
    
    return title;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canEdit;
    if ([self hasChildDataSources]) {
        canEdit = [[self childDataSourceForTableViewSection:indexPath.section] tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    else {
        canEdit = [self canEditRowAtIndexPath:indexPath inTableView:tableView];
    }
    
    return canEdit;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canMove;
    if ([self hasChildDataSources]) {
        canMove = [[self childDataSourceForTableViewSection:indexPath.section] tableView:tableView canMoveRowAtIndexPath:indexPath];
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
    // TODO
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if ([sourceIndexPath isEqual:destinationIndexPath]) {
        // No move
        return;
    }
    
    MUKDataSource *sourceDataSource, *destinationDataSource;

    if ([self hasChildDataSources]) {
        sourceDataSource = [self childDataSourceForTableViewSection:sourceIndexPath.section];
        destinationDataSource = [self childDataSourceForTableViewSection:destinationIndexPath.section];
    }
    else {
        sourceDataSource = destinationDataSource = self;
    }
    
    if (sourceDataSource && destinationDataSource) {
        [sourceDataSource moveItemAtIndex:sourceIndexPath.row toDataSource:destinationDataSource atIndex:destinationIndexPath.row];
    }
}

@end
