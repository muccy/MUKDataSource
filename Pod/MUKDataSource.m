#import "MUKDataSource.h"

MUKDataSourceContent const MUKDataSourceIndefiniteContent = @"MUKDataSourceIndefiniteContent";

@implementation MUKDataSource
@end

#pragma mark -

@implementation  MUKDataSource (SectionedContent)

- (NSArray<MUKDataSourceContentSection *> *)sections {
    if ([_content isKindOfClass:[NSArray class]]) {
        if ([[(NSArray *)_content firstObject] isKindOfClass:[MUKDataSourceContentSection class]])
        {
            // Assume if first object is a section, every object will be a section
            return (NSArray *)[(id)_content copy];
        }
    }
    
    return nil;
}

- (NSArray<MUKDataSourceContentSectionItem> *)allItems {
    NSMutableArray<MUKDataSourceContentSectionItem> *const allItems = [NSMutableArray array];
    
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

- (MUKDataSourceContentSection *)sectionWithIdentifier:(MUKDataSourceIdentifier)identifier
{
    if (!identifier) {
        return nil;
    }
    
    for (MUKDataSourceContentSection *section in self.sections) {
        if ([section.identifier isEqual:identifier]) {
            return section;
        }
    } // for
    
    return nil;
}

- (MUKDataSourceContentSectionItem)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath) {
        return nil;
    }
    
    MUKDataSourceContentSection *const section = [self sectionAtIndex:indexPath.section];
    if (indexPath.item >= 0 && indexPath.item < section.items.count) {
        return section.items[indexPath.item];
    }
    
    return nil;
}

- (NSIndexPath *)indexPathOfItemPassingTest:(BOOL (^)(MUKDataSourceContentSectionItem _Nonnull, NSIndexPath * _Nonnull, BOOL * _Nonnull))test
{
    if (!test) {
        return nil;
    }
    
    __block NSIndexPath *foundIndexPath = nil;
    
    [self.sections enumerateObjectsUsingBlock:^(MUKDataSourceContentSection *section, NSUInteger sectionIndex, BOOL *stopSectionCycle)
    {
        [section.items enumerateObjectsUsingBlock:^(MUKDataSourceContentSectionItem item, NSUInteger itemIndex, BOOL *stopItemCycle)
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

- (NSIndexPath *)indexPathOfItem:(MUKDataSourceContentSectionItem)itemToFind {
    if (!itemToFind)  {
        return nil;
    }
    
    return [self indexPathOfItemPassingTest:^BOOL(MUKDataSourceContentSectionItem item, NSIndexPath *indexPath, BOOL *stop)
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

- (NSArray<MUKDataSourceContentPage> *)pages {
    if ([self.content isKindOfClass:[NSArray class]]) {
        return (NSArray *)self.content;
    }
    
    return nil;
}

- (MUKDataSourceContentPage)pageAtIndex:(NSInteger)idx {
    NSArray<MUKDataSourceContentPage> *const pages = self.pages;
    
    if (idx >= 0 && idx < pages.count) {
        return pages[idx];
    }
    
    return nil;
}

- (MUKDataSourceContentPage)pageForViewController:(UIViewController *)viewController
{
    return nil;
}

- (MUKDataSourceContentPage)pageFollowingPage:(MUKDataSourceContentPage)page {
    if ([self.content isKindOfClass:[NSArray class]]) {
        NSInteger const idx = [self indexOfPageUsingIdentifiers:page];
        if (idx == NSNotFound) {
            return nil;
        }
        
        return [self pageAtIndex:idx+1];
    }

    return nil;
}

- (MUKDataSourceContentPage)pagePrecedingPage:(MUKDataSourceContentPage)page
{
    if ([self.content isKindOfClass:[NSArray class]]) {
        NSInteger const idx = [self indexOfPageUsingIdentifiers:page];
        if (idx == NSNotFound) {
            return nil;
        }
        
        return [self pageAtIndex:idx-1];
    }
    
    return nil;
}

- (BOOL)page:(MUKDataSourceContentPage)page1 precedesPage:(MUKDataSourceContentPage)page2
{
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

- (UIViewController *)newViewControllerForPage:(MUKDataSourceContentPage)page
{
    return nil;
}

+ (NSSet *)keyPathsForValuesAffectingPages {
    return [NSSet setWithObjects:NSStringFromSelector(@selector(content)), nil];
}

- (NSInteger)indexOfPageUsingIdentifiers:(MUKDataSourceContentPage)pageToFind {
    return [self.pages indexOfObjectPassingTest:^BOOL(MUKDataSourceContentPage page, NSUInteger idx, BOOL *stop)
    {
        BOOL matches;
        
        if ([pageToFind respondsToSelector:@selector(identifier)] &&
            [page respondsToSelector:@selector(identifier)])
        {
            matches = [pageToFind.identifier isEqual:page.identifier];
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
    MUKDataSourceContentSectionItem const movedItem = [self itemAtIndexPath:sourceIndexPath];
    
    // Remove moved item
    MUKDataSourceContentSection *const sourceSection = self.sections[sourceIndexPath.section];
    MUKDataSourceContentSection *const newSourceSection = [sourceSection sectionByRemovingItemAtIndex:sourceIndexPath.row];

    // Insert moved item
    MUKDataSourceContentSection *const destinationSection = sourceIndexPath.section == destinationIndexPath.section ? newSourceSection : self.sections[destinationIndexPath.section];
    MUKDataSourceContentSection *const newDestinationSection = [destinationSection sectionByInsertingItem:movedItem atIndex:destinationIndexPath.row];

    // Set new sections
    NSMutableArray<MUKDataSourceContentSection *> *const sections = [self.sections mutableCopy];
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

#pragma mark -

@implementation MUKDataSource (UIPageViewControllerDataSourceImplementedMethods)

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    MUKDataSourceContentPage const page = [self pageForViewController:viewController];
    MUKDataSourceContentPage const newPage = [self pagePrecedingPage:page];
    return newPage ? [self newViewControllerForPage:newPage] : nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    MUKDataSourceContentPage const page = [self pageForViewController:viewController];
    MUKDataSourceContentPage const newPage = [self pageFollowingPage:page];
    return newPage ? [self newViewControllerForPage:newPage] : nil;
}

@end
