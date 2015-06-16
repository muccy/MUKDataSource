//
//  TablePlaygroundDataSource.m
//  MUKDataSource
//
//  Created by Marco on 16/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TablePlaygroundDataSource.h"
#import "TablePlaygroundCommand.h"

@implementation TablePlaygroundDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        self.content = [[self class] originalSections];
    }
    
    return self;
}

+ (NSArray *)originalSections {
    MUKDataSourceTableSection *const commandsSection = [[MUKDataSourceTableSection alloc] initWithIdentifier:@"a" items:[self defaultCommands] headerTitle:nil footerTitle:nil];
    
    MUKDataSourceTableSection *const section1 = [[MUKDataSourceTableSection alloc] initWithIdentifier:@"a" items:@[ @"a", @"b", @"c"] headerTitle:@"A" footerTitle:nil];
    MUKDataSourceTableSection *const section2 = [[MUKDataSourceTableSection alloc] initWithIdentifier:@"b" items:@[ @"c", @"d", @"e"] headerTitle:@"B" footerTitle:nil];
    MUKDataSourceTableSection *const section3 = [[MUKDataSourceTableSection alloc] initWithIdentifier:@"c" items:@[ @"f", @"g", @"h"] headerTitle:@"C" footerTitle:nil];
    
    return @[ commandsSection, section1, section2, section3 ];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const kCellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    
    id const item = [self itemAtIndexPath:indexPath];
    
    if ([item isKindOfClass:[NSString class]]) {
        cell.textLabel.text = item;
    }
    else if ([item isKindOfClass:[TablePlaygroundCommand class]]) {
        TablePlaygroundCommand *const command = item;
        cell.textLabel.text = command.title;
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    id const item = [self itemAtIndexPath:indexPath];
    if ([item isKindOfClass:[TablePlaygroundCommand class]]) {
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    
    id const item = [self itemAtIndexPath:indexPath];
    if ([item isKindOfClass:[TablePlaygroundCommand class]]) {
        TablePlaygroundCommand *const command = item;
        if (command.action) {
            command.action(self, tableView);
        }
    }
}

#pragma mark - Private

+ (NSArray *)defaultCommands {
    NSMutableArray *commands = [NSMutableArray array];

    TablePlaygroundCommand *command = [[TablePlaygroundCommand alloc] initWithIdentifier:@"add-row" title:@"Add Row" editingStyle:UITableViewCellEditingStyleInsert action:^(MUKDataSource *dataSource, UITableView *tableView)
    {
        NSUInteger const sectionIndex = (arc4random() % (dataSource.sections.count-1)) + 1;
        MUKDataSourceTableSection *const section = [dataSource tableSectionAtIndex:sectionIndex];
        
        NSUInteger const rowIndex = arc4random() % section.items.count;
        MUKDataSourceTableSection *const newSection = [section tableSectionInsertingItem:[NSString stringWithFormat:@"%.0f", [NSDate timeIntervalSinceReferenceDate]]  atIndex:rowIndex];
        
        NSMutableArray *const sections = [dataSource.sections mutableCopy];
        [sections replaceObjectAtIndex:sectionIndex withObject:newSection];
        
        MUKDataSourceTableUpdate *const update = [dataSource setTableSections:sections];
        [update applyToTableView:tableView animated:YES];
    }];
    [commands addObject:command];
    
    return [commands copy];
}

@end
