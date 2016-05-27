#import "MUKDataSource.h"

NSObject *const MUKDataSourceIndefiniteContent = @"MUKDataSourceIndefiniteContent";
NSString *const MUKDataSourceInconsistencyException = @"MUKDataSourceInconsistencyException";

@implementation MUKDataSource
@end

#pragma mark -

@implementation MUKDataSource (SectionedContent)

- (NSArray *)sections {
    if ([_content isKindOfClass:[NSArray class]]) {
        if ([[(NSArray *)_content firstObject] isKindOfClass:[MUKDataSourceContentSection class]])
        {
            // Assume if first object is a section, every object will be a section
            return (NSArray *)[_content copy];
        }
    }
    
    return nil;
}

- (NSArray *)allItems {
    NSMutableArray *const allItems = [NSMutableArray array];
    
    for (MUKDataSourceContentSection *section in self.sections) {
        if (section.items) {
            [allItems addObjectsFromArray:section.items];
        }
    } // for
    
    return [allItems copy];
}

- (MUKDataSourceContentSection *)sectionAtIndex:(NSInteger)idx {
    NSArray<MUKDataSourceContentSection *> *const sections = self.sections;
    
    if (idx >= 0 && idx < sections.count) {
        return sections[idx];
    }
    
    return nil;
}

- (__kindof MUKDataSourceContentSection *)sectionWithIdentifier:(MUKDataSourceIdentifier)identifier
{
    for (MUKDataSourceContentSection *section in self.sections) {
        if ([section.identifier isEqual:identifier]) {
            return section;
        }
    } // for
    
    return nil;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    MUKDataSourceContentSection *const section = [self sectionAtIndex:indexPath.section];
    if (indexPath.item >= 0 && indexPath.item < section.items.count) {
        return section.items[indexPath.item];
    }
    
    return nil;
}

- (NSIndexPath *)indexPathOfItemPassingTest:(BOOL (^)(id _Nonnull, NSIndexPath * _Nonnull, BOOL * _Nonnull))test
{
    __block NSIndexPath *foundIndexPath = nil;
    
    [self.sections enumerateObjectsUsingBlock:^(MUKDataSourceContentSection *section, NSUInteger sectionIndex, BOOL *stopSectionCycle)
    {
        [section.items enumerateObjectsUsingBlock:^(id item, NSUInteger itemIndex, BOOL *stopItemCycle)
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

- (NSIndexPath *)indexPathOfItem:(id)itemToFind {
    return [self indexPathOfItemPassingTest:^BOOL(id item, NSIndexPath *indexPath, BOOL *stop)
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

- (MUKDataSourceTableUpdate *)setTableSections:(NSArray<MUKDataSourceContentSection *> *)newSections
{
    NSArray<MUKDataSourceContentSection *> *const oldSections = self.sections;
    
    if (newSections != _content) {
        self.content = newSections;
    }
    
    return [self newTableUpdateFromSections:oldSections toSections:newSections];
}

- (MUKDataSourceTableUpdate *)newTableUpdateFromSections:(NSArray<MUKDataSourceContentSection *> *)sourceSections toSections:(NSArray<MUKDataSourceContentSection *> *)destinationSections
{
    return [[MUKDataSourceTableUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
}

- (void)registerReusableViewsForTableView:(UITableView *)tableView {
    //
}

@end

#pragma mark - 

@implementation MUKDataSource (CollectionViewSupport)

- (MUKDataSourceCollectionUpdate *)setCollectionSections:(NSArray<MUKDataSourceContentSection *> *)newSections
{
    NSArray<MUKDataSourceContentSection *> *const oldSections = self.sections;
    
    if (newSections != _content) {
        self.content = newSections;
    }
    
    return [self newCollectionUpdateFromSections:oldSections toSections:newSections];
}

- (MUKDataSourceCollectionUpdate *)newCollectionUpdateFromSections:(NSArray<MUKDataSourceContentSection *> *)sourceSections toSections:(NSArray<MUKDataSourceContentSection *> *)destinationSections
{
    return [[MUKDataSourceCollectionUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
}

- (void)registerReusableViewsForCollectionView:(UICollectionView *)collectionView
{
    //
}

@end

#pragma mark -

@implementation MUKDataSource (PageViewControllerSupport)

- (NSArray *)pages {
    if ([self.content isKindOfClass:[NSArray class]]) {
        return (NSArray *)self.content;
    }
    
    return nil;
}

- (id)pageAtIndex:(NSInteger)idx {
    NSArray *const pages = self.pages;
    
    if (idx >= 0 && idx < pages.count) {
        return pages[idx];
    }
    
    return nil;
}

- (id)pageForViewController:(__kindof UIViewController *)viewController
{
    [NSException raise:MUKDataSourceInconsistencyException format:@"Data source failed to provide a page for view controller %@", viewController];
    return nil;
}

- (id)pageFollowingPage:(id)page {
    NSInteger const idx = [self indexOfPageUsingIdentifiers:page];
    return idx != NSNotFound ? [self pageAtIndex:idx+1] : nil;
}

- (id)pagePrecedingPage:(id)page {
    NSInteger const idx = [self indexOfPageUsingIdentifiers:page];
    return idx != NSNotFound ? [self pageAtIndex:idx-1] : nil;
}

- (BOOL)page:(id)page1 precedesPage:(id)page2 {
    NSInteger const idx1 = [self indexOfPageUsingIdentifiers:page1];
    if (idx1 == NSNotFound) {
        return NO;
    }
    
    NSInteger const idx2 = [self indexOfPageUsingIdentifiers:page2];
    if (idx2 == NSNotFound) {
        return NO;
    }
    
    return idx1 < idx2;
}

- (__kindof UIViewController *)newViewControllerForPage:(id)page {
    [NSException raise:MUKDataSourceInconsistencyException format:@"Data source failed to provide a view controller for page %@", page];
    return nil;
}

+ (NSSet *)keyPathsForValuesAffectingPages {
    return [NSSet setWithObjects:NSStringFromSelector(@selector(content)), nil];
}

- (NSInteger)indexOfPageUsingIdentifiers:(id)pageToFind {
    return [self.pages indexOfObjectPassingTest:^BOOL(id page, NSUInteger idx, BOOL *stop)
    {
        BOOL matches;
        
        if ([pageToFind respondsToSelector:@selector(identifier)] &&
            [page respondsToSelector:@selector(identifier)])
        {
            matches = [[pageToFind identifier] isEqual:[page identifier]];
        }
        else {
            matches = [pageToFind isEqual:page];
        }
        
        if (matches) {
            *stop = YES;
        }
        
        return matches;
    }];
}

@end

#pragma mark -

@implementation MUKDataSource (UITableViewDataSourceImplementedMethods)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)idx
{
    MUKDataSourceContentSection *const section = [self sectionAtIndex:idx];
    return section.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id const item = [self itemAtIndexPath:indexPath];
    [NSException raise:MUKDataSourceInconsistencyException format:@"Data source failed to provide a cell for item %@ at index path (%i, %i)", item, indexPath.section, indexPath.row];
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIdx
{
    MUKDataSourceContentSection *const section = [self sectionAtIndex:sectionIdx];
    
    if ([section.header isKindOfClass:[NSString class]]) {
        return (NSString *)section.header;
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)sectionIdx
{
    MUKDataSourceContentSection *const section = [self sectionAtIndex:sectionIdx];
    
    if ([section.footer isKindOfClass:[NSString class]]) {
        return (NSString *)section.footer;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    id const movedItem = [self itemAtIndexPath:sourceIndexPath];
    
    // Remove moved item
    NSArray *const sections = self.sections;
    MUKDataSourceContentSection *const sourceSection = sections[sourceIndexPath.section];
    MUKDataSourceContentSection *const newSourceSection = [sourceSection sectionByRemovingItemAtIndex:sourceIndexPath.row];

    // Insert moved item
    MUKDataSourceContentSection *const destinationSection = sourceIndexPath.section == destinationIndexPath.section ? newSourceSection : sections[destinationIndexPath.section];
    MUKDataSourceContentSection *const newDestinationSection = [destinationSection sectionByInsertingItem:movedItem atIndex:destinationIndexPath.row];

    // Set new sections
    NSMutableArray<MUKDataSourceContentSection *> *const newSections = [sections mutableCopy];
    [newSections replaceObjectAtIndex:sourceIndexPath.section withObject:newSourceSection];
    [newSections replaceObjectAtIndex:destinationIndexPath.section withObject:newDestinationSection];
    self.content = newSections;
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
    id const item = [self itemAtIndexPath:indexPath];
    [NSException raise:MUKDataSourceInconsistencyException format:@"Data source failed to provide a cell for item %@ at index path (%i, %i)", item, indexPath.section, indexPath.item];
    
    return nil;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.sections.count;
}

@end

#pragma mark -

@implementation MUKDataSource (UIPageViewControllerDataSourceImplementedMethods)

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    id const page = [self pageForViewController:viewController];
    id const newPage = [self pagePrecedingPage:page];
    return newPage ? [self newViewControllerForPage:newPage] : nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    id const page = [self pageForViewController:viewController];
    id const newPage = [self pageFollowingPage:page];
    return newPage ? [self newViewControllerForPage:newPage] : nil;
}

@end
