//
//  TablePlaygroundDataSource.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TablePlaygroundDataSource.h"
#import "TablePlayground.h"
#import "TablePlaygroundCommand.h"

@implementation TablePlaygroundDataSource

- (instancetype)initWithPlayground:(TablePlayground *)playground {
    self = [super init];
    if (self) {
        _playground = playground;
        self.content = [self originalSections];
    }
    
    return self;
}

- (NSArray *)originalSections {
    MUKDataSourceContentSection *const commandsSection = [[MUKDataSourceContentSection alloc] initWithIdentifier:@"a" items:self.playground.commands header:nil footer:nil];
    
    MUKDataSourceContentSection *const section1 = [[MUKDataSourceContentSection alloc] initWithIdentifier:@"a" items:@[ @"a", @"b", @"c"] header:@"A" footer:nil];
    MUKDataSourceContentSection *const section2 = [[MUKDataSourceContentSection alloc] initWithIdentifier:@"b" items:@[ @"c", @"d", @"e"] header:@"B" footer:nil];
    MUKDataSourceContentSection *const section3 = [[MUKDataSourceContentSection alloc] initWithIdentifier:@"c" items:@[ @"f", @"g", @"h"] header:@"C" footer:nil];
    
    return @[ commandsSection, section1, section2, section3 ];
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
    id const item = [self itemAtIndexPath:indexPath];
    if ([item isKindOfClass:[TablePlaygroundCommand class]]) {
        TablePlaygroundCommand *const command = item;
        if (command.action) {
            command.action(self, tableView);
        }
    }
    else {
        switch (editingStyle) {
            case UITableViewCellEditingStyleDelete: {
                // Remove committed row
                MUKDataSourceContentSection *const section = [self.sections[indexPath.section] sectionByRemovingItemAtIndex:indexPath.row];
                
                // Recreate section
                NSMutableArray *const sections = [self.sections mutableCopy];
                [sections replaceObjectAtIndex:indexPath.section withObject:section];
                
                // Apply update
                MUKDataSourceTableUpdate *const update = [self setTableSections:sections];
                [update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation automaticAnimation]];
                
                break;
            }
                
            default:
                // Do nothing
                break;
        }
    }
}

@end
