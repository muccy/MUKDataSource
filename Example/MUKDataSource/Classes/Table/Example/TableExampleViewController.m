//
//  TableExampleViewController.m
//  MUKDataSource
//
//  Created by Marco on 14/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TableExampleViewController.h"
#import "TableExample.h"
#import "TableExampleDataSource.h"
#import <KVOController/FBKVOController.h>

@interface TableExampleViewController ()
@end

@implementation TableExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataSource = [[TableExampleDataSource alloc] init];
    
    [self.KVOController observe:self keyPath:NSStringFromSelector(@selector(example)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(TableExampleViewController *observer, TableExampleViewController *object, NSDictionary *change)
    {
        observer.title = observer.example.title;
        [observer.dataSource setTableSections:observer.example.sourceTableSections];
        [observer.tableView reloadData];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Perform" style:UIBarButtonItemStylePlain target:self action:@selector(performExample)];
}

#pragma mark - Private

- (void)performExample {
    MUKDataSourceTableUpdate *const update = [self.dataSource setTableSections:self.example.destinationTableSections];
    [update applyToTableView:self.tableView animated:YES];
}

@end
