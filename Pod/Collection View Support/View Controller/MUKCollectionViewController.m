//
//  MUKCollectionViewController.m
//  
//
//  Created by Marco on 17/06/15.
//
//

#import "MUKCollectionViewController.h"
#import <KVOController/FBKVOController.h>

@interface MUKCollectionViewController ()
@end

@implementation MUKCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Keep table view data source bound with self.dataSource from now on
    [self.KVOController observe:self keyPath:NSStringFromSelector(@selector(dataSource)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(MUKCollectionViewController *observer, MUKCollectionViewController *object, NSDictionary *change)
     {
         [observer.dataSource registerReusableViewsForCollectionView:observer.collectionView];
         observer.collectionView.dataSource = observer.dataSource;
     }];
}

@end
