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

- (void)setSections:(NSArray *)sections {
    if (sections != _content) {
        _content = [sections copy];
    }
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

@end

#pragma mark -

@implementation MUKDataSource (TableViewSupport)

- (MUKDataSourceTableSection *)tableSectionAtIndex:(NSInteger)idx {
    id<MUKDataSourceContentSection> const section = [self sectionAtIndex:idx];
    if ([section isKindOfClass:[MUKDataSourceTableSection class]]) {
        return (MUKDataSourceTableSection *)section;
    }
    
    return nil;
}

- (id<MUKDataSourceIdentifiable>)tableRowItemAtIndexPath:(NSIndexPath *)indexPath
{
    id const rowItem = [self itemAtIndexPath:indexPath];
    if ([rowItem conformsToProtocol:@protocol(MUKDataSourceIdentifiable)])
    {
        return rowItem;
    }
    
    return nil;
}

#pragma mark <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)idx
{
    MUKDataSourceTableSection *const section = [self tableSectionAtIndex:idx];
    return section.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
    
    NSString *const text = [NSString stringWithFormat:@"(%lu, %lu): %@", (unsigned long)indexPath.section, (unsigned long)indexPath.row, [self tableRowItemAtIndexPath:indexPath]];
    cell.textLabel.text = text;
    
    return cell;
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

// Moving/reordering

// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;



// Data manipulation - insert and delete support

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
// Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO
}

// Data manipulation - reorder / moving support

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // TODO
}

@end
