//
//  MUKViewController.m
//  MUKDataSource
//
//  Created by Muccy on 08/01/2014.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "ViewController.h"
#import "DataSource.h"

@interface ViewController ()
@property (nonatomic) DataSource *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [self newDataSource];
    [self.dataSource registerReusableViewsForTableView:self.tableView];
    self.tableView.dataSource = self.dataSource;
}

#pragma mark - Private

- (DataSource *)newDataSource {
    DataSource *dataSource = [[DataSource alloc] init];
    
    DataSource *insectsDataSource = [[DataSource alloc] init];
    insectsDataSource.title = @"Insects";
    insectsDataSource.items = @[ @"Spider", @"Fly" ];
    [dataSource addChildDataSource:insectsDataSource];
    
    DataSource *otherAnimalsDataSource = [[DataSource alloc] init];
    otherAnimalsDataSource.title = @"Other Animals";
    otherAnimalsDataSource.items = @[ @"Cat", @"Dog", @"Pig", @"Horse" ];
    [dataSource addChildDataSource:otherAnimalsDataSource];
    
    return dataSource;
}

@end
