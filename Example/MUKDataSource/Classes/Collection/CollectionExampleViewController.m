//
//  CollectionExampleViewController.m
//  MUKDataSource
//
//  Created by Marco on 16/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "CollectionExampleViewController.h"
#import "CollectionExampleDataSource.h"

@interface CollectionExampleViewController ()
@property (nonatomic) CollectionExampleDataSource *dataSource;
@end

@implementation CollectionExampleViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [[CollectionExampleDataSource alloc] init];
    self.collectionView.dataSource = self.dataSource;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        MUKDataSourceCollectionSection *sectionA = [[MUKDataSourceCollectionSection alloc] initWithIdentifier:@"a" items:@[ @"a", @"*" ]];
        MUKDataSourceCollectionSection *sectionB = [[MUKDataSourceCollectionSection alloc] initWithIdentifier:@"b" items:@[ @"g" ]];
        MUKDataSourceCollectionUpdate *update = [self.dataSource setCollectionSections:@[sectionB, sectionA]];
        [update applyToCollectionView:self.collectionView animated:YES completion:nil];
    });
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
