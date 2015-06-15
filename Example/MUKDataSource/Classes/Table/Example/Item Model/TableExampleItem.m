//
//  TableExampleItem.m
//  MUKDataSource
//
//  Created by Marco on 15/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TableExampleItem.h"

@implementation TableExampleItem
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
        TableExampleItem *const item = object;
        return [self.identifier isEqual:item.identifier] && [self.title isEqualToString:item.title];
    }
    
    return self;
}

- (NSUInteger)hash {
    return 843 ^ [self.identifier hash] ^ [self.title hash];
}

@end
