//
//  FlowersTableViewController.m
//  MUKDataSource
//
//  Created by Marco on 09/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "FlowersTableViewController.h"
#import "RemoteFlowersDataSource.h"
#import "FlowerListDataSource.h"
#import "AppendContentDataSource.h"

@interface FlowersTableViewController ()

@end

@implementation FlowersTableViewController

- (MUKDataSource *)newDataSource {
    RemoteFlowersDataSource *dataSource = [[RemoteFlowersDataSource alloc] init];
    
    FlowerListDataSource *sectionDataSource = [[FlowerListDataSource alloc] init];
    AppendContentDataSource *appendContentSection = [[AppendContentDataSource alloc] init];
    dataSource.childDataSources = @[sectionDataSource, appendContentSection];
    
    return dataSource;
}

- (BOOL)usesRefreshControl {
    return YES;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger dataSourceIndex = [self.dataSource childDataSourceIndexFromTableViewSection:indexPath.section checkingBounds:YES];
    if ([[self.dataSource childDataSourceAtIndex:dataSourceIndex] isKindOfClass:[AppendContentDataSource class]])
    {
        [self.dataSource setNeedsAppendContent];
    }
}

@end
