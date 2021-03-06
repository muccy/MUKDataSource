//
//  CollectionViewCell.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:self.contentView.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        label.font = [UIFont systemFontOfSize:17.0f];
        label.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:label];
        _textLabel = label;
    }
    
    return self;
}

@end
