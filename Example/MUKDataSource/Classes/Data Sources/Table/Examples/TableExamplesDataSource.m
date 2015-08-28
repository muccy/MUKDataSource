//
//  SectionedContentExamplesDataSource.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TableExamplesDataSource.h"
#import "SectionedContentExample.h"
#import "TablePlayground.h"
#import "TablePlaygroundCommand.h"

@implementation TableExamplesDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        MUKDataSourceContentSection *const playgroundSection = [[MUKDataSourceContentSection alloc] initWithIdentifier:@"playground" items:[self newPlaygrounds] header:nil footer:nil];
        MUKDataSourceContentSection *const sectionExamplesSection = [[MUKDataSourceContentSection alloc] initWithIdentifier:@"section-examples" items:[self newSectionExamples] header:@"Section" footer:nil];
        MUKDataSourceContentSection *const rowExamplesSection = [[MUKDataSourceContentSection alloc] initWithIdentifier:@"row-examples" items:[self newRowExamples] header:@"Row" footer:nil];
        [self setTableSections:@[playgroundSection, sectionExamplesSection, rowExamplesSection]];
    }
    
    return self;
}

#pragma mark - Private — Playground

- (NSArray *)newPlaygrounds {
    NSMutableArray *const playgrounds = [NSMutableArray array];
    
    NSArray *commands = @[ [[TablePlaygroundCommand alloc] initWithIdentifier:@"add-row" title:@"Add Row" editingStyle:UITableViewCellEditingStyleInsert action:^(MUKDataSource *dataSource, UITableView *tableView)
    {
        NSUInteger const sectionIndex = (arc4random() % (dataSource.sections.count-1)) + 1;
        MUKDataSourceContentSection *const section = [dataSource sectionAtIndex:sectionIndex];
        
        NSUInteger const rowIndex = arc4random() % section.items.count;
        MUKDataSourceContentSection *const newSection = [section sectionByInsertingItem:[NSString stringWithFormat:@"%.0f", [NSDate timeIntervalSinceReferenceDate]] atIndex:rowIndex];
        
        NSMutableArray *const sections = [dataSource.sections mutableCopy];
        [sections replaceObjectAtIndex:sectionIndex withObject:newSection];
        
        MUKDataSourceTableUpdate *const update = [dataSource setTableSections:sections];
        [update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation automaticAnimation]];
    }]];
    
    TablePlayground *playground = [[TablePlayground alloc] initWithIdentifier:@"playground" title:@"Playground" commands:commands];
    [playgrounds addObject:playground];
    
    return [playgrounds copy];
}

#pragma mark - Private – Section Examples

- (NSArray *)newSectionExamples {
    NSMutableArray *const examples = [NSMutableArray array];
    
    [examples addObject:[self newSectionInsertionExample]];
    [examples addObject:[self newSectionInsertionFromEmptyExample]];
    [examples addObject:[self newSectionDeletionExample]];
    [examples addObject:[self newSectionDeletionToEmptyExample]];
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

- (SectionedContentExample *)newSectionInsertionExample {
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"c", nil, nil), TableSection(@"b", nil, nil) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"insertion" title:@"Insertion" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newSectionInsertionFromEmptyExample {
    NSArray *const sourceSections = nil;
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"c", nil, nil), TableSection(@"b", nil, nil) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"insertion-from-empty" title:@"Insertion (from empty)" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newSectionDeletionExample {
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"d", nil, nil) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"deletion" title:@"Deletion" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newSectionDeletionToEmptyExample {
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = nil;
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"deletion-to-empty" title:@"Deletion (to empty)" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newSectionReloadExample {
    // a, b, c
    // a, b', c'
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", @"B'", nil), TableSection(@"c", nil, nil) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"reload" title:@"Reload" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newSectionMovementsExample {
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"c", nil, nil), TableSection(@"b", nil, nil), TableSection(@"d", nil, nil), TableSection(@"a", nil, nil) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"movements" title:@"Movements" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newSectionComboInsertionDeletionExample {
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"c", nil, nil), TableSection(@"b", nil, nil) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"insertion+deletion" title:@"Insertion + Deletion" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newSectionComboInsertionReloadExample {
    // a, b
    // c, d, a, e, b', f
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"c", nil, nil), TableSection(@"d", nil, nil), TableSection(@"a", nil, nil), TableSection(@"e", nil, nil), TableSection(@"b", @"B'", nil), TableSection(@"f", nil, nil) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"insertion+reload" title:@"Insertion + Reload" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newSectionComboInsertionMovementsExample {
    // a, b, c, d
    // e, c, b, d, f, a
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"e", nil, nil), TableSection(@"c", nil, nil), TableSection(@"b", nil, nil), TableSection(@"d", nil, nil), TableSection(@"f", nil, nil), TableSection(@"a", nil, nil) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"insertion+movements" title:@"Insertion + Movements" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newSectionComboDeletionReloadExample {
    // a, b, c, d
    // b, d'
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"d", @"D'", nil) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"deletion+reload" title:@"Deletion + Reload" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newSectionComboReloadMovementsExample {
    // a, b, c
    // c, b, a'
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"c", nil, nil), TableSection(@"b", nil, nil), TableSection(@"a", @"A'", nil) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"reload+movements" title:@"Reload + Movements" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newSectionComboDeletionMovementsExample {
    // a, b, c, d, e
    // b, e, c
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil), TableSection(@"e", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"e", nil, nil), TableSection(@"c", nil, nil) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"deletion+movements" title:@"Deletion + Movements" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newSectionComboInsertionDeletionReloadExample {
    // a, b, c
    // a, d, b', e
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"d", nil, nil), TableSection(@"b", @"B'", nil), TableSection(@"e", nil, nil) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"insertion+deletion+reload" title:@"Insertion + Deletion + Reload" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newSectionComboInsertionDeletionMovementsExample {
    // a, b, c
    // b, d, a, e
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"d", nil, nil), TableSection(@"a", nil, nil), TableSection(@"e", nil, nil) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"insertion+deletion+movements" title:@"Insertion + Deletion + Movements" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newSectionComboDeletionReloadMovementsExample {
    // a, b, c, d
    // b, a', d
    NSArray *const sourceSections = @[ TableSection(@"a", @"a", nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"a", @"a'", nil), TableSection(@"d", nil, nil) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"deletion+reload+movements" title:@"Deletion + Reload + Movements" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newSectionComboInsertionDeletionReloadMovementExample {
    // a, b, c
    // b, d, a', e
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"d", nil, nil), TableSection(@"a", @"A'", nil), TableSection(@"e", nil, nil) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"insertion+deletion+reload+movements" title:@"Insertion + Deletion + Reload + Movements" sourceSections:sourceSections destinationSections:destinationSections];
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

- (SectionedContentExample *)newRowInsertionExample {
    // a, b
    // a, c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"a", @"c", @"b" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"insertion" title:@"Insertion" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowInsertionWithSectionReloadExample {
    // a, b
    // a, c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"a", @"c", @"b" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", @"A'", destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"insertion+section-reload" title:@"Insertion (with section reload)" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowInsertionWithSectionMovementExample {
    // a, b
    // a, c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"a", @"c", @"b" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItems), TableSection(@"b", nil, nil)];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"a", nil, destinationItems) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"insertion+section-movement" title:@"Insertion (with section movement)" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowDeletionExample {
    // a, b, c
    // a, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"a", @"c" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"deletion" title:@"Deletion" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowDeletionWithSectionReloadExample {
    // a, b, c
    // a, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"a", @"c" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", @"A'", destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"deletion+section-reload" title:@"Deletion (with section reload)" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowDeletionWithSectionMovementExample {
    // a, b, c
    // a, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"a", @"c" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItems), TableSection(@"b", nil, nil)];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"a", nil, destinationItems) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"deletion+section-movement" title:@"Deletion (with section movement)" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowReloadExample {
    // a, b, c
    // a, b', c
    NSArray *const sourceItems = @[ @"a", [[Item alloc] initWithIdentifier:@"b" title:@"b"], @"c" ];
    NSArray *const destinationItems = @[ @"a", [[Item alloc] initWithIdentifier:@"b" title:@"b'"], @"c" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"reload" title:@"Reload" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowReloadWithSectionReloadExample {
    // a, b, c
    // a, b', c
    NSArray *const sourceItems = @[ @"a", [[Item alloc] initWithIdentifier:@"b" title:@"b"], @"c" ];
    NSArray *const destinationItems = @[ @"a", [[Item alloc] initWithIdentifier:@"b" title:@"b'"], @"c" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", @"A'", destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"reload+section-reload" title:@"Reload (with section reload)" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowReloadWithSectionMovementExample {
    // a, b, c
    // a, b', c
    NSArray *const sourceItems = @[ @"a", [[Item alloc] initWithIdentifier:@"b" title:@"b"], @"c" ];
    NSArray *const destinationItems = @[ @"a", [[Item alloc] initWithIdentifier:@"b" title:@"b'"], @"c" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItems), TableSection(@"b", nil, nil)];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"a", nil, destinationItems) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"reload+section-movement" title:@"Reload (with section movement)" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowMovementsExample {
    // a, b, c, d
    // c, a, d, b
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"c", @"a", @"d", @"b" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"movements" title:@"Movements" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowMovementsBetweenSectionsExample {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    NSArray *const sourceItemsB = @[ @"c", @"d", @"e", @"f" ];
    
    NSArray *const destinationItemsA = @[ @"c", @"b", @"f", @"d" ];
    NSArray *const destinationItemsB = @[ @"a", @"e" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItemsA), TableSection(@"b", nil, sourceItemsB) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, destinationItemsA), TableSection(@"b", nil, destinationItemsB) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"movements-between-sections" title:@"Movements between sections" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowMovementsWithSectionReloadExample {
    // a, b, c, d
    // c, a, d, b
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"c", @"a", @"d", @"b" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", @"A", sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", @"A'", destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"movements+section-reload" title:@"Movements (with section reload)" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowMovementsWithSectionMovementExample {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    NSArray *const sourceItemsB = @[ @"c", @"d" ];
    NSArray *const sourceItemsC = @[ @"e", @"f" ];
    
    NSArray *const destinationItemsA = @[ @"b" ];
    NSArray *const destinationItemsC = @[ @"e", @"f" ];
    NSArray *const destinationItemsB = @[ @"c", @"a", @"d" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItemsA), TableSection(@"b", nil, sourceItemsB), TableSection(@"c", nil, sourceItemsC) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, destinationItemsA), TableSection(@"c", nil, destinationItemsC), TableSection(@"b", nil, destinationItemsB) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"movements+section-movement" title:@"Movements (with section movement)" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowMovementsToInsertedSectionExample {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    
    NSArray *const destinationItemsA = @[ @"b" ];
    NSArray *const destinationItemsB = @[ @"c", @"a" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItemsA) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, destinationItemsA), TableSection(@"b", nil, destinationItemsB) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"movements-to-inserted-section" title:@"Movement to inserted section" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowMovementsFromDeletedSectionExample {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    NSArray *const sourceItemsB = @[ @"c" ];
    
    NSArray *const destinationItemsB = @[ @"c", @"a" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItemsA), TableSection(@"b", nil, sourceItemsB) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, destinationItemsB) ];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"movements-from-deleted-section" title:@"Movement from deleted section" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowComboInsertionDeletionExample {
    // a, b
    // c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"c", @"b" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"insertion+deletion" title:@"Insertion + Deletion" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowComboInsertionReloadExample {
    // a, b
    // c, d, a, e, b', f
    NSArray *const sourceItems = @[ @"a", [[Item alloc] initWithIdentifier:@"b" title:@"b"] ];
    NSArray *const destinationItems = @[ @"c", @"d", @"a", @"e", [[Item alloc] initWithIdentifier:@"b" title:@"b'"], @"f" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"insertion+reload" title:@"Insertion + Reload" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowComboInsertionMovementsExample {
    // a, b, c, d
    // e, c, b, d, f, a
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"e", @"c", @"b", @"d", @"f", @"a" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"insertion+movements" title:@"Insertion + Movements" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowComboDeletionReloadExample {
    // a, b, c, d
    // b, d'
    NSArray *const sourceItems = @[ @"a", @"b", @"c", [[Item alloc] initWithIdentifier:@"d" title:@"d"] ];
    NSArray *const destinationItems = @[ @"b", [[Item alloc] initWithIdentifier:@"d" title:@"d'"] ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"deletion+reload" title:@"Deletion + Reload" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowComboDeletionMovementsExample {
    // a, b, c, d, e
    // b, e, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d", @"e" ];
    NSArray *const destinationItems = @[ @"b", @"e", @"c" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"deletion+movements" title:@"Deletion + Movements" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowComboReloadMovementsExample {
    // a, b, c
    // c, b, a'
    NSArray *const sourceItems = @[ [[Item alloc] initWithIdentifier:@"a" title:@"a"], @"b", @"c" ];
    NSArray *const destinationItems = @[ @"c", @"b", [[Item alloc] initWithIdentifier:@"a" title:@"a'"] ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"reload+movements" title:@"Reload + Movements" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowComboInsertionDeletionReloadExample {
    // a, b, c
    // a, d, b', e
    NSArray *const sourceItems = @[ @"a", [[Item alloc] initWithIdentifier:@"b" title:@"b"], @"c" ];
    NSArray *const destinationItems = @[ @"a", @"d", [[Item alloc] initWithIdentifier:@"b" title:@"b'"], @"e" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"insertion+deletion+reload" title:@"Insertion + Deletion + Reload" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowComboInsertionDeletionMovementExample {
    // a, b, c
    // b, d, a, e
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"b", @"d", @"a", @"e" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"insertion+deletion+movement" title:@"Insertion + Deletion + Movement" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowComboDeletionReloadMovementsExample {
    // a, b, c, d
    // b, a', d
    NSArray *const sourceItems = @[ [[Item alloc] initWithIdentifier:@"a" title:@"a"], @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"b", [[Item alloc] initWithIdentifier:@"a" title:@"a'"], @"d" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"deletion+reload+movement" title:@"Deletion + Reload + Movement" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

- (SectionedContentExample *)newRowComboInsertionDeletionReloadMovementExample {
    // a, b, c
    // b, d, a', e
    NSArray *const sourceItems = @[ [[Item alloc] initWithIdentifier:@"a" title:@"a"], @"b", @"c" ];
    NSArray *const destinationItems = @[ @"b", @"d", [[Item alloc] initWithIdentifier:@"a" title:@"a'"], @"e" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    SectionedContentExample *const example = [[SectionedContentExample alloc] initWithIdentifier:@"insertion+deletion+reload+movement" title:@"Insertion + Deletion + Reload + Movement" sourceSections:sourceSections destinationSections:destinationSections];
    return example;
}

#pragma mark - Private — Section Generation

static inline MUKDataSourceContentSection *TableSection(NSString *identifier, NSString *title, NSArray *items)
{
    return [[MUKDataSourceContentSection alloc] initWithIdentifier:identifier items:items ?: @[@""] header:[@"Section: " stringByAppendingString:title ?: [identifier uppercaseString]] footer:nil];
}

@end
