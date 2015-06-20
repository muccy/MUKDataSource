//
//  SectionedContentExamplesViewController.h
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import <MUKDataSource/MUKTableViewController.h>

@class SectionedContentExamplesDataSource, Example;
@interface SectionedContentExamplesViewController : MUKTableViewController
- (SectionedContentExamplesDataSource *)newDataSource;
- (NSString *)segueIdentifierForSelectedExample:(Example *)example;
@end
