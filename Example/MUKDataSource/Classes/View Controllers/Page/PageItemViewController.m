//
//  PageItemViewController.m
//  MUKDataSource
//
//  Created by Marco on 05/09/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "PageItemViewController.h"

@interface PageItemViewController ()

@end

@implementation PageItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *const label = [[UILabel alloc] initWithFrame:self.view.bounds];
    label.font = [UIFont boldSystemFontOfSize:70.0f];
    label.textAlignment = NSTextAlignmentCenter;
    
    if ([self.item isKindOfClass:[NSString class]]) {
        label.text = (NSString *)self.item;
    }
    else if ([self.item respondsToSelector:@selector(stringValue)]) {
        label.text = [self.item stringValue];
    }
        
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:label];
}

@end
