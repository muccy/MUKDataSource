//
//  MUKDataSourceSectionedContentUpdate.h
//  
//
//  Created by Marco on 16/06/15.
//
//

#import <Foundation/Foundation.h>

@interface MUKDataSourceContentSectionMovement : NSObject
@property (nonatomic, readonly) NSUInteger sourceIndex;
@property (nonatomic, readonly) NSUInteger destinationIndex;
- (instancetype)initWithSourceIndex:(NSUInteger)sourceIndex destinationIndex:(NSUInteger)destinationIndex;
- (BOOL)isEqualToContentSectionMovement:(MUKDataSourceContentSectionMovement *)movement;
@end

#pragma mark - 

@interface MUKDataSourceContentSectionItemMovement : NSObject
@property (nonatomic, readonly) NSIndexPath *sourceIndexPath;
@property (nonatomic, readonly) NSIndexPath *destinationIndexPath;
- (instancetype)initWithSourceIndexPath:(NSIndexPath *)sourceIndexPath destinationIndexPath:(NSIndexPath *)destinationIndexPath;
- (BOOL)isEqualToContentSectionItemMovement:(MUKDataSourceContentSectionItemMovement *)movement;
@end

#pragma mark -

@protocol MUKDataSourceContentSection;
@interface MUKDataSourceSectionedContentUpdate : NSObject
@property (nonatomic, copy, readonly) NSArray *sourceSections;
@property (nonatomic, copy, readonly) NSArray *destinationSections;

@property (nonatomic, readonly) NSIndexSet *insertedSectionIndexes;
@property (nonatomic, readonly) NSIndexSet *deletedSectionIndexes;
@property (nonatomic, readonly) NSIndexSet *reloadedSectionIndexes;
@property (nonatomic, readonly) NSSet *sectionMovements;

@property (nonatomic, readonly) NSSet *insertedItemIndexPaths;
@property (nonatomic, readonly) NSSet *deletedItemIndexPaths;
@property (nonatomic, readonly) NSSet *reloadedItemIndexPaths;
@property (nonatomic, readonly) NSSet *itemMovements;

- (instancetype)initWithSourceSections:(NSArray *)sourceSections destinationSections:(NSArray *)destinationSections;
@end

@class MUKArrayDelta, MUKArrayDeltaMatch;
@interface MUKDataSourceSectionedContentUpdate (Build)
- (NSIndexSet *)insertedSectionIndexesFromDelta:(MUKArrayDelta *)delta;
- (NSIndexSet *)deletedSectionIndexesFromDelta:(MUKArrayDelta *)delta;
- (MUKDataSourceContentSectionMovement *)sectionMovementForDelta:(MUKArrayDelta *)delta movement:(MUKArrayDeltaMatch *)movement;
- (NSUInteger)reloadedSectionIndexForDelta:(MUKArrayDelta *)delta change:(MUKArrayDeltaMatch *)change;

- (NSIndexPath *)insertedItemIndexPathForDelta:(MUKArrayDelta *)delta insertedIndex:(NSUInteger)idx sectionMatch:(MUKArrayDeltaMatch *)sectionMatch;
- (NSIndexPath *)deletedItemIndexPathForDelta:(MUKArrayDelta *)delta deletedIndex:(NSUInteger)idx sectionMatch:(MUKArrayDeltaMatch *)sectionMatch;
- (MUKDataSourceContentSectionItemMovement *)itemMovementForDelta:(MUKArrayDelta *)delta movement:(MUKArrayDeltaMatch *)movement sectionMatch:(MUKArrayDeltaMatch *)sectionMatch;
- (NSIndexPath *)reloadedItemIndexPathForDelta:(MUKArrayDelta *)delta change:(MUKArrayDeltaMatch *)change sectionMatch:(MUKArrayDeltaMatch *)sectionMatch;
@end
