//
//  BasicItem.m
//  MUKDataSource
//
//  Created by Marco on 16/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "BasicItem.h"

@implementation BasicItem
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

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self.identifier isEqual:((BasicItem *)object).identifier] &&
        [self.title isEqualToString:((BasicItem *)object).title];
    }
    
    return NO;
}

- (NSUInteger)hash {
    return 843 ^ [self.identifier hash] ^ [self.title hash];
}

@end
