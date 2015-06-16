//
//  BasicSection.m
//  MUKDataSource
//
//  Created by Marco on 16/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "BasicSection.h"

@implementation BasicSection
@synthesize identifier = _identifier;
@synthesize items = _items;

- (instancetype)initWithIdentifier:(NSString *)identifier items:(NSArray *)items
{
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
        _items = [items copy];
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        BasicSection *const section = object;
        BOOL const sameIdentifier = (!self.identifier && !section.identifier) || [self.identifier isEqual:section.identifier];
        BOOL const sameItems = (!self.items && !section.items) || [self.items isEqualToArray:section.items];
        return sameIdentifier && sameItems;
    }
    
    return NO;
}

- (NSUInteger)hash {
    return 85945 ^ [self.identifier hash] ^ [self.items hash];
}

@end
