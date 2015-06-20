//
//  TablePlaygroundCommand.h
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "Item.h"
#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKDataSource.h>

typedef void (^TablePlaygroundCommandAction)(MUKDataSource *dataSource, UITableView *tableView);

@interface TablePlaygroundCommand : Item
@property (nonatomic, readonly) UITableViewCellEditingStyle editingStyle;
@property (nonatomic, readonly, copy) TablePlaygroundCommandAction action;

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title editingStyle:(UITableViewCellEditingStyle)editingStyle action:(TablePlaygroundCommandAction)action;
- (BOOL)isEqualToTablePlaygroundCommand:(TablePlaygroundCommand *)command;
@end
