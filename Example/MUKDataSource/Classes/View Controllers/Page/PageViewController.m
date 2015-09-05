//
//  PageViewController.m
//  MUKDataSource
//
//  Created by Marco on 05/09/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "PageViewController.h"
#import "PageDataSource.h"

#define INDEFINITE_CONTENT  1

@interface PageViewController ()

@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pageDataSource = [[PageDataSource alloc] init];
#if INDEFINITE_CONTENT
    self.pageDataSource.content = MUKDataSourceIndefiniteContent;
    [self setCurrentPages:@[ @0 ] animated:NO completion:nil];
#else
    self.pageDataSource.content = @[ @"1", @"2", @"3" ];
    [self setCurrentPages:@[self.pageDataSource.pages.firstObject] animated:NO completion:nil];
#endif
}

- (IBAction)goToPreviousPage:(id)sender {
    id const currentPage = self.currentPages.firstObject;
    id const previousPage = [self.pageDataSource pagePrecedingPage:currentPage];
    
    if (previousPage) {
        [self setCurrentPages:@[previousPage] animated:YES completion:nil];
    }
}

- (IBAction)goToNextPage:(id)sender {
    id const currentPage = self.currentPages.lastObject;
    id const nextPage = [self.pageDataSource pageFollowingPage:currentPage];
    
    if (nextPage) {
        [self setCurrentPages:@[nextPage] animated:YES completion:nil];
    }
}

@end
