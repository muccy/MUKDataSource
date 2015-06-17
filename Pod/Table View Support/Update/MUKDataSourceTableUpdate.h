//
//  MUKDataSourceTableSectionsUpdate.h
//  
//
//  Created by Marco on 11/06/15.
//
//

#import <MUKDataSource/MUKDataSourceSectionedContentUpdate.h>

@interface MUKDataSourceTableUpdate : MUKDataSourceSectionedContentUpdate
@property (nonatomic, readonly) BOOL needsReloadData;
- (void)applyToTableView:(UITableView *)tableView animated:(BOOL)animated;
@end
