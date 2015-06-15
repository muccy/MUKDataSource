//
//  TableExamplesDataSource.m
//  MUKDataSource
//
//  Created by Marco on 14/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TableExamplesDataSource.h"
#import "TableExample.h"

@implementation TableExamplesDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        MUKDataSourceTableSection *const sectionExamplesSection = [[MUKDataSourceTableSection alloc] initWithIdentifier:@"section-examples" items:[self newSectionExamples] headerTitle:@"Section" footerTitle:nil];
        MUKDataSourceTableSection *const rowExamplesSection = [[MUKDataSourceTableSection alloc] initWithIdentifier:@"row-examples" items:[self newRowExamples] headerTitle:@"Row" footerTitle:nil];
        [self setTableSections:@[sectionExamplesSection, rowExamplesSection]];
    }
    
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const kCellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    TableExample *const example = [self tableRowItemAtIndexPath:indexPath];
    cell.textLabel.text = example.title;
    
    return cell;
}

#pragma mark - Private – Section Examples

- (NSArray *)newSectionExamples {
    NSMutableArray *const examples = [NSMutableArray array];
    
    [examples addObject:[self newSectionInsertionExample]];
    [examples addObject:[self newSectionDeletionExample]];
    [examples addObject:[self newSectionReloadExample]];
    [examples addObject:[self newSectionMovementsExample]];
    [examples addObject:[self newSectionComboInsertionDeletionExample]];
    [examples addObject:[self newSectionComboInsertionReloadExample]];
    [examples addObject:[self newSectionComboInsertionMovementsExample]];
    [examples addObject:[self newSectionComboDeletionReloadExample]];
    [examples addObject:[self newSectionComboDeletionMovementsExample]];
    [examples addObject:[self newSectionComboReloadMovementsExample]];
    [examples addObject:[self newSectionComboInsertionDeletionReloadExample]];
    [examples addObject:[self newSectionComboInsertionDeletionMovementsExample]];
    [examples addObject:[self newSectionComboInsertionDeletionReloadMovementExample]];
    
    return [examples copy];
}

- (TableExample *)newSectionInsertionExample {
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"c", nil, nil), TableSection(@"b", nil, nil) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion" title:@"Insertion" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionDeletionExample {
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"d", nil, nil) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"deletion" title:@"Deletion" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionReloadExample {
    // a, b, c
    // a, b', c'
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", @"B'", nil), TableSection(@"c", nil, nil) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"reload" title:@"Reload" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionMovementsExample {
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"c", nil, nil), TableSection(@"b", nil, nil), TableSection(@"d", nil, nil), TableSection(@"a", nil, nil) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"movements" title:@"Movements" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionComboInsertionDeletionExample {
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"c", nil, nil), TableSection(@"b", nil, nil) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+deletion" title:@"Insertion + Deletion" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionComboInsertionReloadExample {
    // a, b
    // c, d, a, e, b', f
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"c", nil, nil), TableSection(@"d", nil, nil), TableSection(@"a", nil, nil), TableSection(@"e", nil, nil), TableSection(@"b", @"B'", nil), TableSection(@"f", nil, nil) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+reload" title:@"Insertion + Reload" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionComboInsertionMovementsExample {
    // a, b, c, d
    // e, c, b, d, f, a
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"e", nil, nil), TableSection(@"c", nil, nil), TableSection(@"b", nil, nil), TableSection(@"d", nil, nil), TableSection(@"f", nil, nil), TableSection(@"a", nil, nil) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+movements" title:@"Insertion + Movements" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionComboDeletionReloadExample {
    // a, b, c, d
    // b, d'
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"d", @"D'", nil) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"deletion+reload" title:@"Deletion + Reload" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionComboReloadMovementsExample {
    // a, b, c
    // c, b, a'
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"c", nil, nil), TableSection(@"b", nil, nil), TableSection(@"a", @"A'", nil) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"reload+movements" title:@"Reload + Movements" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionComboDeletionMovementsExample {
    // a, b, c, d, e
    // b, e, c
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil), TableSection(@"e", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"e", nil, nil), TableSection(@"c", nil, nil) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"deletion+movements" title:@"Deletion + Movements" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionComboInsertionDeletionReloadExample {
    // a, b, c
    // a, d, b', e
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"d", nil, nil), TableSection(@"b", @"B'", nil), TableSection(@"e", nil, nil) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+deletion+reload" title:@"Insertion + Deletion + Reload" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionComboInsertionDeletionMovementsExample {
    // a, b, c
    // b, d, a, e
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"d", nil, nil), TableSection(@"a", nil, nil), TableSection(@"e", nil, nil) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+deletion+movements" title:@"Insertion + Deletion + Movements" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionComboInsertionDeletionReloadMovementExample {
    // a, b, c
    // b, d, a', e
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"d", nil, nil), TableSection(@"a", @"A'", nil), TableSection(@"e", nil, nil) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+deletion+reload+movements" title:@"Insertion + Deletion + Reload + Movements" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

#pragma mark - Private — Row Examples

- (NSArray *)newRowExamples {
    NSMutableArray *examples = [NSMutableArray array];
    
    [examples addObject:[self newRowInsertionExample]];
    [examples addObject:[self newRowInsertionWithSectionReloadExample]];
    [examples addObject:[self newRowDeletionExample]];
    [examples addObject:[self newRowDeletionWithSectionReloadExample]];
    
    return [examples copy];
}

- (TableExample *)newRowInsertionExample {
    // a, b
    // a, c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"a", @"c", @"b" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion" title:@"Insertion" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowInsertionWithSectionReloadExample {
    // a, b
    // a, c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"a", @"c", @"b" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", @"A'", destinationItems)];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+section-reload" title:@"Insertion (with section reload)" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowDeletionExample {
    // a, b, c
    // a, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"a", @"c" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];

    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"deletion" title:@"Deletion" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowDeletionWithSectionReloadExample {
    // a, b, c
    // a, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"a", @"c" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", @"A'", destinationItems)];

    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"deletion+section-reload" title:@"Deletion (with section reload)" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

#pragma mark - Private — Section Generation

static inline MUKDataSourceTableSection *TableSection(NSString *identifier, NSString *title, NSArray *items)
{
    return [[MUKDataSourceTableSection alloc] initWithIdentifier:identifier items:items ?: @[@""] headerTitle:[@"Section: " stringByAppendingString:title ?: [identifier uppercaseString]] footerTitle:nil];
}

@end
