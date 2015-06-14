//
//  TableExample.m
//  MUKDataSource
//
//  Created by Marco on 14/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TableExample.h"

@implementation TableExample
@synthesize identifier = _identifier;

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title sourceTableSections:(NSArray *)sourceTableSections destinationTableSections:(NSArray *)destinationTableSections
{
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
        _title = [title copy];
        _sourceTableSections = [sourceTableSections copy];
        _destinationTableSections = [destinationTableSections copy];
    }
    
    return self;
}

@end
