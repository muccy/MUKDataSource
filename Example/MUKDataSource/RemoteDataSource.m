//
//  RemoteDataSource.m
//  MUKDataSource
//
//  Created by Marco on 08/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "RemoteDataSource.h"
#import "Florist.h"
#import "Flower.h"

@implementation RemoteDataSource

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

- (MUKDataSourceContentLoading *)newContentLoadingForState:(NSString *)state {
    static NSInteger const kCount = 20;
    MUKDataSourceContentLoading *contentLoading = [[MUKDataSourceContentLoading alloc] init];
    __weak MUKDataSourceContentLoading *weakContentLoading = contentLoading;

    if ([state isEqualToString:MUKDataSourceContentLoadStateLoading] ||
        [state isEqualToString:MUKDataSourceContentLoadStateRefreshing])
    {
        contentLoading.job = ^{
            [Florist flowersFromIndex:0 count:kCount completion:^(NSArray *flowers, NSError *error)
            {
                MUKDataSourceContentLoading *strongContentLoading = weakContentLoading;
                
                if (strongContentLoading && !strongContentLoading.isCancelled) {
                    [strongContentLoading finishWithResultType:MUKDataSourceContentLoadingResultTypeDone error:nil update:^
                    {
                        [[self childDataSourceAtIndex:0] setItems:flowers animated:YES];
                    }];
                }
            }];
        };
    }
    else if ([state isEqualToString:MUKDataSourceContentLoadStateAppending]) {
        contentLoading.job = ^{
            [Florist flowersFromIndex:[self childDataSourcesItemCount] count:kCount completion:^(NSArray *flowers, NSError *error)
            {
                MUKDataSourceContentLoading *strongContentLoading = weakContentLoading;
                
                if (strongContentLoading && !strongContentLoading.isCancelled) {
                    [strongContentLoading finishWithResultType:MUKDataSourceContentLoadingResultTypeDone error:nil update:^
                    {
                        NSMutableArray *proxy = [[self childDataSourceAtIndex:0] mutableArrayValueForKey:@"items"];
                        [proxy addObjectsFromArray:flowers];
                    }];
                }
            }];
        };
    }
    else {
        contentLoading = nil;
    }
    
    return contentLoading;
        
}

@end
