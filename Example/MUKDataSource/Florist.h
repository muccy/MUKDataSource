//
//  Florist.h
//  MUKDataSource
//
//  Created by Marco on 08/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Florist : NSObject
+ (void)flowersFromIndex:(NSInteger)startIndex count:(NSInteger)count completion:(void (^)(NSArray *flowers, NSError *error))completionHandler;
@end
