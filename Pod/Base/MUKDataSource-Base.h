#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKDataSourceContentSection.h>
#import <MUKDataSource/MUKDataSourceTableUpdate.h>
#import <MUKDataSource/MUKDataSourceCollectionUpdate.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A content which means content is indefinite.
 It is used by page view controller data sources.
 */
extern NSObject *const MUKDataSourceIndefiniteContent;

/// Exception raised when data source some required data is missing
extern NSString *const MUKDataSourceInconsistencyException;

/**
 An object ready to hold and provide content data.
 The generic type is the type of contained item: it could be the type of items 
 contained in sections or the type of pages.
 */
@interface MUKDataSource<__covariant ObjectType> : NSObject
/// Content data
@property (nonatomic, copy, nullable) __kindof NSObject *content;
@end


@interface MUKDataSource<__covariant ItemType> (SectionedContent)
/// Data interpreted as sectioned content
@property (nonatomic, copy, readonly, nullable) NSArray<MUKDataSourceContentSection<ItemType> *> *sections;
/// Items inside every section
@property (nonatomic, copy, readonly, nullable) NSArray<ItemType> *allItems;
/// @returns Section at given index. It could return nil if no section is found.
- (nullable MUKDataSourceContentSection<ItemType> *)sectionAtIndex:(NSInteger)idx;
/// @returns Section with given identifier
- (nullable MUKDataSourceContentSection<ItemType> *)sectionWithIdentifier:(MUKDataSourceIdentifier)identifier;
/// @returns Item at given index path. It could return nil if no item is found.
- (nullable ItemType)itemAtIndexPath:(NSIndexPath *)indexPath;
/**
 @returns Index path for item passing given test. It could return nil if no item 
 passes test.
 */
- (nullable NSIndexPath *)indexPathOfItemPassingTest:(BOOL (^)(ItemType item, NSIndexPath *indexPath, BOOL *stop))test;
/// @returns Index path for given item. It could return nil if no item is found.
- (nullable NSIndexPath *)indexPathOfItem:(ItemType)item;
@end


@interface MUKDataSource<__covariant ItemType> (TableViewSupport)
/**
 Sets table view sections
 @param tableSections An array of MUKDataSourceContentSection objects
 @returns The update to apply to your UITableView instance or nil if no update
 is generated
 */
- (MUKDataSourceTableUpdate *)setTableSections:(nullable NSArray<MUKDataSourceContentSection<ItemType> *> *)tableSections;
/**
 @param sourceSections      Table sections before the update
 @param destinationSections Table sections after the update
 @returns New table update. Default implementation returns a valid
 MUKDataSourceTableUpdate instance.
 */
- (MUKDataSourceTableUpdate *)newTableUpdateFromSections:(nullable NSArray<MUKDataSourceContentSection<ItemType> *> *)sourceSections toSections:(nullable NSArray<MUKDataSourceContentSection<ItemType> *> *)destinationSections;
/**
 Register reusable views (e.g.: cell, header/footer) to table view
 @discussion You override this method to register reusable views once. This method
 is called by MUKTableViewController in its -viewDidLoad implementation.
 */
- (void)registerReusableViewsForTableView:(UITableView *)tableView;
@end

/// Implemented methods for UITableViewDataSource protocol
@interface MUKDataSource (UITableViewDataSourceImplementedMethods) <UITableViewDataSource>
/// @returns Number of items inside matching table section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)idx;
/**
 @warning You have to override this method: default implementation throws a
 MUKDataSourceInconsistencyException
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
/// @returns Number of sections in self.sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
/// @returns Header title for matching table section
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
/// @returns Footer title for matching table section
- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
@end


@interface MUKDataSource<__covariant ItemType> (CollectionViewSupport)
/**
 Sets collection view sections
 @param collectionSections An array of MUKDataSourceContentSection objects
 @returns The update to apply to your UICollectionView instance or nil if no update
 is generated
 */
- (MUKDataSourceCollectionUpdate *)setCollectionSections:(nullable NSArray<MUKDataSourceContentSection<ItemType> *> *)collectionSections;
/**
 You should override this method and provide your custom
 MUKDataSourceCollectionUpdate subclass in order to indicate sections to reload
 @param sourceSections      Collection sections before the update
 @param destinationSections Collection sections after the update
 @returns New collection update. Default implementation returns a valid
 MUKDataSourceCollectionUpdate instance.
 */
- (MUKDataSourceCollectionUpdate *)newCollectionUpdateFromSections:(nullable NSArray<MUKDataSourceContentSection<ItemType> *> *)sourceSections toSections:(nullable NSArray<MUKDataSourceContentSection<ItemType> *> *)destinationSections;
/**
 Register reusable views (e.g.: cell, header/footer) to collection view
 @discussion You override this method to register reusable views once. This method
 is called by MUKCollectionViewController in its -viewDidLoad implementation.
 */
- (void)registerReusableViewsForCollectionView:(UICollectionView *)collectionView;
@end

/// Implemented methods for UICollectionViewDataSource protocol
@interface MUKDataSource (UICollectionViewDataSourceImplementedMethods) <UICollectionViewDataSource>
/// @returns Number of items inside matching collection section
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
/**
 @warning You have to override this method: default implementation throws a
 MUKDataSourceInconsistencyException
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
/// @returns Number of sections in self.sections
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
@end

@interface MUKDataSource<__covariant PageType> (PageViewControllerSupport)
/**
 Data interpreted as paged content. 
 @warning This returns nil when you use indefinite number of pages (setting
 `self.content = MUKDataSourceIndefiniteContent`)
 */
@property (nonatomic, copy, readonly, nullable) NSArray<PageType> *pages;
/**
 @returns Page at given index or nil, if idx is out of bounds
 */
- (nullable PageType)pageAtIndex:(NSInteger)idx;
/**
 @param viewController The view controller which represents a page
 @returns Page represented by view controller. Default implementation returns nil.
 @warning You need to override this method. Default implementation throws a 
 MUKDataSourceInconsistencyException.
 */
- (nullable PageType)pageForViewController:(__kindof UIViewController *)viewController;
/**
 @returns Page after given page.
 @warning You need to override this method if you are using an indefinite number
 of pages.
 */
- (nullable PageType)pageFollowingPage:(PageType)page;
/**
 @returns Page before given page.
 @warning You need to override this method if you are using an indefinite number
 of pages.
 */
- (nullable PageType)pagePrecedingPage:(PageType)page;
/**
 @returns YES if page 1 precedes page 2
 @warning You need to override this method if you are using an indefinite number
 of pages.
 */
- (BOOL)page:(PageType)page1 precedesPage:(PageType)page2;
/**
 @param page Page item
 @returns A new view controller which displays page at given index. Default
 implementation returns nil.
 @warning You need to override this method to provide new view controllers on
 response of user gestures. Default implementation throws a 
 MUKDataSourceInconsistencyException.
 */
- (nullable __kindof UIViewController *)newViewControllerForPage:(PageType)page;
@end

/// Implemented methods for UIPageViewControllerDataSource protocol
@interface MUKDataSource (UIPageViewControllerDataSourceImplementedMethods) <UIPageViewControllerDataSource>
/**
 @returns The view controller returned by -newViewControllerForPage:atIndex:,
 called with result of -pagePrecedingPage:
 */
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;
/**
 @returns The view controller returned by -newViewControllerForPage:,
 called with result of -pageFollowingPage:
 */
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController;
@end

NS_ASSUME_NONNULL_END
