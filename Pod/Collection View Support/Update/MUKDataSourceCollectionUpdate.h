#import <MUKDataSource/MUKDataSourceSectionedContentUpdate.h>

NS_ASSUME_NONNULL_BEGIN

/**
 How collection should be updated to reflect the transition from source sections
 to destination sections.
 @note This subclass uses destination indexes due the nature of 
 applyToCollectionView:completion: in reloadedItemIndexPathForDelta:change:sectionMatch:.
 @note You should use destination indexes if you subclass 
 reloadedSectionIndexForDelta:change: (which still returns NSNotFound here)
 */
@interface MUKDataSourceCollectionUpdate : MUKDataSourceSectionedContentUpdate
/**
 YES when only calling reloadData is a safe path to apply transition
 */
@property (nonatomic, readonly) BOOL needsReloadData;
/**
 @brief         Apply update to a collection view
 @discussion    Update is applied in two steps. First it inserts, deletes and
                moves collection view components. Then it attempts various reloads.
                This is necessary because collection views don't like to mix
                movements and reloads.
 @param collectionView      Table view instance to affect with update
 @param completionHandler   A block called when all updates are completed
 */
- (void)applyToCollectionView:(UICollectionView *)collectionView completion:(void (^)(BOOL finished))completionHandler;
/**
 Reload sections in a collection view.
 You may want to override this method when default behavior to call
 collection view's reloadSections: is not proper for you.
 @param collectionView  Table view instance to affect with update
 @param indexes         Indexes to reload
 */
- (void)reloadCollectionView:(UICollectionView *)collectionView sectionsAtIndexes:(NSIndexSet *)indexes;
/**
 Reload rows in a collection view.
 You may want to override this method when default behavior to call
 collection view's reloadItemsAtIndexPaths: is not proper for you.
 @param collectionView  Table view instance to affect with update
 @param indexPaths      Index paths to reload
 */
- (void)reloadCollectionView:(UICollectionView *)collectionView itemsAtIndexPaths:(NSSet *)indexPaths;
@end

NS_ASSUME_NONNULL_END
