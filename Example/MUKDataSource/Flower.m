//
//  Flower.m
//  MUKDataSource
//
//  Created by Marco on 08/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "Flower.h"

@implementation Flower

- (BOOL)isEqualToFlower:(Flower *)flower {
    if (!flower) {
        return NO;
    }
    
    if (flower == self) {
        return YES;
    }
    
    return [flower.name isEqualToString:self.name] && [flower.botanicalName isEqualToString:self.botanicalName];
}

- (NSUInteger)hash {
    return 34678 ^ [self.name hash];
}

#pragma mark - <NSSecureCoding>

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _botanicalName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"botanicalName"];
        _name = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_botanicalName forKey:@"botanicalName"];
}

@end
