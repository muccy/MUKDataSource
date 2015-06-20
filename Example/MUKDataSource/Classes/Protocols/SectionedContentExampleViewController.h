//
//  SectionedContentExampleViewController.h
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "ExampleViewController.h"
#import "SectionedContentExample.h"

@protocol SectionedContentExampleViewController <ExampleViewController>
@required
@property (nonatomic) SectionedContentExample *example;
- (void)performExample;
@end
