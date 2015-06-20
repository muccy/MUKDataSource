//
//  CollectionExamplesViewController.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "CollectionExamplesViewController.h"
#import "CollectionExamplesDataSource.h"
#import "SectionedContentExample.h"

@interface CollectionExamplesViewController ()
@end

@implementation CollectionExamplesViewController

#pragma mark - Overrides

- (SectionedContentExamplesDataSource *)newDataSource {
    return [[CollectionExamplesDataSource alloc] init];
}

- (NSString *)segueIdentifierForSelectedExample:(Example *)example {
    if ([example isKindOfClass:[SectionedContentExample class]]) {
        return @"Show Example";
    }

    return nil;
}

@end
