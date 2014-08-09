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

@end
