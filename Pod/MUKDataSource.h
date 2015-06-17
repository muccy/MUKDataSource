//
//  MUKDataSource.h
//  
//
//  Created by Marco on 10/06/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKDataSourceTableSection.h>
#import <MUKDataSource/MUKDataSourceTableUpdate.h>
#import <MUKDataSource/MUKDataSourceCollectionSection.h>
#import <MUKDataSource/MUKDataSourceCollectionUpdate.h>

@interface MUKDataSource : NSObject
@property (nonatomic, copy) id<NSObject, NSCopying> content;
@end

@interface MUKDataSource (SectionedContent)
@property (nonatomic, readonly) NSArray *sections;
- (id<MUKDataSourceContentSection>)sectionAtIndex:(NSInteger)idx;
- (id<MUKDataSourceIdentifiable>)itemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface MUKDataSource (TableViewSupport)
- (MUKDataSourceTableUpdate *)setTableSections:(NSArray *)tableSections;
- (MUKDataSourceTableSection *)tableSectionAtIndex:(NSInteger)idx;
- (MUKDataSourceTableUpdate *)newTableUpdateFromSections:(NSArray *)sourceSections toSections:(NSArray *)destinationSections;
@end

@interface MUKDataSource (UITableViewDataSourceImplementedMethods) <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)idx;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface MUKDataSource (CollectionViewSupport)
- (MUKDataSourceCollectionUpdate *)setCollectionSections:(NSArray *)sections;
- (MUKDataSourceCollectionSection *)collectionSectionAtIndex:(NSInteger)idx;
- (MUKDataSourceCollectionUpdate *)newCollectionUpdateFromSections:(NSArray *)sourceSections toSections:(NSArray *)destinationSections;
@end

@interface MUKDataSource (UICollectionViewDataSourceImplementedMethods) <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
@end
