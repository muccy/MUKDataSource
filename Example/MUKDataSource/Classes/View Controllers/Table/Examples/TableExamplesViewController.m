//
//  TableExamplesViewController.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TableExamplesViewController.h"
#import "TableExamplesDataSource.h"
#import "SectionedContentExample.h"
#import "TablePlayground.h"

@implementation TableExamplesViewController

#pragma mark - Overrides

- (SectionedContentExamplesDataSource *)newDataSource {
    return [[TableExamplesDataSource alloc] init];
}

- (NSString *)segueIdentifierForSelectedExample:(Example *)example {
    if ([example isKindOfClass:[SectionedContentExample class]]) {
        return @"Show Example";
    }
    else if ([example isKindOfClass:[TablePlayground class]]) {
        return @"Show Playground";
    }
    
    return nil;
}

@end
