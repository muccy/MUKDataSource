//
//  MUKDataSource.h
//  
//
//  Created by Marco on 10/06/15.
//
//

#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceTableSection.h>

@interface MUKDataSource : NSObject
@property (nonatomic, copy) id<NSObject, NSCopying> content;
@end

@interface MUKDataSource (SectionedContent)
@property (nonatomic, copy) NSArray *sections;
- (id<MUKDataSourceContentSection>)sectionAtIndex:(NSInteger)idx;
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
@end

/*
 Implemented:
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)idx
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
 - (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
 - (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
 */
@interface MUKDataSource (TableViewSupport) <UITableViewDataSource>
- (MUKDataSourceTableSection *)tableSectionAtIndex:(NSInteger)idx;
- (id<MUKDataSourceIdentifiable>)tableRowItemAtIndexPath:(NSIndexPath *)indexPath;
@end