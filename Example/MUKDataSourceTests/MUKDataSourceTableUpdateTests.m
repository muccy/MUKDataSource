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

@interface BasicItem : NSObject <MUKDataSourceIdentifiable>
@property (nonatomic, readonly, copy) NSString *title;
@end

@implementation BasicItem
@synthesize identifier = _identifier;

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title
{
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
        _title = [title copy];
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self.identifier isEqual:((BasicItem *)object).identifier] &&
        [self.title isEqualToString:((BasicItem *)object).title];
    }
    
    return self;
}

- (NSUInteger)hash {
    return 843 ^ [self.identifier hash] ^ [self.title hash];
}

@end

#pragma mark -

@interface MUKDataSourceTableUpdateTests : XCTestCase

@end

@implementation MUKDataSourceTableUpdateTests

- (void)testSectionInsertion {
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"c", nil, nil), TableSection(@"b", nil, nil) ];
    
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
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionDeletion {
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"d", nil, nil) ];
    
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
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionReload {
    // a, b, c
    // a, b', c'
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", @"B'", nil), TableSection(@"c", @"C'", nil) ];
    
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
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionMovements {
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"c", nil, nil), TableSection(@"b", nil, nil), TableSection(@"d", nil, nil), TableSection(@"a", nil, nil) ];
    
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
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionDeletion {
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"c", nil, nil), TableSection(@"b", nil, nil) ];
    
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
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionReload {
    // a, b
    // c, d, a, e, b', f
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"c", nil, nil), TableSection(@"d", nil, nil), TableSection(@"a", nil, nil), TableSection(@"e", nil, nil), TableSection(@"b", @"B'", nil), TableSection(@"f", nil, nil) ];
    
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
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionMovements {
    // a, b, c, d
    // e, c, b, d, f, a
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"e", nil, nil), TableSection(@"c", nil, nil), TableSection(@"b", nil, nil), TableSection(@"d", nil, nil), TableSection(@"f", nil, nil), TableSection(@"a", nil, nil) ];
    
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
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboDeletionReload {
    // a, b, c, d
    // b, d'
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"d", @"D'", nil) ];
    
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
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboDeletionMovements {
    // a, b, c, d, e
    // b, e, c
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil), TableSection(@"d", nil, nil), TableSection(@"e", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"e", nil, nil), TableSection(@"c", nil, nil) ];
    
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
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboReloadMovements {
    // a, b, c
    // c, b, a'
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"c", nil, nil), TableSection(@"b", nil, nil), TableSection(@"a", @"A'", nil) ];
    
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
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionDeletionReload {
    // a, b, c
    // a, d, b', e
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"d", nil, nil), TableSection(@"b", @"B'", nil), TableSection(@"e", nil, nil) ];
    
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
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionDeletionMovement {
    // a, b, c
    // b, d, a, e
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"d", nil, nil), TableSection(@"a", nil, nil), TableSection(@"e", nil, nil) ];
    
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
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionDeletionReloadMovement {
    // a, b, c
    // b, d, a', e
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"b", nil, nil), TableSection(@"d", nil, nil), TableSection(@"a", @"A'", nil), TableSection(@"e", nil, nil) ];
    
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
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
}

- (void)testNotReloadedChangedSection {
    // a, b, c
    // a, b', c*
    NSArray *const sourceSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", nil, nil), TableSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ TableSection(@"a", nil, nil), TableSection(@"b", @"B'", nil), TableSection(@"c", nil, @[@"New item!"]) ];
    
    MUKDataSourceTableUpdate *const update = [[MUKDataSourceTableUpdate alloc] initWithSourceTableSections:sourceSections destinationTableSections:destinationSections];
    
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
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSSet *const insertedRowIndexPaths = [NSSet setWithObjects:[NSIndexPath indexPathForRow:1 inSection:0], nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedRowIndexPaths, insertedRowIndexPaths);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
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
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:0];
    NSSet *const insertedRowIndexPaths = [NSSet setWithObjects:[NSIndexPath indexPathForRow:1 inSection:0], nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedRowIndexPaths, insertedRowIndexPaths);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
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
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];

    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssert(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
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
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSSet *const deletedRowIndexPaths = [NSSet setWithObjects:[NSIndexPath indexPathForRow:1 inSection:0], nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqualObjects(update.deletedRowIndexPaths, deletedRowIndexPaths);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
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
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:0];
    NSSet *const deletedRowIndexPaths = [NSSet setWithObjects:[NSIndexPath indexPathForRow:1 inSection:0], nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqualObjects(update.deletedRowIndexPaths, deletedRowIndexPaths);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
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
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];

    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedRowIndexPaths.count, 0);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssert(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
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
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSSet *const reloadedRowIndexPaths = [NSSet setWithObjects:[NSIndexPath indexPathForRow:1 inSection:0], nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqualObjects(update.reloadedRowIndexPaths, reloadedRowIndexPaths);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
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
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:0];
    NSSet *const reloadedRowIndexPaths = [NSSet setWithObjects:[NSIndexPath indexPathForRow:1 inSection:0], nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqualObjects(update.reloadedRowIndexPaths, reloadedRowIndexPaths);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
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
    
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    UITableView *const tableView = [self newTableViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([tableView numberOfSections], sourceSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:0], sourceItems.count);
    
    MUKDataSourceTableUpdate *const update = [dataSource setTableSections:destinationSections];
    
    NSSet *const sectionMovements = [NSSet setWithObjects:[[MUKDataSourceTableUpdateSectionMovement alloc] initWithSourceIndex:0 destinationIndex:1], nil];
    NSSet *const reloadedRowIndexPaths = [NSSet setWithObjects:[NSIndexPath indexPathForRow:1 inSection:1], nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.sectionMovements, sectionMovements);
    
    XCTAssertEqual(update.insertedRowIndexPaths.count, 0);
    XCTAssertEqual(update.deletedRowIndexPaths.count, 0);
    XCTAssertEqualObjects(update.reloadedRowIndexPaths, reloadedRowIndexPaths);
    XCTAssertEqual(update.rowMovements.count, 0);
    
    XCTAssertFalse(update.needsReloadData);
    
    XCTAssertNoThrow([update applyToTableView:tableView animated:NO]);
    XCTAssertEqual([tableView numberOfSections], destinationSections.count);
    XCTAssertEqual([tableView numberOfRowsInSection:1], destinationItems.count);
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

@end
