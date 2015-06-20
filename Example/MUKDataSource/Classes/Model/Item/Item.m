//
//  Item.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "Item.h"

@implementation Item
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

- (BOOL)isEqualToItem:(Item *)item {
    BOOL sameIdentifier = (!self.identifier && !item.identifier) || [self.identifier isEqual:item.identifier];
    BOOL sameTitle = (!self.title && !item.title) || [self.title isEqualToString:item.title];
    return sameIdentifier && sameTitle;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self isEqualToItem:object];
    }
    
    return NO;
}

- (NSUInteger)hash {
    return 48395 ^ [self.identifier hash] ^ [self.title hash];
}

@end
