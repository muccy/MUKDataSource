//
//  MUKDataSourceTests.m
//  MUKDataSource
//
//  Created by Marco on 21/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <MUKDataSource/MUKDataSource.h>

@interface MUKDataSourceTests : XCTestCase
@end

@implementation MUKDataSourceTests

- (void)testSectionedContent {
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    XCTAssertNil(dataSource.content);
    XCTAssertNil(dataSource.sections);
    
    id content = @"Content";
    dataSource.content = content;
    XCTAssertEqualObjects(dataSource.content, content);
    XCTAssertNil(dataSource.sections);
    
    content = @[ [[MUKDataSourceContentSection alloc] init] ];
    dataSource.content = content;
    XCTAssertEqualObjects(dataSource.content, content);
    XCTAssertEqualObjects(dataSource.sections, content);
}

- (void)testAllItemsInSections {
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    dataSource.content = @[ [[MUKDataSourceContentSection alloc] initWithIdentifier:@"a"items:nil], [[MUKDataSourceContentSection alloc] initWithIdentifier:@"b" items:nil] ];
    XCTAssertEqualObjects(dataSource.allItems, @[]);
    
    dataSource.content = @[ [[MUKDataSourceContentSection alloc] initWithIdentifier:@"1"items:@[ @"a", @"b"]], [[MUKDataSourceContentSection alloc] initWithIdentifier:@"2" items:@[ @"c", @"d"] ] ];
    XCTAssertEqualObjects(dataSource.allItems, (@[ @"a", @"b", @"c", @"d" ]));
}

- (void)testSectionAtIndex {
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    dataSource.content = @[ [[MUKDataSourceContentSection alloc] initWithIdentifier:@"a"items:nil], [[MUKDataSourceContentSection alloc] initWithIdentifier:@"b" items:nil] ];
    
    XCTAssertEqualObjects([dataSource sectionAtIndex:0], dataSource.sections[0]);
    XCTAssertEqualObjects([dataSource sectionAtIndex:1], dataSource.sections[1]);
    
    XCTAssertNoThrow([dataSource sectionAtIndex:2]);
    XCTAssertNil([dataSource sectionAtIndex:2]);
    
    XCTAssertNoThrow([dataSource sectionAtIndex:-1]);
    XCTAssertNil([dataSource sectionAtIndex:-1]);
}

- (void)testItemAtIndexPath {
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    dataSource.content = @[ [[MUKDataSourceContentSection alloc] initWithIdentifier:@"1"items:@[ @"a", @"b"]], [[MUKDataSourceContentSection alloc] initWithIdentifier:@"2" items:@[ @"c", @"d"] ] ];
    
    XCTAssertEqualObjects([dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]], [dataSource.sections[0] items][0]);
    XCTAssertEqualObjects([dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:1]], [dataSource.sections[1] items][1]);
    
    XCTAssertNoThrow([dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:2]]);
    XCTAssertNil([dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:2]]);
    
    XCTAssertNoThrow([dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:-1]]);
    XCTAssertNil([dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:-1]]);
    
    XCTAssertNoThrow([dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]]);
    XCTAssertNil([dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]]);
    
    XCTAssertNoThrow([dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:-1 inSection:0]]);
    XCTAssertNil([dataSource itemAtIndexPath:[NSIndexPath indexPathForItem:-1 inSection:0]]);
    
    XCTAssertNoThrow([dataSource itemAtIndexPath:nil]);
    XCTAssertNil([dataSource itemAtIndexPath:nil]);
}

- (void)testIndexPathOfItemPassingTest {
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    dataSource.content = @[ [[MUKDataSourceContentSection alloc] initWithIdentifier:@"1"items:@[ @"a", @"b"]], [[MUKDataSourceContentSection alloc] initWithIdentifier:@"2" items:@[ @"c", @"d"] ] ];
    
    NSIndexPath *indexPath = [dataSource indexPathOfItemPassingTest:^BOOL(id<MUKDataSourceIdentifiable> item, NSIndexPath *indexPath, BOOL *stop)
    {
        return [item isEqual:@"c"];
    }];
    XCTAssertEqualObjects(indexPath, [NSIndexPath indexPathForItem:0 inSection:1]);
    
    indexPath = [dataSource indexPathOfItemPassingTest:^BOOL(id<MUKDataSourceIdentifiable> item, NSIndexPath *indexPath, BOOL *stop)
    {
        return [item isEqual:@"z"];
    }];
    XCTAssertNil(indexPath);
    
    XCTAssertNoThrow([dataSource indexPathOfItemPassingTest:nil]);
    XCTAssertNil([dataSource indexPathOfItemPassingTest:nil]);
}

- (void)testIndexPathOfItem {
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    dataSource.content = @[ [[MUKDataSourceContentSection alloc] initWithIdentifier:@"1"items:@[ @"a", @"b"]], [[MUKDataSourceContentSection alloc] initWithIdentifier:@"2" items:@[ @"c", @"d"] ] ];
    
    NSIndexPath *indexPath = [dataSource indexPathOfItem:(id)@"c"];
    XCTAssertEqualObjects(indexPath, [NSIndexPath indexPathForItem:0 inSection:1]);

    indexPath = [dataSource indexPathOfItem:(id)@"z"];
    XCTAssertNil(indexPath);
    
    XCTAssertNoThrow([dataSource indexPathOfItem:nil]);
    XCTAssertNil([dataSource indexPathOfItem:nil]);
}

@end
