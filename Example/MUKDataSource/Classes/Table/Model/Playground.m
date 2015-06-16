//
//  Playground.m
//  MUKDataSource
//
//  Created by Marco on 16/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "Playground.h"

@implementation Playground
@synthesize identifier = _identifier;

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title
{
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
        _title = [title copy];
    }
    
    return self;
}

@end
