//
//  MUKDataSource.m
//  
//
//  Created by Marco on 10/06/15.
//
//

#import "MUKDataSource.h"

@implementation MUKDataSource

@end

#pragma mark -

@implementation  MUKDataSource (SectionedContent)
@dynamic sections;

- (NSArray *)sections {
    if ([_content isKindOfClass:[NSArray class]]) {
        return (NSArray *)_content;
    }
    
    return nil;
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

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    id<MUKDataSourceContentSection> const section = [self sectionAtIndex:indexPath.section];
    if (indexPath.item >= 0 && indexPath.item < section.items.count) {
        return section.items[indexPath.item];
    }
    
    return nil;
}

+ (NSSet *)keyPathsForValuesAffectingSections {
    return [NSSet setWithObjects:NSStringFromSelector(@selector(content)), nil];
}

@end

#pragma mark -

@implementation MUKDataSource (TableViewSupport)

- (MUKDataSourceTableUpdate *)setTableSections:(NSArray *)tableSections
{
    if (tableSections != _content) {
        MUKDataSourceTableUpdate *const update = [self newTableUpdateFromSections:self.sections toSections:tableSections];
        self.content = tableSections;
        return update;
    }
    
    return nil;
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

@end

@implementation MUKDataSource (CollectionViewSupport)

- (MUKDataSourceCollectionUpdate *)setCollectionSections:(NSArray *)sections {
    if (sections != _content) {
        MUKDataSourceCollectionUpdate *const update = [self newCollectionUpdateFromSections:self.sections toSections:sections];
        self.content = sections;
        return update;
    }
    
    return nil;
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
            MUKDataSourceTableSection *const section = [self.sections[indexPath.section] tableSectionRemovingItemAtIndex:indexPath.row];
            
            // Recreate section
            NSMutableArray *const sections = [self.sections mutableCopy];
            [sections replaceObjectAtIndex:indexPath.section withObject:section];

            // Apply update
            MUKDataSourceTableUpdate *const update = [self setTableSections:sections];
            [update applyToTableView:tableView animated:YES];
            
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
    MUKDataSourceTableSection *const newSourceSection = [sourceSection tableSectionRemovingItemAtIndex:sourceIndexPath.row];

    // Insert moved item
    MUKDataSourceTableSection *const destinationSection = sourceIndexPath.section == destinationIndexPath.section ? newSourceSection : self.sections[destinationIndexPath.section];
    MUKDataSourceTableSection *const newDestinationSection = [destinationSection tableSectionInsertingItem:movedItem atIndex:destinationIndexPath.row];

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
