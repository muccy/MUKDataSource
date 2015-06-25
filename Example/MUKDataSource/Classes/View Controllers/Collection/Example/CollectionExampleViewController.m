//
//  CollectionExampleViewController.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "CollectionExampleViewController.h"
#import <KVOController/FBKVOController.h>
#import "TitlesDataSource.h"

@implementation CollectionExampleViewController
@synthesize example = _example;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.alwaysBounceVertical = YES;
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.headerReferenceSize = CGSizeMake(0, 30.0f);
    flowLayout.minimumInteritemSpacing = 10.0f;
    flowLayout.minimumLineSpacing = 10.0f;
    flowLayout.sectionInset = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
    [self.collectionView setCollectionViewLayout:flowLayout animated:NO];
    
    self.dataSource = [[TitlesDataSource alloc] init];
    
    [self.KVOController observe:self keyPath:NSStringFromSelector(@selector(example)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(CollectionExampleViewController *observer, CollectionExampleViewController *object, NSDictionary *change)
     {
         observer.title = observer.example.title;
         observer.dataSource.content = observer.example.sourceSections;
     }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Perform" style:UIBarButtonItemStylePlain target:self action:@selector(performExample)];
    
    if (self.dataSource.sections.count == 0) {
        self.dataSource.content = [self newEmptyPlaceholder];
    }
}

- (void)performExample {
    MUKDataSourceCollectionUpdate *const update = [self.dataSource setCollectionSections:self.example.destinationSections];
    [update applyToCollectionView:self.collectionView completion:nil];
    
    if (self.dataSource.sections.count == 0) {
        self.dataSource.content = [self newEmptyPlaceholder];
    }
}

#pragma mark - Private

- (MUKDataSourceContentPlaceholder *)newEmptyPlaceholder {
    return [[MUKDataSourceContentPlaceholder alloc] initWithTitle:@"Empty" subtitle:@"No sections in this collection view" image:nil];
}

@end
