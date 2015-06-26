//
//  MUKDataSourceTableUpdateTests.m
//  MUKDataSource
//
//  Created by Marco on 14/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <MUKDataSource/MUKDataSource.h>
#import "BasicItem.h"

@interface BasicDataSource : MUKDataSource
@end

@implementation BasicDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[UITableViewCell alloc] init];
}

@end

#pragma mark -

@interface MUKDataSourceTableUpdateTests : XCTestCase
@end

@implementation MUKDataSourceTableUpdateTests

- (void)testSectionInsertion {
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"c", nil, nil), TableSection(@"b", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionDeletion {
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"d", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionReload {
    // a, b, c
    // a, b', c'
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", @"B'", nil), TableSection(@"c", @"C'", nil) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionMovements {
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"c", nil, nil), TableSection(@"b", nil, nil), TableSection(@"d", nil, nil), TableSection(@"a", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionDeletion {
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"c", nil, nil), TableSection(@"b", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionReload {
    // a, b
    // c, d, a, e, b', f
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"c", nil, nil), TableSection(@"d", nil, nil), TableSection(@"a", nil, nil), TableSection(@"e", nil, nil), TableSection(@"b", @"B'", nil), TableSection(@"f", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSMutableIndexSet *const insertedSections = [NSMutableIndexSet indexSet];
    [insertedSections addIndex:0];
    [insertedSections addIndex:1];
    [insertedSections addIndex:3];
    [insertedSections addIndex:5];
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:4];
    
    XCTAssertEqualObjects(update.insertedSectionIndexes, insertedSections);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionMovements {
    // a, b, c, d
    // e, c, b, d, f, a
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"e", nil, nil), TableSection(@"c", nil, nil), TableSection(@"b", nil, nil), TableSection(@"d", nil, nil), TableSection(@"f", nil, nil), TableSection(@"a", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboDeletionReload {
    // a, b, c, d
    // b, d'
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"d", @"D'", nil) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSMutableIndexSet *const deletedSections = [NSMutableIndexSet indexSetWithIndex:0];
    [deletedSections addIndex:2];
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:1];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboDeletionMovements {
    // a, b, c, d, e
    // b, e, c
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil), TableSection(@"e", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"e", nil, nil), TableSection(@"c", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboReloadMovements {
    // a, b, c
    // c, b, a'
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"c", nil, nil), TableSection(@"b", nil, nil), TableSection(@"a", @"A'", nil) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:2];
    
    // 0->2, 2->0
    NSSet *const movements = [NSSet setWithObjects:[[MUKDataSourceContentSectionMovement alloc] initWithSourceIndex:0 destinationIndex:2], [[MUKDataSourceContentSectionMovement alloc] initWithSourceIndex:2 destinationIndex:0], nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqualObjects(update.sectionMovements, movements);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionDeletionReload {
    // a, b, c
    // a, d, b', e
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"d", nil, nil), TableSection(@"b", @"B'", nil), TableSection(@"e", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSMutableIndexSet *const insertedSections = [NSMutableIndexSet indexSetWithIndex:1];
    [insertedSections addIndex:3];
    NSIndexSet *const deletedSections = [NSIndexSet indexSetWithIndex:2];
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:2];
    
    XCTAssertEqualObjects(update.insertedSectionIndexes, insertedSections);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionDeletionMovement {
    // a, b, c
    // b, d, a, e
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"d", nil, nil), TableSection(@"a", nil, nil), TableSection(@"e", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboDeletionReloadMovement {
    // a, b, c, d
    // b, a', d
    NSArray *const sourceSections = @[ TableSection(@"a", @"a", nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"a", @"a'", nil), TableSection(@"d", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSIndexSet *const deletedSections = [NSIndexSet indexSetWithIndex:2];
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:1];
    
    NSSet *const movements = [NSSet setWithObjects:[[MUKDataSourceContentSectionMovement alloc] initWithSourceIndex:0 destinationIndex:1], nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqualObjects(update.sectionMovements, movements);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionDeletionReloadMovement {
    // a, b, c
    // b, d, a', e
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"d", nil, nil), TableSection(@"a", @"A'", nil), TableSection(@"e", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSMutableIndexSet *const insertedSections = [NSMutableIndexSet indexSetWithIndex:1];
    [insertedSections addIndex:3];
    NSIndexSet *const deletedSections = [NSIndexSet indexSetWithIndex:2];
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:2];
    
    NSSet *const movements = [NSSet setWithObjects:[[MUKDataSourceContentSectionMovement alloc] initWithSourceIndex:0 destinationIndex:2], nil];
    
    XCTAssertEqualObjects(update.insertedSectionIndexes, insertedSections);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqualObjects(update.sectionMovements, movements);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testNotReloadedChangedSection {
    // a, b, c
    // a, b', c*
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", @"B'", nil), TableSection(@"c", nil, @[@"New item!"]) ];
    
    MUKDataSourceTableUpdate *const update = [[MUKDataSourceTableUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:1];
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
}

- (void)testRowInsertion {
    // a, b
    // a, c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"a", @"c", @"b" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

- (void)testRowInsertionWithSectionReload {
    // a, b
    // a, c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"a", @"c", @"b" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", @"A'", destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:0];
    NSSet *const insertedItemIndexPaths = [NSSet setWithObjects:IndexPathWithRow(1), nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedItemIndexPaths, insertedItemIndexPaths);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

- (void)testRowInsertionWithSectionMovement {
    // a, b
    // a, c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"a", @"c", @"b" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItems), TableSection(@"b", nil, nil)];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"a", nil, destinationItems) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];

    XCTAssert(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:1], destinationItems.count);
}

- (void)testRowDeletion {
    // a, b, c
    // a, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"a", @"c" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

- (void)testRowDeletionWithSectionReload {
    // a, b, c
    // a, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"a", @"c" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", @"A'", destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:0];
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithRow(1), nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

- (void)testRowDeletionWithSectionMovement {
    // a, b, c
    // a, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"a", @"c" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItems), TableSection(@"b", nil, nil)];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"a", nil, destinationItems) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];

    XCTAssert(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:1], destinationItems.count);
}

- (void)testRowReload {
    // a, b, c
    // a, b', c
    NSArray *const sourceItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"B"], @"c" ];
    NSArray *const destinationItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"B'"], @"c" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithRow(1), nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqual(update.itemMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

- (void)testRowReloadWithSectionReload {
    // a, b, c
    // a, b', c
    NSArray *const sourceItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"B"], @"c" ];
    NSArray *const destinationItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"B'"], @"c" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", @"A'", destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:0];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithRow(1), nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqual(update.itemMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

- (void)testRowReloadWithSectionMovement {
    // a, b, c
    // a, b', c
    NSArray *const sourceItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"B"], @"c" ];
    NSArray *const destinationItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"B'"], @"c" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItems), TableSection(@"b", nil, nil)];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"a", nil, destinationItems) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:1], destinationItems.count);
}

- (void)testRowMovements {
    // a, b, c, d
    // c, a, d, b
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"c", @"a", @"d", @"b" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

- (void)testRowMovementBetweenSections {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    NSArray *const sourceItemsB = @[ @"c", @"d", @"e", @"f" ];
    
    NSArray *const destinationItemsA = @[ @"c", @"b", @"f", @"d" ];
    NSArray *const destinationItemsB = @[ @"a", @"e" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItemsA), TableSection(@"b", nil, sourceItemsB) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, destinationItemsA), TableSection(@"b", nil, destinationItemsB) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItemsA.count);
    XCTAssertEqual([tableView numberOfRowsInSection:1], sourceItemsB.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItemsA.count);
    XCTAssertEqual([tableView numberOfRowsInSection:1], destinationItemsB.count);
}

- (void)testRowMovementsWithSectionReload {
    // a, b, c, d
    // c, a, d, b
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"c", @"a", @"d", @"b" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", @"A", sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", @"A'", destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    // 0->1, 1->3
    NSSet *const itemMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithRow(0) destinationIndexPath:IndexPathWithRow(1)], [[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithRow(1) destinationIndexPath:IndexPathWithRow(3)], nil];
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:0];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.itemMovements, itemMovements);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

- (void)testRowMovementWithSectionMovement {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    NSArray *const sourceItemsB = @[ @"c", @"d" ];
    NSArray *const sourceItemsC = @[ @"e", @"f" ];
    
    NSArray *const destinationItemsA = @[ @"b" ];
    NSArray *const destinationItemsC = @[ @"e", @"f" ];
    NSArray *const destinationItemsB = @[ @"c", @"a", @"d" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItemsA), TableSection(@"b", nil, sourceItemsB), TableSection(@"c", nil, sourceItemsC) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, destinationItemsA), TableSection(@"c", nil, destinationItemsC), TableSection(@"b", nil, destinationItemsB) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItemsA.count);
    XCTAssertEqual([tableView numberOfRowsInSection:1], sourceItemsB.count);
    XCTAssertEqual([tableView numberOfRowsInSection:2], sourceItemsC.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];

    XCTAssert(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItemsA.count);
    XCTAssertEqual([tableView numberOfRowsInSection:1], destinationItemsC.count);
    XCTAssertEqual([tableView numberOfRowsInSection:2], destinationItemsB.count);
}

- (void)testRowMovementToInsertedSection {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    
    NSArray *const destinationItemsA = @[ @"b" ];
    NSArray *const destinationItemsB = @[ @"c", @"a" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItemsA) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, destinationItemsA), TableSection(@"b", nil, destinationItemsB) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItemsA.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItemsA.count);
    XCTAssertEqual([tableView numberOfRowsInSection:1], destinationItemsB.count);
}

- (void)testRowMovementFromDeletedSection {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    NSArray *const sourceItemsB = @[ @"c" ];
    
    NSArray *const destinationItemsB = @[ @"c", @"a" ];
    
    NSArray *const sourceSections = @[ TableSection(@"a", nil, sourceItemsA), TableSection(@"b", nil, sourceItemsB) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, destinationItemsB) ];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItemsA.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItemsB.count);
}

- (void)testRowComboInsertionDeletion {
    // a, b
    // c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"c", @"b" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

- (void)testRowComboInsertionReload {
    // a, b
    // c, d, a, e, b', f
    NSArray *const sourceItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"b"] ];
    NSArray *const destinationItems = @[ @"c", @"d", @"a", @"e", [[BasicItem alloc] initWithIdentifier:@"b" title:@"b'"], @"f" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSSet *const insertedItemIndexPaths = [NSSet setWithObjects:IndexPathWithRow(0), IndexPathWithRow(1), IndexPathWithRow(3), IndexPathWithRow(5), nil];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithRow(4), nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedItemIndexPaths, insertedItemIndexPaths);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqual(update.itemMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

- (void)testRowComboInsertionMovements {
    // a, b, c, d
    // e, c, b, d, f, a
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"e", @"c", @"b", @"d", @"f", @"a" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

- (void)testRowComboDeletionReload {
    // a, b, c, d
    // b, d'
    NSArray *const sourceItems = @[ @"a", @"b", @"c", [[BasicItem alloc] initWithIdentifier:@"d" title:@"d"] ];
    NSArray *const destinationItems = @[ @"b", [[BasicItem alloc] initWithIdentifier:@"d" title:@"d'"] ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithRow(0), IndexPathWithRow(2), nil];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithRow(1), nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqual(update.itemMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

- (void)testRowComboDeletionMovements {
    // a, b, c, d, e
    // b, e, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d", @"e" ];
    NSArray *const destinationItems = @[ @"b", @"e", @"c" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

- (void)testRowComboReloadMovements {
    // a, b, c
    // c, b, a'
    NSArray *const sourceItems = @[ [[BasicItem alloc] initWithIdentifier:@"a" title:@"a"], @"b", @"c" ];
    NSArray *const destinationItems = @[ @"c", @"b", [[BasicItem alloc] initWithIdentifier:@"a" title:@"a'"] ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithRow(2), nil];
    NSSet *const itemMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithRow(0) destinationIndexPath:IndexPathWithRow(2)], [[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithRow(2) destinationIndexPath:IndexPathWithRow(0)], nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqualObjects(update.itemMovements, itemMovements);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

- (void)testRowComboInsertionDeletionReload {
    // a, b, c
    // a, d, b', e
    NSArray *const sourceItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"b"], @"c" ];
    NSArray *const destinationItems = @[ @"a", @"d", [[BasicItem alloc] initWithIdentifier:@"b" title:@"b'"], @"e" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSSet *const insertedItemIndexPaths = [NSSet setWithObjects:IndexPathWithRow(1), IndexPathWithRow(3), nil];
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithRow(2), nil];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithRow(2), nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedItemIndexPaths, insertedItemIndexPaths);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqual(update.itemMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

- (void)testRowComboInsertionDeletionMovement {
    // a, b, c
    // b, d, a, e
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"b", @"d", @"a", @"e" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

- (void)testRowComboDeletionReloadMovement {
    // a, b, c, d
    // b, a', d
    NSArray *const sourceItems = @[ [[BasicItem alloc] initWithIdentifier:@"a" title:@"a"], @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"b", [[BasicItem alloc] initWithIdentifier:@"a" title:@"a'"], @"d" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithRow(2), nil];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithRow(1), nil];
    NSSet *const itemMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithRow(0) destinationIndexPath:IndexPathWithRow(1)], nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqualObjects(update.itemMovements, itemMovements);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

- (void)testRowComboInsertionDeletionReloadMovement {
    // a, b, c
    // b, d, a', e
    NSArray *const sourceItems = @[ [[BasicItem alloc] initWithIdentifier:@"a" title:@"a"], @"b", @"c" ];
    NSArray *const destinationItems = @[ @"b", @"d", [[BasicItem alloc] initWithIdentifier:@"a" title:@"a'"], @"e" ];
    
    NSArray *const sourceSections = @[TableSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[TableSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSSet *const insertedItemIndexPaths = [NSSet setWithObjects:IndexPathWithRow(1), IndexPathWithRow(3), nil];
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithRow(2), nil];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithRow(2), nil];
    NSSet *const itemMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithRow(0) destinationIndexPath:IndexPathWithRow(2)], nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedItemIndexPaths, insertedItemIndexPaths);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqualObjects(update.itemMovements, itemMovements);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView withAnimation:[MUKDataSourceTableUpdateAnimation defaultAnimation]]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], destinationItems.count);
}

#pragma mark - Private

- (UITableView *)newTableViewWithSections:(NSArray *)sections dataSource:(MUKDataSource *)dataSource
{
    UITableView *const tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 568.0f) style:UITableViewStylePlain];
    
    [dataSource setTableSections:sections];
    tableView.dataSource = dataSource;
    
    [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]; // access view to initialize it
    [tableView reloadData];
    
    return tableView;
}

static inline MUKDataSourceTableSection *TableSection(NSString *identifier, NSString *title, NSArray *items)
{
    return [[MUKDataSourceTableSection alloc] initWithIdentifier:identifier items:items ?: @[@""] headerTitle:[@"Section: " stringByAppendingString:title ?: [identifier uppercaseString]] footerTitle:nil];
}

static inline NSIndexPath *IndexPathWithRow(NSUInteger row) {
    return IndexPath(0, row);
}

static inline NSIndexPath *IndexPath(NSUInteger section, NSUInteger row) {
    return [NSIndexPath indexPathForRow:row inSection:section];
}

@end
