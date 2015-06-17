//
//  MUKTableViewController.m
//  
//
//  Created by Marco on 10/06/15.
//
//

#import "MUKTableViewController.h"
#import <KVOController/FBKVOController.h>

@interface MUKTableViewController ()
@end

@implementation MUKTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Keep table view data source bound with self.dataSource from now on
    [self.KVOController observe:self keyPath:NSStringFromSelector(@selector(dataSource)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(MUKTableViewController *observer, MUKTableViewController *object, NSDictionary *change)
    {
        [observer.dataSource registerReusableViewsForTableView:observer.tableView];
        observer.tableView.dataSource = observer.dataSource;
    }];
}

@end
