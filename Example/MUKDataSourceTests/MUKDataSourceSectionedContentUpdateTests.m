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

@interface MUKDataSourceSectionedContentUpdateTests : XCTestCase
@end

@implementation MUKDataSourceSectionedContentUpdateTests

- (void)testNoUpdate {
    NSArray *const sourceSections = @[ Section(@"a", nil), Section(@"b", nil) ];
    NSArray *const destinationSections = @[ Section(@"a", nil), Section(@"b", nil) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    XCTAssert(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testSectionInsertion {
    NSArray *const sourceSections = @[ Section(@"a", nil), Section(@"b", nil) ];
    NSArray *const destinationSections = @[ Section(@"a", nil), Section(@"c", nil), Section(@"b", nil) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSIndexSet *const insertedSections = [NSIndexSet indexSetWithIndex:1];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqualObjects(update.insertedSectionIndexes, insertedSections);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testSectionDeletion {
    NSArray *const sourceSections = @[ Section(@"a", nil), Section(@"b", nil), Section(@"c", nil), Section(@"d", nil) ];
    NSArray *const destinationSections = @[ Section(@"a", nil), Section(@"d", nil) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSIndexSet *const deletedSections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testSectionReload {
    // a, b, c
    // a, b', c'
    NSArray *const sourceSections = @[ Section(@"a", nil), Section(@"b", nil), Section(@"c", nil) ];
    NSArray *const destinationSections = @[ Section(@"a", nil), Section(@"b", @[@"*"]), Section(@"c", @[@"*"]) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    // Abstract implementation never reloads sections
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 2); // Don't care here
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testSectionMovements {
    NSArray *const sourceSections = @[ Section(@"a", nil), Section(@"b", nil), Section(@"c", nil), Section(@"d", nil) ];
    NSArray *const destinationSections = @[ Section(@"c", nil), Section(@"b", nil), Section(@"d", nil), Section(@"a", nil) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    // 0->3, 2->0
    NSSet *const sectionMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionMovement alloc] initWithSourceIndex:0 destinationIndex:3], [[MUKDataSourceContentSectionMovement alloc] initWithSourceIndex:2 destinationIndex:0], nil ];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.sectionMovements, sectionMovements);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testSectionComboInsertionDeletion {
    NSArray *const sourceSections = @[ Section(@"a", nil), Section(@"b", nil) ];
    NSArray *const destinationSections = @[ Section(@"c", nil), Section(@"b", nil) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSIndexSet *const insertedSections = [NSIndexSet indexSetWithIndex:0];
    NSIndexSet *const deletedSections = [NSIndexSet indexSetWithIndex:0];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqualObjects(update.insertedSectionIndexes, insertedSections);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testSectionComboInsertionReload {
    // a, b
    // c, d, a, e, b', f
    NSArray *const sourceSections = @[ Section(@"a", nil), Section(@"b", nil) ];
    NSArray *const destinationSections = @[ Section(@"c", nil), Section(@"d", nil), Section(@"a", nil), Section(@"e", nil), Section(@"b", @[@"*"]), Section(@"f", nil) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSMutableIndexSet *const insertedSections = [NSMutableIndexSet indexSet];
    [insertedSections addIndex:0];
    [insertedSections addIndex:1];
    [insertedSections addIndex:3];
    [insertedSections addIndex:5];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqualObjects(update.insertedSectionIndexes, insertedSections);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    // Abstract implementation never reloads sections
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 1); // Don't care here
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testSectionComboInsertionMovements {
    // a, b, c, d
    // e, c, b, d, f, a
    NSArray *const sourceSections = @[ Section(@"a", nil), Section(@"b", nil), Section(@"c", nil), Section(@"d", nil) ];
    NSArray *const destinationSections = @[ Section(@"e", nil), Section(@"c", nil), Section(@"b", nil), Section(@"d", nil), Section(@"f", nil), Section(@"a", nil) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSMutableIndexSet *const insertedSections = [NSMutableIndexSet indexSetWithIndex:0];
    [insertedSections addIndex:4];
    
    // 0->5, 1->2
    NSSet *const sectionMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionMovement alloc] initWithSourceIndex:0 destinationIndex:5], [[MUKDataSourceContentSectionMovement alloc] initWithSourceIndex:1 destinationIndex:2], nil ];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqualObjects(update.insertedSectionIndexes, insertedSections);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.sectionMovements, sectionMovements);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testSectionComboDeletionReload {
    // a, b, c, d
    // b, d'
    NSArray *const sourceSections = @[ Section(@"a", nil), Section(@"b", nil), Section(@"c", nil), Section(@"d", nil) ];
    NSArray *const destinationSections = @[ Section(@"b", nil), Section(@"d", @[@"*"]) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSMutableIndexSet *const deletedSections = [NSMutableIndexSet indexSetWithIndex:0];
    [deletedSections addIndex:2];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    // Abstract implementation never reloads sections
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 1); // Don't care here
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testSectionComboDeletionMovements {
    // a, b, c, d, e
    // b, e, c
    NSArray *const sourceSections = @[ Section(@"a", nil), Section(@"b", nil), Section(@"c", nil), Section(@"d", nil), Section(@"e", nil) ];
    NSArray *const destinationSections = @[ Section(@"b", nil), Section(@"e", nil), Section(@"c", nil) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSMutableIndexSet *const deletedSections = [NSMutableIndexSet indexSetWithIndex:0];
    [deletedSections addIndex:3];

    // 4->1
    NSSet *const sectionMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionMovement alloc] initWithSourceIndex:4 destinationIndex:1], nil ];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.sectionMovements, sectionMovements);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testSectionComboReloadMovements {
    // a, b, c
    // c, b, a'
    NSArray *const sourceSections = @[ Section(@"a", nil), Section(@"b", nil), Section(@"c", nil) ];
    NSArray *const destinationSections = @[ Section(@"c", nil), Section(@"b", nil), Section(@"a", @[@"*"]) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    // 0->2, 2->0
    NSSet *const movements = [NSSet setWithObjects:[[MUKDataSourceContentSectionMovement alloc] initWithSourceIndex:0 destinationIndex:2], [[MUKDataSourceContentSectionMovement alloc] initWithSourceIndex:2 destinationIndex:0], nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    // Abstract implementation never reloads sections
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.sectionMovements, movements);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 1); // Don't care here
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testSectionComboInsertionDeletionReload {
    // a, b, c
    // a, d, b', e
    NSArray *const sourceSections = @[ Section(@"a", nil), Section(@"b", nil), Section(@"c", nil) ];
    NSArray *const destinationSections = @[ Section(@"a", nil), Section(@"d", nil), Section(@"b", @[@"*"]), Section(@"e", nil) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSMutableIndexSet *const insertedSections = [NSMutableIndexSet indexSetWithIndex:1];
    [insertedSections addIndex:3];
    NSIndexSet *const deletedSections = [NSIndexSet indexSetWithIndex:2];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqualObjects(update.insertedSectionIndexes, insertedSections);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    // Abstract implementation never reloads sections
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 1); // Don't care here
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testSectionComboInsertionDeletionMovement {
    // a, b, c
    // b, d, a, e
    NSArray *const sourceSections = @[ Section(@"a", nil), Section(@"b", nil), Section(@"c", nil) ];
    NSArray *const destinationSections = @[ Section(@"b", nil), Section(@"d", nil), Section(@"a", nil), Section(@"e", nil) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSMutableIndexSet *const insertedSections = [NSMutableIndexSet indexSetWithIndex:1];
    [insertedSections addIndex:3];
    NSIndexSet *const deletedSections = [NSIndexSet indexSetWithIndex:2];
   
    NSSet *const movements = [NSSet setWithObjects:[[MUKDataSourceContentSectionMovement alloc] initWithSourceIndex:0 destinationIndex:2], nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqualObjects(update.insertedSectionIndexes, insertedSections);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.sectionMovements, movements);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testSectionComboDeletionReloadMovement {
    // a, b, c, d
    // b, a', d
    NSArray *const sourceSections = @[ Section(@"a", nil), Section(@"b", nil), Section(@"c", nil), Section(@"d", nil) ];
    NSArray *const destinationSections = @[ Section(@"b", nil), Section(@"a", @[@"*"]), Section(@"d", nil) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSIndexSet *const deletedSections = [NSIndexSet indexSetWithIndex:2];
    
    NSSet *const movements = [NSSet setWithObjects:[[MUKDataSourceContentSectionMovement alloc] initWithSourceIndex:0 destinationIndex:1], nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    // Abstract implementation never reloads sections
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.sectionMovements, movements);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 1); // Don't care here
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testSectionComboInsertionDeletionReloadMovement {
    // a, b, c
    // b, d, a', e
    NSArray *const sourceSections = @[ Section(@"a", nil), Section(@"b", nil), Section(@"c", nil) ];
    NSArray *const destinationSections = @[ Section(@"b", nil), Section(@"d", nil), Section(@"a", @[@"*"]), Section(@"e", nil) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSMutableIndexSet *const insertedSections = [NSMutableIndexSet indexSetWithIndex:1];
    [insertedSections addIndex:3];
    NSIndexSet *const deletedSections = [NSIndexSet indexSetWithIndex:2];
    
    NSSet *const movements = [NSSet setWithObjects:[[MUKDataSourceContentSectionMovement alloc] initWithSourceIndex:0 destinationIndex:2], nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqualObjects(update.insertedSectionIndexes, insertedSections);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    // Abstract implementation never reloads sections
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.sectionMovements, movements);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 1); // Don't care here
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testItemInsertion {
    // a, b
    // a, c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"a", @"c", @"b" ];
    
    NSArray *const sourceSections = @[Section(@"a", sourceItems)];
    NSArray *const destinationSections = @[Section(@"a", destinationItems)];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSSet *const insertedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(1), nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedItemIndexPaths, insertedItemIndexPaths);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}
/*
- (void)testItemInsertionWithSectionMovement {
    // a, b
    // a, c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"a", @"c", @"b" ];
    
    NSArray *const sourceSections = @[ Section(@"a", sourceItems), Section(@"b", nil)];
    NSArray *const destinationSections = @[ Section(@"b", nil), Section(@"a", destinationItems) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
    
  //  XCTAssert(update.needsReloadData);
}
*/
- (void)testItemDeletion {
    // a, b, c
    // a, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"a", @"c" ];
    
    NSArray *const sourceSections = @[Section(@"a", sourceItems)];
    NSArray *const destinationSections = @[Section(@"a", destinationItems)];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(1), nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}
/*
- (void)testItemDeletionWithSectionMovement {
    // a, b, c
    // a, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"a", @"c" ];
    
    NSArray *const sourceSections = @[ Section(@"a", sourceItems), Section(@"b", nil)];
    NSArray *const destinationSections = @[ Section(@"b", nil), Section(@"a", destinationItems) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];

    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
    
   // XCTAssert(update.needsReloadData);
}
*/
- (void)testItemReload {
    // a, b, c
    // a, b', c
    NSArray *const sourceItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"B"], @"c" ];
    NSArray *const destinationItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"B'"], @"c" ];
    
    NSArray *const sourceSections = @[Section(@"a", sourceItems)];
    NSArray *const destinationSections = @[Section(@"a", destinationItems)];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(1), nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqual(update.itemMovements.count, 0);
}
- (void)testItemReloadWithSectionMovement {
    // a, b, c
    // a, b', c
    NSArray *const sourceItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"B"], @"c" ];
    NSArray *const destinationItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"B'"], @"c" ];
    
    NSArray *const sourceSections = @[ Section(@"a", sourceItems), Section(@"b", nil)];
    NSArray *const destinationSections = @[ Section(@"b", nil), Section(@"a", destinationItems) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSSet *const sectionMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionMovement alloc] initWithSourceIndex:0 destinationIndex:1], nil];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPath(0, 1), nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.sectionMovements, sectionMovements);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testItemMovements {
    // a, b, c, d
    // c, a, d, b
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"c", @"a", @"d", @"b" ];
    
    NSArray *const sourceSections = @[Section(@"a", sourceItems)];
    NSArray *const destinationSections = @[Section(@"a", destinationItems)];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    // 0->1, 1->3
    NSSet *const ItemMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPath(0, 0) destinationIndexPath:IndexPath(0, 1)], [[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPath(0, 1) destinationIndexPath:IndexPath(0, 3)], nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.itemMovements, ItemMovements);
}

- (void)testItemMovementBetweenSections {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    NSArray *const sourceItemsB = @[ @"c", @"d", @"e", @"f" ];

    NSArray *const destinationItemsA = @[ @"c", @"b", @"f", @"d" ];
    NSArray *const destinationItemsB = @[ @"a", @"e" ];
    
    NSArray *const sourceSections = @[ Section(@"a", sourceItemsA), Section(@"b", sourceItemsB) ];
    NSArray *const destinationSections = @[ Section(@"a", destinationItemsA), Section(@"b", destinationItemsB) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    // a: (0, 0) -> (1, 0)
    // b: -
    // c: (1, 0) -> (0, 0)
    // d: (1, 1) -> (0, 3)
    // e: -
    // f: (1, 3) -> (0, 2)
    NSSet *const ItemMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPath(0, 0) destinationIndexPath:IndexPath(1, 0)], [[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPath(1, 0) destinationIndexPath:IndexPath(0, 0)], [[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPath(1, 1) destinationIndexPath:IndexPath(0, 3)], [[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPath(1, 3) destinationIndexPath:IndexPath(0, 2)], nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.itemMovements, ItemMovements);
}
/*
- (void)testItemMovementWithSectionMovement {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    NSArray *const sourceItemsB = @[ @"c", @"d" ];
    NSArray *const sourceItemsC = @[ @"e", @"f" ];
    
    NSArray *const destinationItemsA = @[ @"b" ];
    NSArray *const destinationItemsC = @[ @"e", @"f" ];
    NSArray *const destinationItemsB = @[ @"c", @"a", @"d" ];
    
    NSArray *const sourceSections = @[ Section(@"a", sourceItemsA), Section(@"b", sourceItemsB), Section(@"c", sourceItemsC) ];
    NSArray *const destinationSections = @[ Section(@"a", destinationItemsA), Section(@"c", destinationItemsC), Section(@"b", destinationItemsB) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];

    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
    
   // XCTAssert(update.needsReloadData);
}
*/
- (void)testItemMovementToInsertedSection {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    
    NSArray *const destinationItemsA = @[ @"b" ];
    NSArray *const destinationItemsB = @[ @"c", @"a" ];
    
    NSArray *const sourceSections = @[ Section(@"a", sourceItemsA) ];
    NSArray *const destinationSections = @[ Section(@"a", destinationItemsA), Section(@"b", destinationItemsB) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSIndexSet *const insertedSections = [NSIndexSet indexSetWithIndex:1];
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(0), nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqualObjects(update.insertedSectionIndexes, insertedSections);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testItemMovementFromDeletedSection {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    NSArray *const sourceItemsB = @[ @"c" ];

    NSArray *const destinationItemsB = @[ @"c", @"a" ];
    
    NSArray *const sourceSections = @[ Section(@"a", sourceItemsA), Section(@"b", sourceItemsB) ];
    NSArray *const destinationSections = @[ Section(@"b", destinationItemsB) ];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSIndexSet *const deletedSections = [NSIndexSet indexSetWithIndex:0];
    NSSet *const insertedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(1), nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.deletedSectionIndexes, deletedSections);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedItemIndexPaths, insertedItemIndexPaths);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testItemComboInsertionDeletion {
    // a, b
    // c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"c", @"b" ];
    
    NSArray *const sourceSections = @[Section(@"a", sourceItems)];
    NSArray *const destinationSections = @[Section(@"a", destinationItems)];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSSet *const insertedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(0), nil];
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(0), nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedItemIndexPaths, insertedItemIndexPaths);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testItemComboInsertionReload {
    // a, b
    // c, d, a, e, b', f
    NSArray *const sourceItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"b"] ];
    NSArray *const destinationItems = @[ @"c", @"d", @"a", @"e", [[BasicItem alloc] initWithIdentifier:@"b" title:@"b'"], @"f" ];
    
    NSArray *const sourceSections = @[Section(@"a", sourceItems)];
    NSArray *const destinationSections = @[Section(@"a", destinationItems)];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSSet *const insertedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(0), IndexPathWithItem(1), IndexPathWithItem(3), IndexPathWithItem(5), nil];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(1), nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedItemIndexPaths, insertedItemIndexPaths);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testItemComboInsertionMovements {
    // a, b, c, d
    // e, c, b, d, f, a
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"e", @"c", @"b", @"d", @"f", @"a" ];
    
    NSArray *const sourceSections = @[Section(@"a", sourceItems)];
    NSArray *const destinationSections = @[Section(@"a", destinationItems)];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSSet *const insertedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(0), IndexPathWithItem(4), nil];
    NSSet *const ItemMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithItem(0) destinationIndexPath:IndexPathWithItem(5)], [[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithItem(1) destinationIndexPath:IndexPathWithItem(2)], nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedItemIndexPaths, insertedItemIndexPaths);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.itemMovements, ItemMovements);
}

- (void)testItemComboDeletionReload {
    // a, b, c, d
    // b, d'
    NSArray *const sourceItems = @[ @"a", @"b", @"c", [[BasicItem alloc] initWithIdentifier:@"d" title:@"d"] ];
    NSArray *const destinationItems = @[ @"b", [[BasicItem alloc] initWithIdentifier:@"d" title:@"d'"] ];
    
    NSArray *const sourceSections = @[Section(@"a", sourceItems)];
    NSArray *const destinationSections = @[Section(@"a", destinationItems)];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(0), IndexPathWithItem(2), nil];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(3), nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testItemComboDeletionMovements {
    // a, b, c, d, e
    // b, e, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d", @"e" ];
    NSArray *const destinationItems = @[ @"b", @"e", @"c" ];
    
    NSArray *const sourceSections = @[Section(@"a", sourceItems)];
    NSArray *const destinationSections = @[Section(@"a", destinationItems)];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(0), IndexPathWithItem(3), nil];
    NSSet *const ItemMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithItem(4) destinationIndexPath:IndexPathWithItem(1)], nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.itemMovements, ItemMovements);
}

- (void)testItemComboReloadMovements {
    // a, b, c
    // c, b, a'
    NSArray *const sourceItems = @[ [[BasicItem alloc] initWithIdentifier:@"a" title:@"a"], @"b", @"c" ];
    NSArray *const destinationItems = @[ @"c", @"b", [[BasicItem alloc] initWithIdentifier:@"a" title:@"a'"] ];
    
    NSArray *const sourceSections = @[Section(@"a", sourceItems)];
    NSArray *const destinationSections = @[Section(@"a", destinationItems)];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(0), nil];
    NSSet *const ItemMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithItem(0) destinationIndexPath:IndexPathWithItem(2)], [[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithItem(2) destinationIndexPath:IndexPathWithItem(0)], nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqualObjects(update.itemMovements, ItemMovements);
}

- (void)testItemComboInsertionDeletionReload {
    // a, b, c
    // a, d, b', e
    NSArray *const sourceItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"b"], @"c" ];
    NSArray *const destinationItems = @[ @"a", @"d", [[BasicItem alloc] initWithIdentifier:@"b" title:@"b'"], @"e" ];
    
    NSArray *const sourceSections = @[Section(@"a", sourceItems)];
    NSArray *const destinationSections = @[Section(@"a", destinationItems)];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSSet *const insertedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(1), IndexPathWithItem(3), nil];
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(2), nil];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(1), nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedItemIndexPaths, insertedItemIndexPaths);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqual(update.itemMovements.count, 0);
}

- (void)testItemComboInsertionDeletionMovement {
    // a, b, c
    // b, d, a, e
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"b", @"d", @"a", @"e" ];
    
    NSArray *const sourceSections = @[Section(@"a", sourceItems)];
    NSArray *const destinationSections = @[Section(@"a", destinationItems)];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSSet *const insertedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(1), IndexPathWithItem(3), nil];
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(2), nil];
    NSSet *const ItemMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithItem(0) destinationIndexPath:IndexPathWithItem(2)], nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedItemIndexPaths, insertedItemIndexPaths);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.itemMovements, ItemMovements);
}

- (void)testItemComboDeletionReloadMovement {
    // a, b, c, d
    // b, a', d
    NSArray *const sourceItems = @[ [[BasicItem alloc] initWithIdentifier:@"a" title:@"a"], @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"b", [[BasicItem alloc] initWithIdentifier:@"a" title:@"a'"], @"d" ];
    
    NSArray *const sourceSections = @[Section(@"a", sourceItems)];
    NSArray *const destinationSections = @[Section(@"a", destinationItems)];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(2), nil];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(0), nil];
    NSSet *const ItemMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithItem(0) destinationIndexPath:IndexPathWithItem(1)], nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqualObjects(update.itemMovements, ItemMovements);
}

- (void)testItemComboInsertionDeletionReloadMovement {
    // a, b, c
    // b, d, a', e
    NSArray *const sourceItems = @[ [[BasicItem alloc] initWithIdentifier:@"a" title:@"a"], @"b", @"c" ];
    NSArray *const destinationItems = @[ @"b", @"d", [[BasicItem alloc] initWithIdentifier:@"a" title:@"a'"], @"e" ];
    
    NSArray *const sourceSections = @[Section(@"a", sourceItems)];
    NSArray *const destinationSections = @[Section(@"a", destinationItems)];
    
    MUKDataSourceSectionedContentUpdate *const update = [[MUKDataSourceSectionedContentUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSSet *const insertedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(1), IndexPathWithItem(3), nil];
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(2), nil];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(0), nil];
    NSSet *const ItemMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithItem(0) destinationIndexPath:IndexPathWithItem(2)], nil];
    
    XCTAssertFalse(update.isEmpty);
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedItemIndexPaths, insertedItemIndexPaths);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqualObjects(update.itemMovements, ItemMovements);
}

#pragma mark - Private

static inline MUKDataSourceContentSection *Section(NSString *identifier, NSArray *items)
{
    return [[MUKDataSourceContentSection alloc] initWithIdentifier:identifier items:items];
}

static inline NSIndexPath *IndexPathWithItem(NSUInteger Item) {
    return IndexPath(0, Item);
}

static inline NSIndexPath *IndexPath(NSUInteger section, NSUInteger Item) {
    return [NSIndexPath indexPathForItem:Item inSection:section];
}

@end
