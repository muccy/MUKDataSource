//
//  PageDataSource.m
//  MUKDataSource
//
//  Created by Marco on 05/09/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "PageDataSource.h"
#import "PageItemViewController.h"

@implementation PageDataSource

#pragma mark - Overrides

- (UIViewController * __nullable)newViewControllerForPage:(id<MUKDataSourceIdentifiable> __nonnull)page
{
    PageItemViewController *const viewController = [[PageItemViewController alloc] init];
    viewController.item = page;
    return viewController;
}

- (nullable id<MUKDataSourceIdentifiable>)pageForViewController:(UIViewController * __nonnull)viewController
{
    PageItemViewController *const pageItemViewController = (PageItemViewController *)viewController;
    return pageItemViewController.item;
}

#pragma mark - Overrides (for indefinite number of pages)

- (nullable id<MUKDataSourceIdentifiable>)pageFollowingPage:(id<MUKDataSourceIdentifiable> __nonnull)page
{
    if ([self.content isEqual:MUKDataSourceIndefiniteContent]) {
        NSInteger const n = [(NSNumber *)page integerValue];
        return (id)@(n+1);
    }
    
    return [super pageFollowingPage:page];
}

- (nullable id<MUKDataSourceIdentifiable>)pagePrecedingPage:(id<MUKDataSourceIdentifiable> __nonnull)page
{
    if ([self.content isEqual:MUKDataSourceIndefiniteContent]) {
        NSInteger const n = [(NSNumber *)page integerValue];
        return (id)@(n-1);
    }
    
    return [super pagePrecedingPage:page];
}

- (BOOL)page:(id<MUKDataSourceIdentifiable> __nonnull)page1 precedesPage:(id<MUKDataSourceIdentifiable> __nonnull)page2
{
    if ([self.content isEqual:MUKDataSourceIndefiniteContent]) {
        NSInteger const n1 = [(NSNumber *)page1 integerValue];
        NSInteger const n2 = [(NSNumber *)page2 integerValue];
        
        return n1 < n2;
    }
    
    return [super page:page1 precedesPage:page2];
}

@end
