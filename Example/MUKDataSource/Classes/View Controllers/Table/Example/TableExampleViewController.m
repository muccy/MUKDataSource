//
//  TableExampleViewController.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TableExampleViewController.h"
#import "TitlesDataSource.h"

@implementation TableExampleViewController
@synthesize example = _example;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [[TitlesDataSource alloc] init];
    self.dataSource.content = self.example.sourceSections;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Perform" style:UIBarButtonItemStylePlain target:self action:@selector(performExample)];
    
    if (self.dataSource.sections.count == 0) {
        self.dataSource.content = [self newEmptyPlaceholder];
    }
}

- (void)performExample {
    MUKDataSourceTableUpdate *const update = [self.dataSource setTableSections:self.example.destinationSections];
    [update applyToTableView:self.tableView withAnimation:[MUKDataSourceTableUpdateAnimation automaticAnimation]];
    
    if (self.dataSource.sections.count == 0) {
        self.dataSource.content = [self newEmptyPlaceholder];
    }
}

#pragma mark - Accessors

- (void)setExample:(SectionedContentExample *)example {
    if (_example != example) {
        _example = example;
    }
    
    // React
    self.title = self.example.title;
    self.dataSource.content = self.example.sourceSections;
}

#pragma mark - Private

- (MUKDataSourceContentPlaceholder *)newEmptyPlaceholder {
    return [[MUKDataSourceContentPlaceholder alloc] initWithTitle:@"Empty" subtitle:@"No sections in this table" image:nil];
}

@end
