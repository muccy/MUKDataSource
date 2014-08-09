//
//  TableViewController.h
//  MUKDataSource
//
//  Created by Marco on 09/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKdataSource.h>

@interface TableViewController : UITableViewController <MUKDataSourceDelegate>
@property (nonatomic, readonly) MUKDataSource *dataSource;
- (MUKDataSource *)newDataSource;
- (BOOL)usesRefreshControl;
@end
