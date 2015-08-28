//
//  MUKDataSourceTableSupportTests.m
//  MUKDataSource
//
//  Created by Marco on 15/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <MUKDataSource/MUKDataSource.h>

@interface MUKDataSourceContentSectionTests : XCTestCase

@end

@implementation MUKDataSourceContentSectionTests

- (void)testSections {
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    
    NSArray *const sections = @[ Section(@"1", nil, @[@"a"]), Section(@"2", nil, @[@"b", @"c", @"d"]), Section(@"3", nil, @[@"e", @"f"]) ];
    [dataSource setTableSections:sections];
    
    XCTAssertEqualObjects([dataSource sectionAtIndex:0], sections[0]);
    XCTAssertEqualObjects([dataSource sectionAtIndex:1], sections[1]);
    XCTAssertNil([dataSource sectionAtIndex:3]);
    XCTAssertNoThrow([dataSource sectionAtIndex:3]);
    
    XCTAssertEqualObjects([dataSource itemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], [sections[0] items][0]);
    XCTAssertEqualObjects([dataSource itemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]], [sections[2] items][1]);
    XCTAssertNil([dataSource itemAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:2]]);
    XCTAssertNoThrow([dataSource itemAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:2]]);
}

- (void)testSectionEdit {
    MUKDataSourceContentSection *const originalSection = [[MUKDataSourceContentSection alloc] initWithIdentifier:@"identifier" items:@[@"a", @"b", @"c"] header:@"header" footer:@"footer"];
    
    MUKDataSourceContentSection *section = [originalSection sectionByReplacingItemsWithItems:@[@"d"]];
    XCTAssertEqualObjects(section.items, @[@"d"]);
    XCTAssertEqualObjects(section.identifier, originalSection.identifier);
    XCTAssertEqualObjects(section.header, originalSection.header);
    XCTAssertEqualObjects(section.footer, originalSection.footer);

    section = [originalSection sectionByInsertingItem:@"x" atIndex:1];
    XCTAssertEqualObjects(section.items, (@[@"a", @"x", @"b", @"c"]));
    XCTAssertEqualObjects(section.identifier, originalSection.identifier);
    XCTAssertEqualObjects(section.header, originalSection.header);
    XCTAssertEqualObjects(section.footer, originalSection.footer);
    
    section = [originalSection sectionByRemovingItemAtIndex:1];
    XCTAssertEqualObjects(section.items, (@[@"a", @"c"]));
    XCTAssertEqualObjects(section.identifier, originalSection.identifier);
    XCTAssertEqualObjects(section.header, originalSection.header);
    XCTAssertEqualObjects(section.footer, originalSection.footer);
    
    section = [originalSection sectionByInsertingItem:@"x" atIndex:10];
    XCTAssertEqualObjects(section, originalSection);
    
    section = [originalSection sectionByRemovingItemAtIndex:10];
    XCTAssertEqualObjects(section, originalSection);
}

#pragma mark - Private

static inline MUKDataSourceContentSection *Section(NSString *identifier, NSString *title, NSArray *items)
{
    return [[MUKDataSourceContentSection alloc] initWithIdentifier:identifier items:items ?: @[@""] header:[@"Section: " stringByAppendingString:title ?: [identifier uppercaseString]] footer:nil];
}

@end
