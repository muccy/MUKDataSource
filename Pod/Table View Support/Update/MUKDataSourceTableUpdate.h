//
//  MUKDataSourceTableSectionsUpdate.h
//  
//
//  Created by Marco on 11/06/15.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MUKDataSourceTableUpdateSectionMovement : NSObject
@property (nonatomic, readonly) NSUInteger sourceIndex;
@property (nonatomic, readonly) NSUInteger destinationIndex;
- (instancetype)initWithSourceIndex:(NSUInteger)sourceIndex destinationIndex:(NSUInteger)destinationIndex;
- (BOOL)isEqualToTableUpdateSectionMovement:(MUKDataSourceTableUpdateSectionMovement *)movement;
@end

@interface MUKDataSourceTableUpdateRowMovement : NSObject
@property (nonatomic, readonly) NSIndexPath *sourceIndexPath;
@property (nonatomic, readonly) NSIndexPath *destinationIndexPath;
- (instancetype)initWithSourceIndexPath:(NSIndexPath *)sourceIndexPath destinationIndexPath:(NSIndexPath *)destinationIndexPath;
- (BOOL)isEqualToTableUpdateRowMovement:(MUKDataSourceTableUpdateRowMovement *)movement;
@end

@interface MUKDataSourceTableUpdate : NSObject
@property (nonatomic, copy, readonly) NSArray *sourceTableSections;
@property (nonatomic, copy, readonly) NSArray *destinationTableSections;

@property (nonatomic, readonly) NSIndexSet *insertedSectionIndexes;
@property (nonatomic, readonly) NSIndexSet *deletedSectionIndexes;
@property (nonatomic, readonly) NSIndexSet *reloadedSectionIndexes; // Indexes after insertion, deletion, movements
@property (nonatomic, readonly) NSSet *sectionMovements;

@property (nonatomic, readonly) NSSet *insertedRowIndexPaths;
@property (nonatomic, readonly) NSSet *deletedRowIndexPaths;
@property (nonatomic, readonly) NSSet *reloadedRowIndexPaths;
@property (nonatomic, readonly) NSSet *rowMovements;

@property (nonatomic, readonly) BOOL needsReloadData;

- (instancetype)initWithSourceTableSections:(NSArray *)sourceSections destinationTableSections:(NSArray *)destinationSections;
- (void)applyToTableView:(UITableView *)tableView animated:(BOOL)animated;
@end
