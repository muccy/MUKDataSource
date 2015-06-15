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

@interface MUKDataSourceTableUpdateTests : XCTestCase

@end

@implementation MUKDataSourceTableUpdateTests

- (void)testSectionInsertion {
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"b"] ];
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSIndexSet *const insertedSections = [NSIndexSet indexSetWithIndex:1];
    
    XCTAssertEqualObjects(update.insertedSectionIndexes, insertedSections);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionDeletion {
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"d"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"d"] ];
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSIndexSet *const deletedSections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionReload {
    // a, b, c
    // a, b', c'
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a" title:@"A"], [self newSectionWithIdentifier:@"b" title:@"B"], [self newSectionWithIdentifier:@"c" title:@"C"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"a" title:@"A"], [self newSectionWithIdentifier:@"b" title:@"B'"], [self newSectionWithIdentifier:@"c" title:@"C'"] ];
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionMovements {
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"d"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"d"], [self newSectionWithIdentifier:@"a"] ];
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    // 0->3, 2->0
    NSSet *const sectionMovements = [NSSet setWithObjects:[[MUKDataSourceTableUpdateSectionMovement alloc] initWithSourceIndex:0 destinationIndex:3], [[MUKDataSourceTableUpdateSectionMovement alloc] initWithSourceIndex:2 destinationIndex:0], nil ];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.sectionMovements, sectionMovements);
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionDeletion {
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"b"] ];
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSIndexSet *const insertedSections = [NSIndexSet indexSetWithIndex:0];
    NSIndexSet *const deletedSections = [NSIndexSet indexSetWithIndex:0];
    
    XCTAssertEqualObjects(update.insertedSectionIndexes, insertedSections);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionReload {
    // a, b
    // c, d, a, e, b', f
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b" title:@"B"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"d"], [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"e"], [self newSectionWithIdentifier:@"b" title:@"B'"], [self newSectionWithIdentifier:@"f"] ];
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
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
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionMovements {
    // a, b, c, d
    // e, c, b, d, f, a
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"d"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"e"], [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"d"], [self newSectionWithIdentifier:@"f"], [self newSectionWithIdentifier:@"a"] ];
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSMutableIndexSet *const insertedSections = [NSMutableIndexSet indexSetWithIndex:0];
    [insertedSections addIndex:4];
    
    // 0->5, 1->2
    NSSet *const sectionMovements = [NSSet setWithObjects:[[MUKDataSourceTableUpdateSectionMovement alloc] initWithSourceIndex:0 destinationIndex:5], [[MUKDataSourceTableUpdateSectionMovement alloc] initWithSourceIndex:1 destinationIndex:2], nil ];
    
    XCTAssertEqualObjects(update.insertedSectionIndexes, insertedSections);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.sectionMovements, sectionMovements);
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboDeletionReload {
    // a, b, c, d
    // b, d'
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"d"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"d" title:@"D'"] ];
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
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
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboDeletionMovements {
    // a, b, c, d, e
    // b, e, c
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"d"], [self newSectionWithIdentifier:@"e"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"e"], [self newSectionWithIdentifier:@"c"] ];
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSMutableIndexSet *const deletedSections = [NSMutableIndexSet indexSetWithIndex:0];
    [deletedSections addIndex:3];

    // 4->1
    NSSet *const sectionMovements = [NSSet setWithObjects:[[MUKDataSourceTableUpdateSectionMovement alloc] initWithSourceIndex:4 destinationIndex:1], nil ];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.sectionMovements, sectionMovements);
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboReloadMovements {
    // a, b, c
    // c, b, a'
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"c"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"c"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"a" title:@"A'"] ];
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:2];
   
    // 0->2, 2->0
    NSSet *const movements = [NSSet setWithObjects:[[MUKDataSourceTableUpdateSectionMovement alloc] initWithSourceIndex:0 destinationIndex:2], [[MUKDataSourceTableUpdateSectionMovement alloc] initWithSourceIndex:2 destinationIndex:0], nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqualObjects(update.sectionMovements, movements);
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionDeletionReload {
    // a, b, c
    // a, d, b', e
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"c"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"d"], [self newSectionWithIdentifier:@"b" title:@"B'"], [self newSectionWithIdentifier:@"e"] ];
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
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
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionDeletionMovement {
    // a, b, c
    // b, d, a, e
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"c"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"d"], [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"e"] ];
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSMutableIndexSet *const insertedSections = [NSMutableIndexSet indexSetWithIndex:1];
    [insertedSections addIndex:3];
    NSIndexSet *const deletedSections = [NSIndexSet indexSetWithIndex:2];
   
    NSSet *const movements = [NSSet setWithObjects:[[MUKDataSourceTableUpdateSectionMovement alloc] initWithSourceIndex:0 destinationIndex:2], nil];
    
    XCTAssertEqualObjects(update.insertedSectionIndexes, insertedSections);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.sectionMovements, movements);
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionDeletionReloadMovement {
    // a, b, c
    // b, d, a', e
    NSArray *const sourceSections = @[ [self newSectionWithIdentifier:@"a"], [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"c"] ];
    NSArray *const destinationSections = @[ [self newSectionWithIdentifier:@"b"], [self newSectionWithIdentifier:@"d"], [self newSectionWithIdentifier:@"a" title:@"A'"], [self newSectionWithIdentifier:@"e"] ];
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSMutableIndexSet *const insertedSections = [NSMutableIndexSet indexSetWithIndex:1];
    [insertedSections addIndex:3];
    NSIndexSet *const deletedSections = [NSIndexSet indexSetWithIndex:2];
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:2];
    
    NSSet *const movements = [NSSet setWithObjects:[[MUKDataSourceTableUpdateSectionMovement alloc] initWithSourceIndex:0 destinationIndex:2], nil];
    
    XCTAssertEqualObjects(update.insertedSectionIndexes, insertedSections);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqualObjects(update.sectionMovements, movements);
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}


#pragma mark - Private

- (MUKDataSourceTableSection *)newSectionWithIdentifier:(NSString *)identifier {
    return [self newSectionWithIdentifier:identifier title:identifier];
}

- (MUKDataSourceTableSection *)newSectionWithIdentifier:(NSString *)identifier title:(NSString *)title
{
    return [[MUKDataSourceTableSection alloc] initWithIdentifier:identifier items:@[ identifier ] headerTitle:[@"Section: " stringByAppendingString:title] footerTitle:nil];
}

- (UITableView *)newTableViewWithSections:(NSArray *)sections dataSource:(MUKDataSource *)dataSource
{
    UITableView *const tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 568.0f) style:UITableViewStylePlain];
    
    [dataSource setTableSections:sections];
    tableView.dataSource = dataSource;
    
    [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]; // access view to initialize it
    [tableView reloadData];
    
    return tableView;
}

@end
