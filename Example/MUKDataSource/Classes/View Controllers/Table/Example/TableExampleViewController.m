//
//  TableExampleViewController.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TableExampleViewController.h"
#import <KVOController/FBKVOController.h>
#import "TitlesDataSource.h"

@implementation TableExampleViewController
@synthesize example = _example;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [[TitlesDataSource alloc] init];
    
    [self.KVOController observe:self keyPath:NSStringFromSelector(@selector(example)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(TableExampleViewController *observer, TableExampleViewController *object, NSDictionary *change)
     {
         observer.title = observer.example.title;
         observer.dataSource.content = observer.example.sourceSections;
     }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Perform" style:UIBarButtonItemStylePlain target:self action:@selector(performExample)];
}

- (void)performExample {
    MUKDataSourceTableUpdate *const update = [self.dataSource setTableSections:self.example.destinationSections];
    [update applyToTableView:self.tableView animated:YES];
}

@end