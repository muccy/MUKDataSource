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
        [self setTableSections:@[sectionExamplesSection]];
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
    [examples addObject:[self newSectionComboInsertionDeletionReloadExample]];
    
    return [examples copy];
}

- (TableExample *)newSectionInsertionExample {
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"b"] ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion" title:@"Insertion" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionDeletionExample {
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"d"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"d"] ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"deletion" title:@"Deletion" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionReloadExample {
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a" title:@"A"], [self newSectionWithIdentifier:@"b" title:@"B"], [self newSectionWithIdentifier:@"c" title:@"C"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"a" title:@"A"], [self newSectionWithIdentifier:@"b" title:@"B'"], [self newSectionWithIdentifier:@"c" title:@"C'"] ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"reload" title:@"Reload" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionMovementsExample {
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"d"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"d"], [self newSectionWithIdentifier:@"a"] ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"movements" title:@"Movements" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionComboInsertionDeletionExample {
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"b"] ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+deletion" title:@"Insertion + Deletion" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionComboInsertionReloadExample {
    // a, b
    // c, d, a, e, b', f
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b" title:@"B"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"d"], [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"e"], [self newSectionWithIdentifier:@"b" title:@"B'"], [self newSectionWithIdentifier:@"f"] ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+reload" title:@"Insertion + Reload" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionComboInsertionMovementsExample {
    // a, b, c, d
    // e, c, b, d, f, a
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"d"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"e"], [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"d"], [self newSectionWithIdentifier:@"f"], [self newSectionWithIdentifier:@"a"] ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+movements" title:@"Insertion + Movements" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionComboDeletionReloadExample {
    // a, b, c, d
    // b, d'
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"d"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"d" title:@"D'"] ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"deletion+reload" title:@"Deletion + Reload" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionComboDeletionMovementsExample {
    // a, b, c, d, e
    // b, e, c
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"d"], [self newSectionWithIdentifier:@"e"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"e"], [self newSectionWithIdentifier:@"c"] ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"deletion+movements" title:@"Deletion + Movements" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

- (TableExample *)newSectionComboInsertionDeletionReloadExample {
    // a, b, c
    // a, d, b', e
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"c"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"d"], [self newSectionWithIdentifier:@"b" title:@"B'"], [self newSectionWithIdentifier:@"e"] ];
    
    TableExample *const example = [[TableExample alloc] initWithIdentifier:@"insertion+deletion+reload" title:@"Insertion + Deletion + Reload" sourceTableSections:sourceSections destinationTableSections:destinationSections];
    return example;
}

#pragma mark - Private — Section Generation

- (MUKDataSourceTableSection *)newSectionWithIdentifier:(NSString *)identifier {
    return [self newSectionWithIdentifier:identifier title:[identifier uppercaseString]];
}
                                   
- (MUKDataSourceTableSection *)newSectionWithIdentifier:(NSString *)identifier title:(NSString *)title
{
    return [[MUKDataSourceTableSection alloc] initWithIdentifier:identifier items:@[ @"" ] headerTitle:[@"Section: " stringByAppendingString:title] footerTitle:nil];
}

@end
