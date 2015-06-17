//
//  TablePlayground.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TablePlayground.h"

@implementation TablePlayground

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title commands:(NSArray *)commands
{
    self = [super initWithIdentifier:identifier title:title];
    if (self) {
        _commands = [commands copy];
    }
    
    return self;
}

@end
