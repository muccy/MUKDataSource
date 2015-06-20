//
//  SectionedContentExample.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "SectionedContentExample.h"

@implementation SectionedContentExample
@synthesize identifier = _identifier;

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title sourceSections:(NSArray *)sourceSections destinationSections:(NSArray *)destinationSections
{
    self = [super initWithIdentifier:identifier title:title];
    if (self) {
        _sourceSections = [sourceSections copy];
        _destinationSections = [destinationSections copy];
    }
    
    return self;
}

@end
