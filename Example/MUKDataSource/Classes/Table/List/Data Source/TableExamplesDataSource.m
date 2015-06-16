//
//  TableExamplesDataSource.m
//  MUKDataSource
//
//  Created by Marco on 14/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TableExamplesDataSource.h"
#import "TableExample.h"
#import "TableExampleItem.h"
#import "Playground.h"

@implementation TableExamplesDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        MUKDataSourceTableSection *const playgroundSection = [[MUKDataSourceTableSection alloc] initWithIdentifier:@"playground" items:@[[[Playground alloc] initWithIdentifier:@"playground" title:@"Playground"]] headerTitle:nil footerTitle:nil];
        MUKDataSourceTableSection *const sectionExamplesSection = [[MUKDataSourceTableSection alloc] initWithIdentifier:@"section-examples" items:[self newSectionExamples] headerTitle:@"Section" footerTitle:nil];
        MUKDataSourceTableSection *const rowExamplesSection = [[MUKDataSourceTableSection alloc] initWithIdentifier:@"row-examples" items:[self newRowExamples] headerTitle:@"Row" footerTitle:nil];
        [self setTableSections:@[playgroundSection, sectionExamplesSection, rowExamplesSection]];
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
    
    id<MUKDataSourceIdentifiable> const item = [self tableRowItemAtIndexPath:indexPath];
    if ([item respondsToSelector:@selector(title)]) {
        cell.textLabel.text = [(id)item title];
    }
    
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
    [examples addObject:[self newSectionComboDeletionReloadMovementsExample]];
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

- (TableExample *)newSectionComboDeletionReloadMovementsExample {
    // a, b, c, d
    // b, a', d
    NSArray *const sourceSections = @[ TableSection(@"a", @"a", nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"a", @"a'", nil), TableSection(@"d", nil, nil) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"deletion+reload+movements" title:@"Deletion + Reload + Movements" sourceTableSections:sourceSections destinationTableSections:destinationSections];
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
    [examples addObject:[self newRowInsertionWithSectionMovementExample]];
    [examples addObject:[self newRowDeletionExample]];
    [examples addObject:[self newRowDeletionWithSectionReloadExample]];
    [examples addObject:[self newRowDeletionWithSectionMovementExample]];
    [examples addObject:[self newRowReloadExample]];
    [examples addObject:[self newRowReloadWithSectionReloadExample]];
    [examples addObject:[self newRowReloadWithSectionMovementExample]];
    [examples addObject:[self newRowMovementsExample]];
    [examples addObject:[self newRowMovementsBetweenSectionsExample]];
    [examples addObject:[self newRowMovementsWithSectionReloadExample]];
    [examples addObject:[self newRowMovementsWithSectionMovementExample]];
    [examples addObject:[self newRowMovementsToInsertedSectionExample]];
    [examples addObject:[self newRowMovementsFromDeletedSectionExample]];
    [examples addObject:[self newRowComboInsertionDeletionExample]];
    [examples addObject:[self newRowComboInsertionReloadExample]];
    [examples addObject:[self newRowComboInsertionMovementsExample]];
    [examples addObject:[self newRowComboDeletionReloadExample]];
    [examples addObject:[self newRowComboDeletionMovementsExample]];
    [examples addObject:[self newRowComboReloadMovementsExample]];
    [examples addObject:[self newRowComboInsertionDeletionReloadExample]];
    [examples addObject:[self newRowComboInsertionDeletionMovementExample]];
    [examples addObject:[self newRowComboDeletionReloadMovementsExample]];
    [examples addObject:[self newRowComboInsertionDeletionReloadMovementExample]];
    
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

- (TableExample *)newRowInsertionWithSectionMovementExample {
    // a, b
    // a, c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"a", @"c", @"b" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItems), TableSection(@"b", nil, nil)];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"a", nil, destinationItems) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+section-movement" title:@"Insertion (with section movement)" sourceTableSections:sourceSections destinationTableSections:destinationSections];
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

- (TableExample *)newRowDeletionWithSectionMovementExample {
    // a, b, c
    // a, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"a", @"c" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItems), TableSection(@"b", nil, nil)];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"a", nil, destinationItems) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"deletion+section-movement" title:@"Deletion (with section movement)" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowReloadExample {
    // a, b, c
    // a, b', c
    NSArray *const sourceItems = @[ @"a", [[TableExampleItem alloc] initWithIdentifier:@"b" title:@"b"], @"c" ];
    NSArray *const destinationItems = @[ @"a", [[TableExampleItem alloc] initWithIdentifier:@"b" title:@"b'"], @"c" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"reload" title:@"Reload" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowReloadWithSectionReloadExample {
    // a, b, c
    // a, b', c
    NSArray *const sourceItems = @[ @"a", [[TableExampleItem alloc] initWithIdentifier:@"b" title:@"b"], @"c" ];
    NSArray *const destinationItems = @[ @"a", [[TableExampleItem alloc] initWithIdentifier:@"b" title:@"b'"], @"c" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", @"A'", destinationItems)];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"reload+section-reload" title:@"Reload (with section reload)" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowReloadWithSectionMovementExample {
    // a, b, c
    // a, b', c
    NSArray *const sourceItems = @[ @"a", [[TableExampleItem alloc] initWithIdentifier:@"b" title:@"b"], @"c" ];
    NSArray *const destinationItems = @[ @"a", [[TableExampleItem alloc] initWithIdentifier:@"b" title:@"b'"], @"c" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItems), TableSection(@"b", nil, nil)];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"a", nil, destinationItems) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"reload+section-movement" title:@"Reload (with section movement)" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowMovementsExample {
    // a, b, c, d
    // c, a, d, b
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"c", @"a", @"d", @"b" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"movements" title:@"Movements" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowMovementsBetweenSectionsExample {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    NSArray *const sourceItemsB = @[ @"c", @"d", @"e", @"f" ];
    
    NSArray *const destinationItemsA = @[ @"c", @"b", @"f", @"d" ];
    NSArray *const destinationItemsB = @[ @"a", @"e" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItemsA), TableSection(@"b", nil, sourceItemsB) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, destinationItemsA), TableSection(@"b", nil, destinationItemsB) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"movements-between-sections" title:@"Movements between sections" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowMovementsWithSectionReloadExample {
    // a, b, c, d
    // c, a, d, b
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"c", @"a", @"d", @"b" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", @"A", sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", @"A'", destinationItems)];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"movements+section-reload" title:@"Movements (with section reload)" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowMovementsWithSectionMovementExample {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    NSArray *const sourceItemsB = @[ @"c", @"d" ];
    NSArray *const sourceItemsC = @[ @"e", @"f" ];
    
    NSArray *const destinationItemsA = @[ @"b" ];
    NSArray *const destinationItemsC = @[ @"e", @"f" ];
    NSArray *const destinationItemsB = @[ @"c", @"a", @"d" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItemsA), TableSection(@"b", nil, sourceItemsB), TableSection(@"c", nil, sourceItemsC) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, destinationItemsA), TableSection(@"c", nil, destinationItemsC), TableSection(@"b", nil, destinationItemsB) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"movements+section-movement" title:@"Movements (with section movement)" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowMovementsToInsertedSectionExample {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    
    NSArray *const destinationItemsA = @[ @"b" ];
    NSArray *const destinationItemsB = @[ @"c", @"a" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItemsA) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, destinationItemsA), TableSection(@"b", nil, destinationItemsB) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"movements-to-inserted-section" title:@"Movement to inserted section" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowMovementsFromDeletedSectionExample {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    NSArray *const sourceItemsB = @[ @"c" ];
    
    NSArray *const destinationItemsB = @[ @"c", @"a" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItemsA), TableSection(@"b", nil, sourceItemsB) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, destinationItemsB) ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"movements-from-deleted-section" title:@"Movement from deleted section" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowComboInsertionDeletionExample {
    // a, b
    // c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"c", @"b" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+deletion" title:@"Insertion + Deletion" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowComboInsertionReloadExample {
    // a, b
    // c, d, a, e, b', f
    NSArray *const sourceItems = @[ @"a", [[TableExampleItem alloc] initWithIdentifier:@"b" title:@"b"] ];
    NSArray *const destinationItems = @[ @"c", @"d", @"a", @"e", [[TableExampleItem alloc] initWithIdentifier:@"b" title:@"b'"], @"f" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+reload" title:@"Insertion + Reload" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowComboInsertionMovementsExample {
    // a, b, c, d
    // e, c, b, d, f, a
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"e", @"c", @"b", @"d", @"f", @"a" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+movements" title:@"Insertion + Movements" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowComboDeletionReloadExample {
    // a, b, c, d
    // b, d'
    NSArray *const sourceItems = @[ @"a", @"b", @"c", [[TableExampleItem alloc] initWithIdentifier:@"d" title:@"d"] ];
    NSArray *const destinationItems = @[ @"b", [[TableExampleItem alloc] initWithIdentifier:@"d" title:@"d'"] ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"deletion+reload" title:@"Deletion + Reload" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowComboDeletionMovementsExample {
    // a, b, c, d, e
    // b, e, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d", @"e" ];
    NSArray *const destinationItems = @[ @"b", @"e", @"c" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"deletion+movements" title:@"Deletion + Movements" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowComboReloadMovementsExample {
    // a, b, c
    // c, b, a'
    NSArray *const sourceItems = @[ [[TableExampleItem alloc] initWithIdentifier:@"a" title:@"a"], @"b", @"c" ];
    NSArray *const destinationItems = @[ @"c", @"b", [[TableExampleItem alloc] initWithIdentifier:@"a" title:@"a'"] ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"reload+movements" title:@"Reload + Movements" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowComboInsertionDeletionReloadExample {
    // a, b, c
    // a, d, b', e
    NSArray *const sourceItems = @[ @"a", [[TableExampleItem alloc] initWithIdentifier:@"b" title:@"b"], @"c" ];
    NSArray *const destinationItems = @[ @"a", @"d", [[TableExampleItem alloc] initWithIdentifier:@"b" title:@"b'"], @"e" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+deletion+reload" title:@"Insertion + Deletion + Reload" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowComboInsertionDeletionMovementExample {
    // a, b, c
    // b, d, a, e
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"b", @"d", @"a", @"e" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+deletion+movement" title:@"Insertion + Deletion + Movement" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowComboDeletionReloadMovementsExample {
    // a, b, c, d
    // b, a', d
    NSArray *const sourceItems = @[ [[TableExampleItem alloc] initWithIdentifier:@"a" title:@"a"], @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"b", [[TableExampleItem alloc] initWithIdentifier:@"a" title:@"a'"], @"d" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"deletion+reload+movement" title:@"Deletion + Reload + Movement" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newRowComboInsertionDeletionReloadMovementExample {
    // a, b, c
    // b, d, a', e
    NSArray *const sourceItems = @[ [[TableExampleItem alloc] initWithIdentifier:@"a" title:@"a"], @"b", @"c" ];
    NSArray *const destinationItems = @[ @"b", @"d", [[TableExampleItem alloc] initWithIdentifier:@"a" title:@"a'"], @"e" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+deletion+reload+movement" title:@"Insertion + Deletion + Reload + Movement" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

#pragma mark - Private — Section Generation

static inline MUKDataSourceTableSection *TableSection(NSString *identifier, NSString *title, NSArray *items)
{
    return [[MUKDataSourceTableSection alloc] initWithIdentifier:identifier items:items ?: @[@""] headerTitle:[@"Section: " stringByAppendingString:title ?: [identifier uppercaseString]] footerTitle:nil];
}

@end
