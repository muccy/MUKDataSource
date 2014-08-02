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

- (UITableViewCell *)dequeueOrCreateCellForRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    [super configureCell:cell forRowAtIndexPath:tableIndexPath inTableView:tableView];
    
    NSInteger idx = [self itemIndexFromTableViewRow:tableIndexPath.row checkingBounds:YES];
    NSString *name = [self itemAtIndex:idx];
    cell.textLabel.text = name;
}

- (BOOL)canEditRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    return YES;
}

- (BOOL)canMoveRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    return YES;
}

@end
