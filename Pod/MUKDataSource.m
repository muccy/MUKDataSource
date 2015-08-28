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
    for (id obj in self.sections) {
        if ([obj isKindOfClass:[MUKDataSourceContentSection class]]) {
            MUKDataSourceContentSection *const section = obj;

            if (section.items) {
                [allItems addObjectsFromArray:section.items];
            }
        }
    } // for
    
    return [allItems copy];
}

- (MUKDataSourceContentSection *__nullable)sectionAtIndex:(NSInteger)idx {
    NSArray *const sections = self.sections;
    
    if (idx >= 0 && idx < sections.count) {
        MUKDataSourceContentSection *const section = sections[idx];
        if ([section isKindOfClass:[MUKDataSourceContentSection class]]) {
            return section;
        }
    }
    
    return nil;
}

- (MUKDataSourceContentSection *__nullable)sectionWithIdentifier:(id<NSObject,NSCopying>)identifier
{
    if (!identifier) {
        return nil;
    }
    
    for (id obj in self.sections) {
        if ([obj isKindOfClass:[MUKDataSourceContentSection class]]) {
            MUKDataSourceContentSection *const section = obj;
            
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
    
    MUKDataSourceContentSection *const section = [self sectionAtIndex:indexPath.section];
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
    
    [self.sections enumerateObjectsUsingBlock:^(id obj, NSUInteger sectionIndex, BOOL *stopSectionCycle)
    {
        if ([obj isKindOfClass:[MUKDataSourceContentSection class]]) {
            MUKDataSourceContentSection *const section = obj;
            
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
        } // if
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

- (MUKDataSourceTableUpdate *__nonnull)setTableSections:(NSArray *__nullable)newSections
{
    NSArray *const oldSections = self.sections;
    
    if (newSections != _content) {
        self.content = newSections;
    }
    
    return [self newTableUpdateFromSections:oldSections toSections:newSections];
}

- (MUKDataSourceTableUpdate *__nonnull)newTableUpdateFromSections:(NSArray *__nullable)sourceSections toSections:(NSArray *__nullable)destinationSections
{
    return [[MUKDataSourceTableUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
}

- (void)registerReusableViewsForTableView:(UITableView *)tableView {
    //
}

@end

#pragma mark - 

@implementation MUKDataSource (CollectionViewSupport)

- (MUKDataSourceCollectionUpdate *__nonnull)setCollectionSections:(NSArray *__nullable)newSections
{
    NSArray *const oldSections = self.sections;
    
    if (newSections != _content) {
        self.content = newSections;
    }
    
    return [self newCollectionUpdateFromSections:oldSections toSections:newSections];
}


- (MUKDataSourceCollectionUpdate *__nonnull)newCollectionUpdateFromSections:(NSArray *__nullable)sourceSections toSections:(NSArray *__nullable)destinationSections
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
    id<MUKDataSourceIdentifiable> const movedItem = [self itemAtIndexPath:sourceIndexPath];
    
    // Remove moved item
    MUKDataSourceContentSection *const sourceSection = self.sections[sourceIndexPath.section];
    MUKDataSourceContentSection *const newSourceSection = [sourceSection sectionByRemovingItemAtIndex:sourceIndexPath.row];

    // Insert moved item
    MUKDataSourceContentSection *const destinationSection = sourceIndexPath.section == destinationIndexPath.section ? newSourceSection : self.sections[destinationIndexPath.section];
    MUKDataSourceContentSection *const newDestinationSection = [destinationSection sectionByInsertingItem:movedItem atIndex:destinationIndexPath.row];

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
