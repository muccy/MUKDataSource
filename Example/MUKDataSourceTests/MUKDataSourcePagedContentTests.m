//
//  MUKDataSourcePagedContentTests.m
//  MUKDataSource
//
//  Created by Marco on 05/09/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <MUKDataSource/MUKDataSource.h>

@interface MUKDataSourcePagedContentTests : XCTestCase

@end

@implementation MUKDataSourcePagedContentTests

- (void)testContent {
    MUKDataSource *const dataSource = [[MUKDataSource alloc] init];

    dataSource.content = MUKDataSourceIndefiniteContent;
    XCTAssertNil(dataSource.pages);
    
    dataSource.content = @[ @1, @2, @3 ];
    XCTAssertEqualObjects(dataSource.content, dataSource.pages);
    XCTAssertEqualObjects([dataSource pageAtIndex:1], @2);
    XCTAssertNil([dataSource pageAtIndex:-10]);
    XCTAssertNil([dataSource pageAtIndex:10]);

    XCTAssertEqualObjects([dataSource pageFollowingPage:@2], @3);
    XCTAssertNil([dataSource pageFollowingPage:@3]);
    
    XCTAssertEqualObjects([dataSource pagePrecedingPage:@2], @1);
    XCTAssertNil([dataSource pagePrecedingPage:@1]);
    
    XCTAssertTrue([dataSource page:@1 precedesPage:@2]);
    XCTAssertFalse([dataSource page:@1 precedesPage:@10]);
    XCTAssertFalse([dataSource page:@(-10) precedesPage:@2]);
    XCTAssertFalse([dataSource page:@3 precedesPage:@2]);
}

@end
