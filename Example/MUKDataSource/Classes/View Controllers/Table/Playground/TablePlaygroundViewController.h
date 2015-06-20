//
//  TablePlaygroundViewController.h
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import <MUKDataSource/MUKTableViewController.h>
#import "ExampleViewController.h"
#import "TablePlayground.h"

@interface TablePlaygroundViewController : MUKTableViewController <ExampleViewController>
@property (nonatomic) TablePlayground *example;
@end
