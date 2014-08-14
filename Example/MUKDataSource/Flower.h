//
//  Flower.h
//  MUKDataSource
//
//  Created by Marco on 08/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Flower : NSObject <NSSecureCoding>
@property (nonatomic, copy) NSString *name, *botanicalName;

- (BOOL)isEqualToFlower:(Flower *)flower;

@end
