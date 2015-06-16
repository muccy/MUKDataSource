//
//  TablePlaygroundCommand.h
//  MUKDataSource
//
//  Created by Marco on 16/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKDataSource.h>

@interface TablePlaygroundCommand : NSObject <MUKDataSourceIdentifiable>
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly) UITableViewCellEditingStyle editingStyle;
@property (nonatomic, readonly, copy) void (^action)(MUKDataSource *, UITableView *);

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title editingStyle:(UITableViewCellEditingStyle)editingStyle action:(void (^)(MUKDataSource *, UITableView *))action;
@end
