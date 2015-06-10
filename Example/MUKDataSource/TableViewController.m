//
//  TableViewController.m
//  MUKDataSource
//
//  Created by Marco on 10/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TableViewController.h"

@interface BasicItem : NSObject <MUKDataSourceIdentifiable>
@end

@implementation BasicItem
@synthesize identifier = _identifier;

- (instancetype)initWithIdentifier:(id)identifier {
    self = [super init];
    if (self) {
        _identifier = [(id)identifier copy];
    }
    
    return self;
}

@end

#pragma mark - 

@interface TableViewController ()

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    MUKDataSource *dataSource = [[MUKDataSource alloc] init];
    
    MUKDataSourceTableSection *section1 = [[MUKDataSourceTableSection alloc] initWithIdentifier:@"section-1" items:@[ [[BasicItem alloc] initWithIdentifier:@"a"], [[BasicItem alloc] initWithIdentifier:@"b"] ] headerTitle:@"Section 1" footerTitle:nil];
    MUKDataSourceTableSection *section2 = [[MUKDataSourceTableSection alloc] initWithIdentifier:@"section-2" items:@[ [[BasicItem alloc] initWithIdentifier:@"c"], [[BasicItem alloc] initWithIdentifier:@"d"] ] headerTitle:@"Section 2" footerTitle:@"Last section!"];
    
    dataSource.sections = @[ section1, section2 ];
    
    self.dataSource = dataSource;
    [self.tableView reloadData];
}

@end
