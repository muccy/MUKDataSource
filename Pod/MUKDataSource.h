#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKDataSourceContentSection.h>
#import <MUKDataSource/MUKDataSourceTableUpdate.h>
#import <MUKDataSource/MUKDataSourceCollectionUpdate.h>

NS_ASSUME_NONNULL_BEGIN

/**
 An abstract class ready to hold and provide content data
 */
@interface MUKDataSource : NSObject
/**
 Content data
 */
@property (nonatomic, copy, nullable) id<NSObject, NSCopying> content;
@end


@interface MUKDataSource (SectionedContent)
/**
 Data interpreted as sectioned content
 */
@property (nonatomic, copy, readonly, nullable) NSArray *sections;
/**
 Items inside every section
 */
@property (nonatomic, copy, readonly, nullable) NSArray *allItems;
/**
 @returns Section at given index. It could return nil if no section is found.
 */
- (MUKDataSourceContentSection *__nullable)sectionAtIndex:(NSInteger)idx;
/**
 @returns Section with given identifier
 */
- (MUKDataSourceContentSection *__nullable)sectionWithIdentifier:(id<NSObject, NSCopying>)identifier;
/**
 @returns Item at given index path. It could return nil if no item is found.
 */
- (nullable id)itemAtIndexPath:(NSIndexPath *)indexPath;
/**
 @returns Index path for item passing given test. It could return nil if no item 
 passes test.
 */
- (NSIndexPath *__nullable)indexPathOfItemPassingTest:(BOOL (^)(id<MUKDataSourceIdentifiable> item, NSIndexPath *indexPath, BOOL *stop))test;
/**
 @returns Index path for given item. It could return nil if no item is found.
 */
- (NSIndexPath *__nullable)indexPathOfItem:(id<MUKDataSourceIdentifiable>)item;
@end


@interface MUKDataSource (TableViewSupport)
/**
 Sets table view sections
 @param tableSections An array of MUKDataSourceContentSection objects
 @returns The update to apply to your UITableView instance or nil if no update
 is generated
 */
- (MUKDataSourceTableUpdate *)setTableSections:(NSArray *__nullable)tableSections;
/**
 @param sourceSections      Table sections before the update
 @param destinationSections Table sections after the update
 @returns New table update. Default implementation returns a valid
 MUKDataSourceTableUpdate instance.
 */
- (MUKDataSourceTableUpdate *)newTableUpdateFromSections:(NSArray *__nullable)sourceSections toSections:(NSArray *__nullable)destinationSections;
/**
 Register reusable views (e.g.: cell, header/footer) to table view
 @discussion You override this method to register reusable views once. This method
 is called by MUKTableViewController in its -viewDidLoad implementation.
 */
- (void)registerReusableViewsForTableView:(UITableView *)tableView;
@end

/** 
 Implemented methods for UITableViewDataSource protocol
 */
@interface MUKDataSource (UITableViewDataSourceImplementedMethods) <UITableViewDataSource>
/**
 @returns Number of items inside matching table section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)idx;
/**
 @warning You have to override this method: default implementation leads UITableView
 to crash
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
/**
 @returns Number of sections in self.sections
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
/**
 @returns Header title for matching table section
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
/**
 @returns Footer title for matching table section
 */
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
@end


@interface MUKDataSource (CollectionViewSupport)
/**
 Sets collection view sections
 @param collectionSections An array of MUKDataSourceContentSection objects
 @returns The update to apply to your UICollectionView instance or nil if no update
 is generated
 */
- (MUKDataSourceCollectionUpdate *)setCollectionSections:(NSArray *__nullable)collectionSections;
/**
 You should override this method and provide your custom
 MUKDataSourceCollectionUpdate subclass in order to indicate sections to reload
 @param sourceSections      Collection sections before the update
 @param destinationSections Collection sections after the update
 @returns New collection update. Default implementation returns a valid
 MUKDataSourceCollectionUpdate instance.
 */
- (MUKDataSourceCollectionUpdate *)newCollectionUpdateFromSections:(NSArray *__nullable)sourceSections toSections:(NSArray *__nullable)destinationSections;
/**
 Register reusable views (e.g.: cell, header/footer) to collection view
 @discussion You override this method to register reusable views once. This method
 is called by MUKCollectionViewController in its -viewDidLoad implementation.
 */
- (void)registerReusableViewsForCollectionView:(UICollectionView *)collectionView;
@end

/**
 Implemented methods for UICollectionViewDataSource protocol
 */
@interface MUKDataSource (UICollectionViewDataSourceImplementedMethods) <UICollectionViewDataSource>
/**
 @returns Number of items inside matching collection section
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
/**
 @warning You have to override this method: default implementation leads 
 UICollectionView to crash
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
/**
 @returns Number of sections in self.sections
 */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
@end

@interface MUKDataSource (PageViewControllerSupport)
/**
 @param idx Page index
 @returns A new view controller which displays page at given index. Default 
 implementation returns nil.
 */
- (UIViewController *__nullable)newViewControllerForPageAtIndex:(NSInteger)idx;
/**
 @param viewController The view controller which represents a page
 @returns The index of given view controller in page view controller. Default
 implementation returns NSNotFound.
 */
- (NSInteger)pageIndexForViewController:(UIViewController *)viewController;
@end

/**
 Implemented methods for UIPageViewControllerDataSource protocol
 */
@interface MUKDataSource (UIPageViewControllerDataSourceImplementedMethods) <UIPageViewControllerDataSource>
/**
 @returns The view controller returned by -newViewControllerForPageAtIndex:, 
 called with current index - 1
 */
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;
/**
 @returns The view controller returned by -newViewControllerForPageAtIndex:,
 called with current index - 1
 */
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController;
@end

NS_ASSUME_NONNULL_END
