//
//  Playground.h
//  MUKDataSource
//
//  Created by Marco on 16/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSource.h>

@interface Playground : NSObject <MUKDataSourceIdentifiable>
@property (nonatomic, readonly, copy) NSString *title;
- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title;
@end
