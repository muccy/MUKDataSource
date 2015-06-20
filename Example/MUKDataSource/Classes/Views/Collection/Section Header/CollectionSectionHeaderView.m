//
//  CollectionSectionHeaderView.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "CollectionSectionHeaderView.h"

@implementation CollectionSectionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 20.0f, 0.0f)];
        label.font = [UIFont boldSystemFontOfSize:15.0f];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:label];
        _textLabel = label;
        
        self.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    }
    
    return self;
}

@end
