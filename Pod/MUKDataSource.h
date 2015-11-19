#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKDataSourceContentSection.h>
#import <MUKDataSource/MUKDataSourceTableUpdate.h>
#import <MUKDataSource/MUKDataSourceCollectionUpdate.h>
#import <MUKDataSource/MUKDataSourceContentPage.h>

NS_ASSUME_NONNULL_BEGIN

typedef __kindof id<NSObject, NSCopying> MUKDataSourceContent;

/**
 A content which means content is indefinite.
 It is used by page view controller data sources.
 */
extern MUKDataSourceContent const MUKDataSourceIndefiniteContent;

/**
 An abstract class ready to hold and provide content data
 */
@interface MUKDataSource : NSObject
/**
 Content data
 */
@property (nonatomic, copy, nullable) MUKDataSourceContent content;
@end


@interface MUKDataSource (SectionedContent)
/**
 Data interpreted as sectioned content
 */
@property (nonatomic, copy, readonly, nullable) NSArray<__kindof MUKDataSourceContentSection *> *sections;
/**
 Items inside every section
 */
@property (nonatomic, copy, readonly, nullable) NSArray<MUKDataSourceContentSectionItem> *allItems;
/**
 @returns Section at given index. It could return nil if no section is found.
 */
- (nullable __kindof MUKDataSourceContentSection *)sectionAtIndex:(NSInteger)idx;
/**
 @returns Section with given identifier
 */
- (nullable __kindof MUKDataSourceContentSection *)sectionWithIdentifier:(MUKDataSourceIdentifier)identifier;
/**
 @returns Item at given index path. It could return nil if no item is found.
 */
- (nullable MUKDataSourceContentSectionItem)itemAtIndexPath:(NSIndexPath *)indexPath;
/**
 @returns Index path for item passing given test. It could return nil if no item 
 passes test.
 */
- (nullable NSIndexPath *)indexPathOfItemPassingTest:(BOOL (^)(MUKDataSourceContentSectionItem item, NSIndexPath *indexPath, BOOL *stop))test;
/**
 @returns Index path for given item. It could return nil if no item is found.
 */
- (nullable NSIndexPath *)indexPathOfItem:(MUKDataSourceContentSectionItem)item;
@end


@interface MUKDataSource (TableViewSupport)
/**
 Sets table view sections
 @param tableSections An array of MUKDataSourceContentSection objects
 @returns The update to apply to your UITableView instance or nil if no update
 is generated
 */
- (MUKDataSourceTableUpdate *)setTableSections:(nullable NSArray<__kindof MUKDataSourceContentSection *> *)tableSections;
/**
 @param sourceSections      Table sections before the update
 @param destinationSections Table sections after the update
 @returns New table update. Default implementation returns a valid
 MUKDataSourceTableUpdate instance.
 */
- (MUKDataSourceTableUpdate *)newTableUpdateFromSections:(nullable NSArray<__kindof MUKDataSourceContentSection *> *)sourceSections toSections:(nullable NSArray<__kindof MUKDataSourceContentSection *> *)destinationSections;
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
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
/**
 @returns Footer title for matching table section
 */
- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
@end


@interface MUKDataSource (CollectionViewSupport)
/**
 Sets collection view sections
 @param collectionSections An array of MUKDataSourceContentSection objects
 @returns The update to apply to your UICollectionView instance or nil if no update
 is generated
 */
- (MUKDataSourceCollectionUpdate *)setCollectionSections:(nullable NSArray<__kindof MUKDataSourceContentSection *> *)collectionSections;
/**
 You should override this method and provide your custom
 MUKDataSourceCollectionUpdate subclass in order to indicate sections to reload
 @param sourceSections      Collection sections before the update
 @param destinationSections Collection sections after the update
 @returns New collection update. Default implementation returns a valid
 MUKDataSourceCollectionUpdate instance.
 */
- (MUKDataSourceCollectionUpdate *)newCollectionUpdateFromSections:(nullable NSArray<__kindof MUKDataSourceContentSection *> *)sourceSections toSections:(nullable __kindof NSArray<MUKDataSourceContentSection *> *)destinationSections;
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
 Data interpreted as paged content. 
 @warning This returns nil when you use indefinite number of pages (setting
 `self.content = MUKDataSourceIndefiniteContent`)
 */
@property (nonatomic, copy, readonly, nullable) NSArray<MUKDataSourceContentPage> *pages;
/**
 @returns Page at given index or nil, if idx is out of bounds
 */
- (nullable MUKDataSourceContentPage)pageAtIndex:(NSInteger)idx;
/**
 @param viewController The view controller which represents a page
 @returns Page represented by view controller. Default implementation returns nil.
 @warning You need to override this method
 */
- (nullable MUKDataSourceContentPage)pageForViewController:(__kindof UIViewController *)viewController;
/**
 @returns Page after given page.
 @warning You need to override this method if you are using an indefinite number
 of pages.
 */
- (nullable MUKDataSourceContentPage)pageFollowingPage:(MUKDataSourceContentPage)page;
/**
 @returns Page before given page.
 @warning You need to override this method if you are using an indefinite number
 of pages.
 */
- (nullable MUKDataSourceContentPage)pagePrecedingPage:(MUKDataSourceContentPage)page;
/**
 @returns YES if page 1 precedes page 2
 @warning You need to override this method if you are using an indefinite number
 of pages.
 */
- (BOOL)page:(MUKDataSourceContentPage)page1 precedesPage:(MUKDataSourceContentPage)page2;
/**
 @param page Page item
 @returns A new view controller which displays page at given index. Default
 implementation returns nil.
 @warning You need to override this method to provide new view controllers on
 response of user gestures.
 */
- (nullable __kindof UIViewController *)newViewControllerForPage:(MUKDataSourceContentPage)page;
@end

/**
 Implemented methods for UIPageViewControllerDataSource protocol
 */
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
