//
//  ItemsDataSource.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TitlesDataSource.h"
#import "CollectionViewCell.h"
#import "CollectionSectionHeaderView.h"

static NSString *const kCellIdentifier = @"Cell";
static NSString *const kSectionHeaderIdentifier = @"SectionHeader";

@implementation TitlesDataSource

- (void)registerReusableViewsForTableView:(UITableView *)tableView {
    [super registerReusableViewsForTableView:tableView];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
}

- (void)registerReusableViewsForCollectionView:(UICollectionView *)collectionView {
    [super registerReusableViewsForCollectionView:collectionView];
    [collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:kCellIdentifier];
    [collectionView registerClass:[CollectionSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSectionHeaderIdentifier];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self stringValueForItemAtIndexPath:indexPath];
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self stringValueForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    CollectionSectionHeaderView *const headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSectionHeaderIdentifier forIndexPath:indexPath];
    MUKDataSourceContentSection * const section = [self sectionAtIndex:indexPath.section];
    headerView.textLabel.text = [section.header isKindOfClass:[NSString class]] ? (NSString *)section.header : nil;
    return headerView;
}

- (NSString *)stringValueForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *value;
    id<MUKDataSourceIdentifiable> const item = [self itemAtIndexPath:indexPath];

    if ([item isKindOfClass:[NSString class]]) {
        value = (NSString *)item;
    }
    else if ([item respondsToSelector:@selector(title)]) {
        value = [(id)item title];
    }
    else {
        value = nil;
    }
    
    return value;
}

@end
