//
//  TablePlayground.h
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "Example.h"

@interface TablePlayground : Example
@property (nonatomic, readonly, copy) NSArray *commands;
- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title commands:(NSArray *)commands;
@end
