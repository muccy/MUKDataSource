//
//  MUKDataSourceCollectionUpdateTests.n
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <MUKDataSource/MUKDataSource.h>
#import <MUKArrayDelta/MUKArrayDelta.h>
#import "BasicItem.h"

static NSTimeInterval const kUpdateTimeout = 1.0;

@interface RichCollectionSection : MUKDataSourceCollectionSection
@property (nonatomic, copy, readonly) NSString *title;
- (instancetype)initWithIdentifier:(id<NSCopying>)identifier title:(NSString *)title items:(NSArray *)items;
@end

@implementation RichCollectionSection

- (instancetype)initWithIdentifier:(id<NSCopying>)identifier title:(NSString *)title items:(NSArray *)items
{
    self = [super initWithIdentifier:identifier items:items];
    if (self) {
        _title = [title copy];
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![super isEqual:object]) {
        return NO;
    }
    
    if ([object isKindOfClass:[self class]]) {
        RichCollectionSection *const section = object;
        BOOL const haveSameTitle = (!self.title && !section.title) || [self.title isEqualToString:section.title];
        return haveSameTitle; // other params tested in superclass
    }
    
    return NO;
}

- (NSUInteger)hash {
    return [super hash] ^ [self.title hash];
}

@end

#pragma mark -

@interface RichCollectionUpdate : MUKDataSourceCollectionUpdate
@end

@implementation RichCollectionUpdate

- (NSUInteger)reloadedSectionIndexForDelta:(MUKArrayDelta *)delta change:(MUKArrayDeltaMatch *)change
{
    RichCollectionSection *const sourceSection = delta.sourceArray[change.sourceIndex];
    RichCollectionSection *const destinationSection = delta.destinationArray[change.destinationIndex];
    
    BOOL const sameTitle = (!destinationSection.title && !sourceSection.title) || [destinationSection.title isEqualToString:sourceSection.title];
    
    if (!sameTitle) {
        return change.destinationIndex;
    }
    
    return NSNotFound;
}

@end

#pragma mark -

@interface BasicCollectionDataSource : MUKDataSource
@end

@implementation BasicCollectionDataSource

- (MUKDataSourceCollectionUpdate *)newCollectionUpdateFromSections:(NSArray *)sourceSections toSections:(NSArray *)destinationSections
{
    return [[RichCollectionUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
    return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header" forIndexPath:indexPath];
}

@end

#pragma mark -

@interface MUKDataSourceCollectionUpdateTests : XCTestCase
@end

@implementation MUKDataSourceCollectionUpdateTests

- (void)testSectionInsertion {
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"b", nil, nil) ];
    NSArray *const destinationSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"c", nil, nil), CollectionSection(@"b", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
}

- (void)testSectionDeletion {
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"b", nil, nil), CollectionSection(@"c", nil, nil), CollectionSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"d", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
}

- (void)testSectionReload {
    // a, b, c
    // a, b', c'
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"b", nil, nil), CollectionSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"b", @"B'", nil), CollectionSection(@"c", @"C'", nil) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
}

- (void)testSectionMovements {
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"b", nil, nil), CollectionSection(@"c", nil, nil), CollectionSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ CollectionSection(@"c", nil, nil), CollectionSection(@"b", nil, nil), CollectionSection(@"d", nil, nil), CollectionSection(@"a", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionDeletion {
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"b", nil, nil) ];
    NSArray *const destinationSections = @[ CollectionSection(@"c", nil, nil), CollectionSection(@"b", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionReload {
    // a, b
    // c, d, a, e, b', f
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"b", nil, nil) ];
    NSArray *const destinationSections = @[ CollectionSection(@"c", nil, nil), CollectionSection(@"d", nil, nil), CollectionSection(@"a", nil, nil), CollectionSection(@"e", nil, nil), CollectionSection(@"b", @"B'", nil), CollectionSection(@"f", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
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
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionMovements {
    // a, b, c, d
    // e, c, b, d, f, a
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"b", nil, nil), CollectionSection(@"c", nil, nil), CollectionSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ CollectionSection(@"e", nil, nil), CollectionSection(@"c", nil, nil), CollectionSection(@"b", nil, nil), CollectionSection(@"d", nil, nil), CollectionSection(@"f", nil, nil), CollectionSection(@"a", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
}

- (void)testSectionComboDeletionReload {
    // a, b, c, d
    // b, d'
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"b", nil, nil), CollectionSection(@"c", nil, nil), CollectionSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ CollectionSection(@"b", nil, nil), CollectionSection(@"d", @"D'", nil) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
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

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
}

- (void)testSectionComboDeletionMovements {
    // a, b, c, d, e
    // b, e, c
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"b", nil, nil), CollectionSection(@"c", nil, nil), CollectionSection(@"d", nil, nil), CollectionSection(@"e", nil, nil) ];
    NSArray *const destinationSections = @[ CollectionSection(@"b", nil, nil), CollectionSection(@"e", nil, nil), CollectionSection(@"c", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
}

- (void)testSectionComboReloadMovements {
    // a, b, c
    // c, b, a'
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"b", nil, nil), CollectionSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ CollectionSection(@"c", nil, nil), CollectionSection(@"b", nil, nil), CollectionSection(@"a", @"A'", nil) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
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
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionDeletionReload {
    // a, b, c
    // a, d, b', e
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"b", nil, nil), CollectionSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"d", nil, nil), CollectionSection(@"b", @"B'", nil), CollectionSection(@"e", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
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

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionDeletionMovement {
    // a, b, c
    // b, d, a, e
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"b", nil, nil), CollectionSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ CollectionSection(@"b", nil, nil), CollectionSection(@"d", nil, nil), CollectionSection(@"a", nil, nil), CollectionSection(@"e", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
}

- (void)testSectionComboDeletionReloadMovement {
    // a, b, c, d
    // b, a', d
    NSArray *const sourceSections = @[ CollectionSection(@"a", @"a", nil), CollectionSection(@"b", nil, nil), CollectionSection(@"c", nil, nil), CollectionSection(@"d", nil, nil) ];
    NSArray *const destinationSections = @[ CollectionSection(@"b", nil, nil), CollectionSection(@"a", @"a'", nil), CollectionSection(@"d", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
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

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
}

- (void)testSectionComboInsertionDeletionReloadMovement {
    // a, b, c
    // b, d, a', e
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"b", nil, nil), CollectionSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ CollectionSection(@"b", nil, nil), CollectionSection(@"d", nil, nil), CollectionSection(@"a", @"A'", nil), CollectionSection(@"e", nil, nil) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
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

    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
}

- (void)testNotReloadedChangedSection {
    // a, b, c
    // a, b', c*
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"b", nil, nil), CollectionSection(@"c", nil, nil) ];
    NSArray *const destinationSections = @[ CollectionSection(@"a", nil, nil), CollectionSection(@"b", @"B'", nil), CollectionSection(@"c", nil, @[@"New item!"]) ];
    
    MUKDataSourceCollectionUpdate *const update = [[RichCollectionUpdate alloc] initWithSourceSections:sourceSections destinationSections:destinationSections];
    
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:1];
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
}

- (void)testItemInsertion {
    // a, b
    // a, c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"a", @"c", @"b" ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

- (void)testItemInsertionWithSectionReload {
    // a, b
    // a, c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"a", @"c", @"b" ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", @"A'", destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:0];
    NSSet *const insertedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(1), nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedItemIndexPaths, insertedItemIndexPaths);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);

    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

- (void)testItemInsertionWithSectionMovement {
    // a, b
    // a, c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"a", @"c", @"b" ];
    
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, sourceItems), CollectionSection(@"b", nil, nil)];
    NSArray *const destinationSections = @[ CollectionSection(@"b", nil, nil), CollectionSection(@"a", nil, destinationItems) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssert(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:1], destinationItems.count);
}

- (void)testItemDeletion {
    // a, b, c
    // a, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"a", @"c" ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

- (void)testItemDeletionWithSectionReload {
    // a, b, c
    // a, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"a", @"c" ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", @"A'", destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:0];
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(1), nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqual(update.itemMovements.count, 0);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

- (void)testItemDeletionWithSectionMovement {
    // a, b, c
    // a, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"a", @"c" ];
    
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, sourceItems), CollectionSection(@"b", nil, nil)];
    NSArray *const destinationSections = @[ CollectionSection(@"b", nil, nil), CollectionSection(@"a", nil, destinationItems) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssert(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:1], destinationItems.count);
}

- (void)testItemReload {
    // a, b, c
    // a, b', c
    NSArray *const sourceItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"B"], @"c" ];
    NSArray *const destinationItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"B'"], @"c" ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(1), nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqual(update.itemMovements.count, 0);

    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

- (void)testItemReloadWithSectionReload {
    // a, b, c
    // a, b', c
    NSArray *const sourceItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"B"], @"c" ];
    NSArray *const destinationItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"B'"], @"c" ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", @"A'", destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:0];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(1), nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqual(update.itemMovements.count, 0);

    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

- (void)testItemReloadWithSectionMovement {
    // a, b, c
    // a, b', c
    NSArray *const sourceItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"B"], @"c" ];
    NSArray *const destinationItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"B'"], @"c" ];
    
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, sourceItems), CollectionSection(@"b", nil, nil)];
    NSArray *const destinationSections = @[ CollectionSection(@"b", nil, nil), CollectionSection(@"a", nil, destinationItems) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:1], destinationItems.count);
}

- (void)testItemMovements {
    // a, b, c, d
    // c, a, d, b
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"c", @"a", @"d", @"b" ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

- (void)testItemMovementBetweenSections {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    NSArray *const sourceItemsB = @[ @"c", @"d", @"e", @"f" ];
    
    NSArray *const destinationItemsA = @[ @"c", @"b", @"f", @"d" ];
    NSArray *const destinationItemsB = @[ @"a", @"e" ];
    
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, sourceItemsA), CollectionSection(@"b", nil, sourceItemsB) ];
    NSArray *const destinationSections = @[ CollectionSection(@"a", nil, destinationItemsA), CollectionSection(@"b", nil, destinationItemsB) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItemsA.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:1], sourceItemsB.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItemsA.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:1], destinationItemsB.count);
}

- (void)testItemMovementsWithSectionReload {
    // a, b, c, d
    // c, a, d, b
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"c", @"a", @"d", @"b" ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", @"A", sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", @"A'", destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
    // 0->1, 1->3
    NSSet *const itemMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithItem(0) destinationIndexPath:IndexPathWithItem(1)], [[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithItem(1) destinationIndexPath:IndexPathWithItem(3)], nil];
    NSIndexSet *const reloadedSections = [NSIndexSet indexSetWithIndex:0];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqualObjects(update.reloadedSectionIndexes, reloadedSections);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqual(update.reloadedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.itemMovements, itemMovements);
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

- (void)testItemMovementWithSectionMovement {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    NSArray *const sourceItemsB = @[ @"c", @"d" ];
    NSArray *const sourceItemsC = @[ @"e", @"f" ];
    
    NSArray *const destinationItemsA = @[ @"b" ];
    NSArray *const destinationItemsC = @[ @"e", @"f" ];
    NSArray *const destinationItemsB = @[ @"c", @"a", @"d" ];
    
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, sourceItemsA), CollectionSection(@"b", nil, sourceItemsB), CollectionSection(@"c", nil, sourceItemsC) ];
    NSArray *const destinationSections = @[ CollectionSection(@"a", nil, destinationItemsA), CollectionSection(@"c", nil, destinationItemsC), CollectionSection(@"b", nil, destinationItemsB) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItemsA.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:1], sourceItemsB.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:2], sourceItemsC.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssert(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItemsA.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:1], destinationItemsC.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:2], destinationItemsB.count);
}

- (void)testItemMovementToInsertedSection {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    
    NSArray *const destinationItemsA = @[ @"b" ];
    NSArray *const destinationItemsB = @[ @"c", @"a" ];
    
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, sourceItemsA) ];
    NSArray *const destinationSections = @[ CollectionSection(@"a", nil, destinationItemsA), CollectionSection(@"b", nil, destinationItemsB) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItemsA.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItemsA.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:1], destinationItemsB.count);
}

- (void)testItemMovementFromDeletedSection {
    NSArray *const sourceItemsA = @[ @"a", @"b" ];
    NSArray *const sourceItemsB = @[ @"c" ];
    
    NSArray *const destinationItemsB = @[ @"c", @"a" ];
    
    NSArray *const sourceSections = @[ CollectionSection(@"a", nil, sourceItemsA), CollectionSection(@"b", nil, sourceItemsB) ];
    NSArray *const destinationSections = @[ CollectionSection(@"b", nil, destinationItemsB) ];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItemsA.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItemsB.count);
}

- (void)testItemComboInsertionDeletion {
    // a, b
    // c, b
    NSArray *const sourceItems = @[ @"a", @"b" ];
    NSArray *const destinationItems = @[ @"c", @"b" ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

- (void)testItemComboInsertionReload {
    // a, b
    // c, d, a, e, b', f
    NSArray *const sourceItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"b"] ];
    NSArray *const destinationItems = @[ @"c", @"d", @"a", @"e", [[BasicItem alloc] initWithIdentifier:@"b" title:@"b'"], @"f" ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
    NSSet *const insertedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(0), IndexPathWithItem(1), IndexPathWithItem(3), IndexPathWithItem(5), nil];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(4), nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedItemIndexPaths, insertedItemIndexPaths);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqual(update.itemMovements.count, 0);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

- (void)testItemComboInsertionMovements {
    // a, b, c, d
    // e, c, b, d, f, a
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"e", @"c", @"b", @"d", @"f", @"a" ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

- (void)testItemComboDeletionReload {
    // a, b, c, d
    // b, d'
    NSArray *const sourceItems = @[ @"a", @"b", @"c", [[BasicItem alloc] initWithIdentifier:@"d" title:@"d"] ];
    NSArray *const destinationItems = @[ @"b", [[BasicItem alloc] initWithIdentifier:@"d" title:@"d'"] ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(0), IndexPathWithItem(2), nil];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(1), nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqual(update.itemMovements.count, 0);

    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

- (void)testItemComboDeletionMovements {
    // a, b, c, d, e
    // b, e, c
    NSArray *const sourceItems = @[ @"a", @"b", @"c", @"d", @"e" ];
    NSArray *const destinationItems = @[ @"b", @"e", @"c" ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

- (void)testItemComboReloadMovements {
    // a, b, c
    // c, b, a'
    NSArray *const sourceItems = @[ [[BasicItem alloc] initWithIdentifier:@"a" title:@"a"], @"b", @"c" ];
    NSArray *const destinationItems = @[ @"c", @"b", [[BasicItem alloc] initWithIdentifier:@"a" title:@"a'"] ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(2), nil];
    NSSet *const itemMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithItem(0) destinationIndexPath:IndexPathWithItem(2)], [[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithItem(2) destinationIndexPath:IndexPathWithItem(0)], nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqual(update.deletedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqualObjects(update.itemMovements, itemMovements);

    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

- (void)testItemComboInsertionDeletionReload {
    // a, b, c
    // a, d, b', e
    NSArray *const sourceItems = @[ @"a", [[BasicItem alloc] initWithIdentifier:@"b" title:@"b"], @"c" ];
    NSArray *const destinationItems = @[ @"a", @"d", [[BasicItem alloc] initWithIdentifier:@"b" title:@"b'"], @"e" ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
    NSSet *const insertedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(1), IndexPathWithItem(3), nil];
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(2), nil];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(2), nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedItemIndexPaths, insertedItemIndexPaths);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqual(update.itemMovements.count, 0);

    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

- (void)testItemComboInsertionDeletionMovement {
    // a, b, c
    // b, d, a, e
    NSArray *const sourceItems = @[ @"a", @"b", @"c" ];
    NSArray *const destinationItems = @[ @"b", @"d", @"a", @"e" ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

- (void)testItemComboDeletionReloadMovement {
    // a, b, c, d
    // b, a', d
    NSArray *const sourceItems = @[ [[BasicItem alloc] initWithIdentifier:@"a" title:@"a"], @"b", @"c", @"d" ];
    NSArray *const destinationItems = @[ @"b", [[BasicItem alloc] initWithIdentifier:@"a" title:@"a'"], @"d" ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(2), nil];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(1), nil];
    NSSet *const itemMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithItem(0) destinationIndexPath:IndexPathWithItem(1)], nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqual(update.insertedItemIndexPaths.count, 0);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqualObjects(update.itemMovements, itemMovements);

    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

- (void)testItemComboInsertionDeletionReloadMovement {
    // a, b, c
    // b, d, a', e
    NSArray *const sourceItems = @[ [[BasicItem alloc] initWithIdentifier:@"a" title:@"a"], @"b", @"c" ];
    NSArray *const destinationItems = @[ @"b", @"d", [[BasicItem alloc] initWithIdentifier:@"a" title:@"a'"], @"e" ];
    
    NSArray *const sourceSections = @[CollectionSection(@"a", nil, sourceItems)];
    NSArray *const destinationSections = @[CollectionSection(@"a", nil, destinationItems)];
    
    MUKDataSource *const dataSource = [[BasicCollectionDataSource alloc] init];
    UICollectionView *const collectionView = [self newCollectionViewWithSections:sourceSections dataSource:dataSource];
    XCTAssertEqual([collectionView numberOfSections], sourceSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], sourceItems.count);
    
    MUKDataSourceCollectionUpdate *const update = [dataSource setCollectionSections:destinationSections];
    
    NSSet *const insertedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(1), IndexPathWithItem(3), nil];
    NSSet *const deletedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(2), nil];
    NSSet *const reloadedItemIndexPaths = [NSSet setWithObjects:IndexPathWithItem(2), nil];
    NSSet *const itemMovements = [NSSet setWithObjects:[[MUKDataSourceContentSectionItemMovement alloc] initWithSourceIndexPath:IndexPathWithItem(0) destinationIndexPath:IndexPathWithItem(2)], nil];
    
    XCTAssertEqual(update.insertedSectionIndexes.count, 0);
    XCTAssertEqual(update.deletedSectionIndexes.count, 0);
    XCTAssertEqual(update.reloadedSectionIndexes.count, 0);
    XCTAssertEqual(update.sectionMovements.count, 0);
    
    XCTAssertEqualObjects(update.insertedItemIndexPaths, insertedItemIndexPaths);
    XCTAssertEqualObjects(update.deletedItemIndexPaths, deletedItemIndexPaths);
    XCTAssertEqualObjects(update.reloadedItemIndexPaths, reloadedItemIndexPaths);
    XCTAssertEqualObjects(update.itemMovements, itemMovements);

    XCTestExpectation *expectation = [self expectationWithDescription:@"Update finished"];
    XCTAssertNoThrow([update applyToCollectionView:collectionView completion:^(BOOL finished)
    {
        [expectation fulfill];
    }]);
    [self waitForExpectationsWithTimeout:kUpdateTimeout handler:nil];
    
    XCTAssertFalse(update.needsReloadData);
    XCTAssertEqual([collectionView numberOfSections], destinationSections.count);
    XCTAssertEqual([collectionView numberOfItemsInSection:0], destinationItems.count);
}

#pragma mark - Private

- (UICollectionView *)newCollectionViewWithSections:(NSArray *)sections dataSource:(MUKDataSource *)dataSource
{
    UICollectionViewFlowLayout *const flowLayout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *const collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 568.0f) collectionViewLayout:flowLayout];
    
    [dataSource setCollectionSections:sections];
    collectionView.dataSource = dataSource;
    
    [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]; // access view to initialize it
    [collectionView reloadData];
    
    return collectionView;
}

static inline RichCollectionSection *CollectionSection(NSString *identifier, NSString *title, NSArray *items)
{
    return [[RichCollectionSection alloc] initWithIdentifier:identifier title:[@"Section: " stringByAppendingString:title ?: [identifier uppercaseString]] items:items ?: @[@""]];
}

static inline NSIndexPath *IndexPathWithItem(NSUInteger row) {
    return IndexPath(0, row);
}

static inline NSIndexPath *IndexPath(NSUInteger section, NSUInteger item) {
    return [NSIndexPath indexPathForItem:item inSection:section];
}

@end
