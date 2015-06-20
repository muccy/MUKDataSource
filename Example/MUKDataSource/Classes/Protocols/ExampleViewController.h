//
//  ExampleViewController.h
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Example.h"

@protocol ExampleViewController <NSObject>
@required
@property (nonatomic) Example *example;
@end
