#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Movement of content section
 */
@interface MUKDataSourceContentSectionMovement : NSObject
/**
 Index where movement starts
 */
@property (nonatomic, readonly) NSUInteger sourceIndex;
/**
 Index where movement ends
 */
@property (nonatomic, readonly) NSUInteger destinationIndex;
/**
 Designated initializer
 */
- (instancetype)initWithSourceIndex:(NSUInteger)sourceIndex destinationIndex:(NSUInteger)destinationIndex NS_DESIGNATED_INITIALIZER;
/**
 @returns YES when passed movement equals to self
 */
- (BOOL)isEqualToContentSectionMovement:(MUKDataSourceContentSectionMovement *)movement;
@end

#pragma mark -

/**
 Movement of section item
 */
@interface MUKDataSourceContentSectionItemMovement : NSObject
/**
 Index path where movement starts
 */
@property (nonatomic, readonly) NSIndexPath *sourceIndexPath;
/**
 Index path where movement ends
 */
@property (nonatomic, readonly) NSIndexPath *destinationIndexPath;
/**
 Designated initializer
 */
- (instancetype)initWithSourceIndexPath:(NSIndexPath *)sourceIndexPath destinationIndexPath:(NSIndexPath *)destinationIndexPath;
/**
 @returns YES when passed movement equals to self
 */
- (BOOL)isEqualToContentSectionItemMovement:(MUKDataSourceContentSectionItemMovement *)movement;
@end

#pragma mark -

/**
 How sectioned content should be updated to reflect the transition from
 source sections to destination sections
 */
@interface MUKDataSourceSectionedContentUpdate : NSObject
/**
 Original sections
 */
@property (nonatomic, copy, readonly, nullable) NSArray *sourceSections;
/**
 Sections after transition
 */
@property (nonatomic, copy, readonly, nullable) NSArray *destinationSections;
/**
 Indexes of inserted sections
 */
@property (nonatomic, readonly) NSIndexSet *insertedSectionIndexes;
/**
 Indexes of deleted sections
 */
@property (nonatomic, readonly) NSIndexSet *deletedSectionIndexes;
/**
 Indexes of sections to reload.
 */
@property (nonatomic, readonly) NSIndexSet *reloadedSectionIndexes;
/**
 A set of MUKDataSourceContentSectionMovement objects which express movements
 of sections from source to destination
 */
@property (nonatomic, readonly) NSSet *sectionMovements;
/**
 Index paths of inserted items (inside sections)
 */
@property (nonatomic, readonly) NSSet *insertedItemIndexPaths;
/**
 Index paths of deleted items (from sections)
 */
@property (nonatomic, readonly) NSSet *deletedItemIndexPaths;
/**
 Index paths of items to reload (inside sections) because they are changed
 */
@property (nonatomic, readonly) NSSet *reloadedItemIndexPaths;
/**
 A set of MUKDataSourceContentSectionItemMovement objects which express movements
 of items from source to destination, also between different sections
 */
@property (nonatomic, readonly) NSSet *itemMovements;
/**
 YES when there are no insertions, no deletions, no reloads, no movements
 */
@property (nonatomic, readonly, getter=isEmpty) BOOL empty;
/**
 Designated initializer
 */
- (instancetype)initWithSourceSections:(NSArray *__nullable)sourceSections destinationSections:(NSArray *__nullable)destinationSections;
@end

@class MUKArrayDelta, MUKArrayDeltaMatch;
/**
 Methods called to build ivar values
 */
@interface MUKDataSourceSectionedContentUpdate (Build)
/**
 @param delta Array delta between sourceSections and destinationSections
 @returns Indexes of inserted sections
 */
- (NSIndexSet *)insertedSectionIndexesFromDelta:(MUKArrayDelta *)delta;
/**
 @param delta Array delta between sourceSections and destinationSections
 @returns Indexes of deleted sections
 */
- (NSIndexSet *)deletedSectionIndexesFromDelta:(MUKArrayDelta *)delta;
/**
 @param delta       Array delta between sourceSections and destinationSections
 @param movement    Single movement found by delta
 @returns Movement of section
 */
- (MUKDataSourceContentSectionMovement *)sectionMovementForDelta:(MUKArrayDelta *)delta movement:(MUKArrayDeltaMatch *)movement;
/**
 @param delta   Array delta between sourceSections and destinationSections
 @param change  Single change found by delta
 @returns Section index to reload
 @warning Default implementation returns NSNotFound
 */
- (NSUInteger)reloadedSectionIndexForDelta:(MUKArrayDelta *)delta change:(MUKArrayDeltaMatch *)change;
/**
 @param delta           Array delta between source section items and destination
                        section items
 @param idx             Inserted index (in destination array coordinates)
 @param sectionMatch    Match between source section and destination section
 @returns   Inserted index path using sectionMatch destination index
            as section and idx as item
 */
- (NSIndexPath *)insertedItemIndexPathForDelta:(MUKArrayDelta *)delta insertedIndex:(NSUInteger)idx sectionMatch:(MUKArrayDeltaMatch *)sectionMatch;
/**
 @param delta           Array delta between source section items and destination
 section items
 @param idx             Deleted index (in source array coordinates)
 @param sectionMatch    Match between source section and destination section
 @returns   Deleted index path using sectionMatch source index
            as section and idx as item
 */
- (NSIndexPath *)deletedItemIndexPathForDelta:(MUKArrayDelta *)delta deletedIndex:(NSUInteger)idx sectionMatch:(MUKArrayDeltaMatch *)sectionMatch;
/**
 @param delta           Array delta between source section items and destination
                        section items
 @param movement        Single movement detected by delta
 @param sectionMatch    Match between source section and destination section
 @returns   Movement from (movement.sourceIndex, sectionMatch.sourceIndex) index
            path to (movement.destinationIndex, sectionMatch.destinationIndex) 
            index path
 */
- (MUKDataSourceContentSectionItemMovement *)itemMovementForDelta:(MUKArrayDelta *)delta movement:(MUKArrayDeltaMatch *)movement sectionMatch:(MUKArrayDeltaMatch *)sectionMatch;
/**
 @param delta           Array delta between source section items and destination
                        section items
 @param change          Single change detected by delta
 @param sectionMatch    Match between source section and destination section
 @returns   Index path to reload using sectionMatch source index as section and
            change source index as item
 */
- (NSIndexPath *)reloadedItemIndexPathForDelta:(MUKArrayDelta *)delta change:(MUKArrayDeltaMatch *)change sectionMatch:(MUKArrayDeltaMatch *)sectionMatch;
@end

NS_ASSUME_NONNULL_END
