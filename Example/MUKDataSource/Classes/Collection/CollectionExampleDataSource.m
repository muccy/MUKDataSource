//
//  CollectionExampleDataSource.m
//  MUKDataSource
//
//  Created by Marco on 16/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "CollectionExampleDataSource.h"
#import "CollectionViewCell.h"

@implementation CollectionExampleDataSource

- (instancetype)init {
    self = [super init];
    if (self) {
        MUKDataSourceCollectionSection *section = [[MUKDataSourceCollectionSection alloc] initWithIdentifier:@"a" items:@[ @"a", @"b", @"c" ]];
        self.content = @[section];
    }
    
    return self;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.contentView.backgroundColor = [[self class] randomColor];

    NSString *text;
    id<MUKDataSourceIdentifiable> const item = [self itemAtIndexPath:indexPath];
    if ([item isKindOfClass:[NSString class]]) {
        text = (NSString *)item;
    }
    else {
        text = [NSString stringWithFormat:@"%lu, %lu", (unsigned long)indexPath.section, (unsigned long)indexPath.item];
    }
    
    cell.textLabel.text = text;
    
    return cell;
}

+ (UIColor *)randomColor {
    NSInteger const r = arc4random()%255;
    NSInteger const g = arc4random()%255;
    NSInteger const b = arc4random()%255;
    return [UIColor colorWithRed:(CGFloat)r/255 green:(CGFloat)g/255 blue:(CGFloat)b/255 alpha:1.0f];
}

@end
