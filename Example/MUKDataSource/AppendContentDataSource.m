//
//  AppendContentDataSource.m
//  MUKDataSource
//
//  Created by Marco on 09/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "AppendContentDataSource.h"

@implementation AppendContentDataSource

- (void)registerReusableViewsForTableView:(UITableView *)tableView {
    [super registerReusableViewsForTableView:tableView];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"AppendCell"];
}

- (UITableViewCell *)dequeueOrCreateCellForRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppendCell" forIndexPath:tableIndexPath];
    cell.textLabel.textColor = [UIColor blueColor];
    return cell;
}

- (void)configureAppendingContentTableViewCell:(UITableViewCell *)cell {
    [super configureAppendingContentTableViewCell:cell];
    cell.textLabel.text = @"Appending";
    
    UIActivityIndicatorView *spinner = [self spinnerViewInTableViewCell:cell createIfNeeded:YES];
    [spinner startAnimating];
    [self layoutSpinnerView:spinner];
}

- (void)configureCouldAppendContentTableViewCell:(UITableViewCell *)cell {
    [super configureCouldAppendContentTableViewCell:cell];
    cell.textLabel.text = @"Append More...";
    
    UIActivityIndicatorView *spinner = [self spinnerViewInTableViewCell:cell createIfNeeded:NO];
    [spinner stopAnimating];
}

#pragma mark - Private

- (UIActivityIndicatorView *)spinnerViewInTableViewCell:(UITableViewCell *)cell createIfNeeded:(BOOL)createIfNeeded
{
    static NSInteger const tag = 22;

    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:tag];
    
    if (!spinner && createIfNeeded) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.tag = tag;
        [cell.contentView addSubview:spinner];
    }
    
    return spinner;
}

- (void)layoutSpinnerView:(UIActivityIndicatorView *)spinner {
    [UIView performWithoutAnimation:^{
        CGRect frame = spinner.frame;
        frame.origin.x = CGRectGetWidth(spinner.superview.bounds) - CGRectGetWidth(frame) - 10.0f;
        frame.origin.y = roundf(CGRectGetMidY(spinner.superview.bounds) - CGRectGetHeight(frame)/2.0f);
        spinner.frame = frame;
    }];
}

@end
