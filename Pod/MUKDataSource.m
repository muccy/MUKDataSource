#import "MUKDataSource.h"

@implementation MUKDataSource
@end

#pragma mark -

@implementation  MUKDataSource (SectionedContent)
@dynamic sections;
@dynamic allItems;

- (NSArray *)sections {
    if ([_content isKindOfClass:[NSArray class]]) {
        return (NSArray *)[(id)_content copy];
    }
    
    return nil;
}

- (NSArray *)allItems {
    NSMutableArray *allItems = [NSMutableArray array];
    for (id<MUKDataSourceContentSection> section in self.sections) {
        if (section.items) {
            [allItems addObjectsFromArray:section.items];
        }
    }
    
    return [allItems copy];
}

- (id<MUKDataSourceContentSection>)sectionAtIndex:(NSInteger)idx {
    NSArray *const sections = self.sections;
    
    if (idx >= 0 && idx < sections.count) {
        id<MUKDataSourceContentSection> const section = sections[idx];
        if ([section conformsToProtocol:@protocol(MUKDataSourceContentSection)])
        {
            return section;
        }
    }
    
    return nil;
}

- (id<MUKDataSourceContentSection>)sectionWithIdentifier:(id<NSObject,NSCopying>)identifier
{
    if (!identifier) {
        return nil;
    }
    
    for (id<MUKDataSourceContentSection> section in self.sections) {
        if ([section respondsToSelector:@selector(identifier)]) {
            if ([section.identifier isEqual:identifier]) {
                return section;
            }
        }
    } // for
    
    return nil;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return nil;
    }
    
    id<MUKDataSourceContentSection> const section = [self sectionAtIndex:indexPath.section];
    if (indexPath.item >= 0 && indexPath.item < section.items.count) {
        return section.items[indexPath.item];
    }
    
    return nil;
}

- (NSIndexPath *)indexPathOfItemPassingTest:(BOOL (^)(id<MUKDataSourceIdentifiable>, NSIndexPath *, BOOL *))test
{
    if (!test) {
        return nil;
    }
    
    __block NSIndexPath *foundIndexPath = nil;
    
    [self.sections enumerateObjectsUsingBlock:^(id<MUKDataSourceContentSection> section, NSUInteger sectionIndex, BOOL *stopSectionCycle)
    {
        [section.items enumerateObjectsUsingBlock:^(id<MUKDataSourceIdentifiable> item, NSUInteger itemIndex, BOOL *stopItemCycle)
        {
            NSIndexPath *const indexPath = [NSIndexPath indexPathForItem:itemIndex inSection:sectionIndex];
            BOOL stop = NO;
            
            if (test(item, indexPath, &stop)) {
                foundIndexPath = indexPath;
                *stopItemCycle = YES;
                *stopSectionCycle = YES;
            }
            else if (stop) {
                *stopItemCycle = YES;
                *stopSectionCycle = YES;
            }
        }];
    }];
    
    return foundIndexPath;
}

- (NSIndexPath *)indexPathOfItem:(id<MUKDataSourceIdentifiable>)itemToFind {
    if (!itemToFind)  {
        return nil;
    }
    
    return [self indexPathOfItemPassingTest:^BOOL(id<MUKDataSourceIdentifiable> item, NSIndexPath *indexPath, BOOL *stop)
    {
        return [itemToFind isEqual:item];
    }];
}

+ (NSSet *)keyPathsForValuesAffectingSections {
    return [NSSet setWithObjects:NSStringFromSelector(@selector(content)), nil];
}

+ (NSSet *)keyPathsForValuesAffectingAllItems {
    return [NSSet setWithObjects:NSStringFromSelector(@selector(content)), nil];
}

@end

#pragma mark -

@implementation MUKDataSource (TableViewSupport)

- (MUKDataSourceTableUpdate *)setTableSections:(NSArray *)newSections {
    NSArray *const oldSections = self.sections;
    
    if (newSections != _content) {
        self.content = newSections;
    }
    
    return [self newTableUpdateFromSections:oldSections toSections:newSections];
}

- (MUKDataSourceTableSection *)tableSectionAtIndex:(NSInteger)idx {
    id<MUKDataSourceContentSection> const section = [self sectionAtIndex:idx];
    if ([section isKindOfClass:[MUKDataSourceTableSection class]]) {
        return (MUKDataSourceTableSection *)section;
    }
    
    return nil;
}

- (MUKDataSourceTableUpdate *)newTableUpdateFromSections:(NSArray *)sourceSections toSections:(NSArray *)destinationSections
{
    return [[MUKDataSourceTableUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
}

- (void)registerReusableViewsForTableView:(UITableView *)tableView {
    //
}

@end

#pragma mark - 

@implementation MUKDataSource (CollectionViewSupport)

- (MUKDataSourceCollectionUpdate *)setCollectionSections:(NSArray *)newSections {
    NSArray *const oldSections = self.sections;
    
    if (newSections != _content) {
        self.content = newSections;
    }
    
    return [self newCollectionUpdateFromSections:oldSections toSections:newSections];
}

- (MUKDataSourceCollectionSection *)collectionSectionAtIndex:(NSInteger)idx {
    id<MUKDataSourceContentSection> const section = [self sectionAtIndex:idx];
    if ([section isKindOfClass:[MUKDataSourceCollectionSection class]]) {
        return (MUKDataSourceCollectionSection *)section;
    }
    
    return nil;
}

- (MUKDataSourceCollectionUpdate *)newCollectionUpdateFromSections:(NSArray *)sourceSections toSections:(NSArray *)destinationSections
{
    return [[MUKDataSourceCollectionUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
}

- (void)registerReusableViewsForCollectionView:(UICollectionView *)collectionView
{
    //
}

@end

#pragma mark -

@implementation MUKDataSource (UITableViewDataSourceImplementedMethods)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)idx
{
    MUKDataSourceTableSection *const section = [self tableSectionAtIndex:idx];
    return section.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self tableSectionAtIndex:section].headerTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [self tableSectionAtIndex:section].footerTitle;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete: {
            // Remove committed row
            MUKDataSourceTableSection *const section = [self.sections[indexPath.section] sectionByRemovingItemAtIndex:indexPath.row];
            
            // Recreate section
            NSMutableArray *const sections = [self.sections mutableCopy];
            [sections replaceObjectAtIndex:indexPath.section withObject:section];

            // Apply update
            MUKDataSourceTableUpdate *const update = [self setTableSections:sections];
            [update applyToTableView:tableView animation:[MUKDataSourceTableUpdateAnimation automaticAnimation]];
            
            break;
        }
            
        default:
            // Do nothing
            break;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id<MUKDataSourceIdentifiable> const movedItem = [self itemAtIndexPath:sourceIndexPath];
    
    // Remove moved item
    MUKDataSourceTableSection *const sourceSection = self.sections[sourceIndexPath.section];
    MUKDataSourceTableSection *const newSourceSection = [sourceSection sectionByRemovingItemAtIndex:sourceIndexPath.row];

    // Insert moved item
    MUKDataSourceTableSection *const destinationSection = sourceIndexPath.section == destinationIndexPath.section ? newSourceSection : self.sections[destinationIndexPath.section];
    MUKDataSourceTableSection *const newDestinationSection = [destinationSection sectionByInsertingItem:movedItem atIndex:destinationIndexPath.row];

    // Set new sections
    NSMutableArray *const sections = [self.sections mutableCopy];
    [sections replaceObjectAtIndex:sourceIndexPath.section withObject:newSourceSection];
    [sections replaceObjectAtIndex:destinationIndexPath.section withObject:newDestinationSection];
    self.content = sections;
}

@end

#pragma mark - 

@implementation MUKDataSource (UICollectionViewDataSourceImplementedMethods)

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self sectionAtIndex:section].items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.sections.count;
}

@end
