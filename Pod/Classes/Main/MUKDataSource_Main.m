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
}

#pragma mark - Table View

- (void)registerReusableViewsForTableView:(UITableView *)tableView {
    for (MUKDataSource *childDataSource in self.childDataSources) {
        [childDataSource registerReusableViewsForTableView:tableView];
    } // for
}

- (UITableViewCell *)dequeueOrCreateCellForRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    return nil;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    //
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

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self hasChildDataSources] ? [self.childDataSources count] : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count;
    
    if ([self hasChildDataSources]) {
        count = [[self childDataSourceAtIndex:section] tableView:tableView numberOfRowsInSection:section];
    }
    else {
        count = [self.items count];
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self dequeueOrCreateCellForRowAtIndexPath:indexPath tableView:tableView];
    [self configureCell:cell forRowAtIndexPath:indexPath tableView:tableView];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    if ([self hasChildDataSources]) {
        title = [[self childDataSourceAtIndex:section] tableView:tableView titleForHeaderInSection:section];
    }
    else {
        title = self.title;
    }
    
    return title;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *title;
    if ([self hasChildDataSources]) {
        title = [[self childDataSourceAtIndex:section] tableView:tableView titleForFooterInSection:section];
    }
    else {
        title = nil;
    }
    
    return title;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canEdit;
    if ([self hasChildDataSources]) {
        canEdit = [[self childDataSourceAtIndex:indexPath.section] tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    else {
        canEdit = NO;
    }
    
    return canEdit;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canMove;
    if ([self hasChildDataSources]) {
        canMove = [[self childDataSourceAtIndex:indexPath.section] tableView:tableView canMoveRowAtIndexPath:indexPath];
    }
    else {
        canMove = NO;
    }
    
    return canMove;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([self childDataSourceAtIndex:index]) {
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
    // TODO
}

@end
