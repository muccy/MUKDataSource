//
//  TablePlaygroundViewController.m
//  MUKDataSource
//
//  Created by Marco on 16/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TablePlaygroundViewController.h"
#import "TablePlaygroundDataSource.h"
#import "Playground.h"
#import "TablePlaygroundCommand.h"
#import <KVOController/FBKVOController.h>

@interface TablePlaygroundViewController ()

@end

@implementation TablePlaygroundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [[TablePlaygroundDataSource alloc] init];
    
    [self.KVOController observe:self keyPath:NSStringFromSelector(@selector(playground)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(TablePlaygroundViewController *observer, TablePlaygroundViewController *object, NSDictionary *change)
     {
         observer.title = observer.playground.title;
     }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStylePlain target:self action:@selector(restorePlayground)];
    
    [self setEditing:YES animated:NO];
}

#pragma mark - Private

- (void)restorePlayground {
    MUKDataSourceTableUpdate *const update = [self.dataSource setTableSections:[TablePlaygroundDataSource originalSections]];
    [update applyToTableView:self.tableView animated:YES];
}

#pragma mark - <UITableViewControllerDelegate>

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id const item = [self.dataSource itemAtIndexPath:indexPath];
    UITableViewCellEditingStyle style;
    
    if ([item isKindOfClass:[TablePlaygroundCommand class]]) {
        TablePlaygroundCommand *const command = item;
        style = command.editingStyle;
    }
    else {
        style = tableView.editing ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
    }
    
    return style;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id const item = [self.dataSource itemAtIndexPath:indexPath];
    if ([item isKindOfClass:[TablePlaygroundCommand class]]) {
        TablePlaygroundCommand *const command = item;
        if (command.action) {
            command.action(self.dataSource, tableView);
        }
    }
}

@end
