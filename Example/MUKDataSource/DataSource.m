//
//  DataSource.m
//  MUKDataSource
//
//  Created by Marco on 01/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "DataSource.h"

@implementation DataSource

#pragma mark - Overrides

- (void)registerReusableViewsForTableView:(UITableView *)tableView {
    [super registerReusableViewsForTableView:tableView];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (UITableViewCell *)dequeueOrCreateCellForRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    [super configureCell:cell forRowAtIndexPath:indexPath tableView:tableView];
    NSString *name = [self itemAtIndexPath:indexPath];
    cell.textLabel.text = name;
}

@end
