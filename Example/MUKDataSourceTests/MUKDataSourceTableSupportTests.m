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

@interface MUKDataSourceTableSupportTests : XCTestCase

@end

@implementation MUKDataSourceTableSupportTests

- (void)testSections {
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];
    
    NSArray *const sections = @[ TableSection(@"1", nil, @[@"a"]), TableSection(@"2", nil, @[@"b", @"c", @"d"]), TableSection(@"3", nil, @[@"e", @"f"]) ];
    [dataSource setTableSections:sections];
    
    XCTAssertEqualObjects([dataSource tableSectionAtIndex:0], sections[0]);
    XCTAssertEqualObjects([dataSource tableSectionAtIndex:1], sections[1]);
    XCTAssertNil([dataSource tableSectionAtIndex:3]);
    XCTAssertNoThrow([dataSource tableSectionAtIndex:3]);
    
    XCTAssertEqualObjects([dataSource tableRowItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]], [sections[0] items][0]);
    XCTAssertEqualObjects([dataSource tableRowItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]], [sections[2] items][1]);
    XCTAssertNil([dataSource tableRowItemAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:2]]);
    XCTAssertNoThrow([dataSource tableRowItemAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:2]]);
}

#pragma mark - Private

static inline MUKDataSourceTableSection *TableSection(NSString *identifier, NSString *title, NSArray *items)
{
    return [[MUKDataSourceTableSection alloc] initWithIdentifier:identifier items:items ?: @[@""] headerTitle:[@"Section: " stringByAppendingString:title ?: [identifier uppercaseString]] footerTitle:nil];
}

@end
