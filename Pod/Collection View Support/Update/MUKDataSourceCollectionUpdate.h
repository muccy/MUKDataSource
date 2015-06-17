//
//  MUKDataSourceCollectionUpdate.h
//  
//
//  Created by Marco on 16/06/15.
//
//

#import <MUKDataSource/MUKDataSourceSectionedContentUpdate.h>

@interface MUKDataSourceCollectionUpdate : MUKDataSourceSectionedContentUpdate
@property (nonatomic, readonly) BOOL needsReloadData;
- (void)applyToCollectionView:(UICollectionView *)collectionView completion:(void (^)(BOOL finished))completionHandler;
@end
