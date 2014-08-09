//
//  FlowersDataSource.m
//  MUKDataSource
//
//  Created by Marco on 09/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "FlowerListDataSource.h"
#import "Flower.h"

@implementation FlowerListDataSource

- (UITableViewCell *)dequeueOrCreateCellForRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    [super configureCell:cell forRowAtIndexPath:tableIndexPath inTableView:tableView];
    
    NSInteger itemIndex = [self itemIndexFromTableViewRow:tableIndexPath.row checkingBounds:YES];
    Flower *flower = [self itemAtIndex:itemIndex];
    
    cell.textLabel.text = flower.name;
    cell.detailTextLabel.text = flower.botanicalName;
}

@end
