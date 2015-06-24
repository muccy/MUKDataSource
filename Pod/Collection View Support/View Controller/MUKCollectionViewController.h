#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKDataSource.h>

/**
 Simple collection view controller which holds a data source
 */
@interface MUKCollectionViewController : UICollectionViewController
/**
 @brief         Data source
 @discussion    When you assign a data source it is also assigned to 
                self.collectionView.dataSource. It also calls
                registerReusableViewsForCollectionView: on it.
 */
@property (nonatomic, nullable) MUKDataSource *dataSource;
@end
