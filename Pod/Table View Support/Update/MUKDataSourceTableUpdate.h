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
- (instancetype)initWithSourceIndex:(NSIndexPath *)sourceIndexPath destinationIndex:(NSIndexPath *)destinationIndexPath;
- (BOOL)isEqualToTableUpdateRowMovement:(MUKDataSourceTableUpdateRowMovement *)movement;
@end

@interface MUKDataSourceTableUpdate : NSObject
@property (nonatomic, copy, readonly) NSArray *sourceTableSections;
@property (nonatomic, copy, readonly) NSArray *destinationTableSections;

@property (nonatomic, readonly) NSIndexSet *insertedSectionIndexes;
@property (nonatomic, readonly) NSIndexSet *deletedSectionIndexes;
@property (nonatomic, readonly) NSIndexSet *reloadedSectionIndexes;
@property (nonatomic, readonly) NSSet *sectionMovements;

@property (nonatomic, readonly) NSArray *insertedRowIndexPaths;
@property (nonatomic, readonly) NSArray *deletedRowIndexPaths;
@property (nonatomic, readonly) NSArray *reloadedRowIndexPaths;
@property (nonatomic, readonly) NSSet *rowMovements;

- (instancetype)initWithSourceTableSections:(NSArray *)sourceSections destinationTableSections:(NSArray *)destinationSections;
- (void)applyToTableView:(UITableView *)tableView animated:(BOOL)animated;
@end
