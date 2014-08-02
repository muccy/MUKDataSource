//
//  DataSource.m
//  MUKDataSource
//
//  Created by Marco on 01/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "DataSource.h"

static void *kKVOEditingContext = &kKVOEditingContext;
static NSString *const kAddAnimalItem = @"Add Animal";

@implementation DataSource

- (id)init {
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"editing" options:NSKeyValueObservingOptionNew context:kKVOEditingContext];
    }
    
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"editing" context:kKVOEditingContext];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    BOOL managed = NO;
    
    if (context == kKVOEditingContext) {
        managed = YES;
        BOOL const isEditing = [change[NSKeyValueChangeNewKey] boolValue];
        
        if (isEditing) {
            [self insertItem:kAddAnimalItem atIndex:0];
        }
        else {
            id firstItem = [self itemAtIndex:0];
            if ([firstItem isEqualToString:kAddAnimalItem]) {
                [self removeItemAtIndex:0];
            }
        }
    }
    
    if (!managed) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Overrides

- (NSInteger)numberOfRowsForSection:(NSInteger)section inTableView:(UITableView *)tableView
{
    NSInteger count = [super numberOfRowsForSection:section inTableView:tableView];
    return count;
}

- (void)registerReusableViewsForTableView:(UITableView *)tableView {
    [super registerReusableViewsForTableView:tableView];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (UITableViewCell *)dequeueOrCreateCellForRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    [super configureCell:cell forRowAtIndexPath:tableIndexPath inTableView:tableView];
    
    NSInteger idx = [self itemIndexFromTableViewRow:tableIndexPath.row checkingBounds:YES];
    NSString *name = [self itemAtIndex:idx];
    cell.textLabel.text = name;
}

- (BOOL)canEditRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    return self.editing;
}

- (BOOL)canMoveRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    NSInteger idx = [self itemIndexFromTableViewRow:tableIndexPath.row checkingBounds:YES];
    return ![[self itemAtIndex:idx] isEqualToString:kAddAnimalItem];
}

- (id)newItemToInsertByCommittingRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    return @"Unicorn";
}

@end
