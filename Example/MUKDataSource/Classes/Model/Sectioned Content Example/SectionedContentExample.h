//
//  SectionedContentExample.h
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "Example.h"

@interface SectionedContentExample : Example
@property (nonatomic, readonly, copy) NSArray *sourceSections, *destinationSections;

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title sourceSections:(NSArray *)sourceSections destinationSections:(NSArray *)destinationSections;
@end
