#import <Foundation/Foundation.h>

/**
 Type of match between two items
 */
typedef NS_ENUM(NSInteger, MUKArrayDeltaMatchType) {
    /**
     No match: items are different
     */
    MUKArrayDeltaMatchTypeNone,
    /**
     Partial match: items are not equal because they change from source array
     to destination array
     */
    MUKArrayDeltaMatchTypeChange,
    /**
     Complete match
     */
    MUKArrayDeltaMatchTypeEqual
};

/**
 A match between two items in source array and destination array
 */
@interface MUKArrayDeltaMatch : NSObject
/**
 Index of matched item in source array
 */
@property (nonatomic, readonly) NSUInteger sourceIndex;
/**
 Index of matched item in destination array
 */
@property (nonatomic, readonly) NSUInteger destinationIndex;
/**
 Type of match
 */
@property (nonatomic, readonly) MUKArrayDeltaMatchType type;
/**
 Designated initializer
 */
- (nonnull instancetype)initWithType:(MUKArrayDeltaMatchType)type sourceIndex:(NSUInteger)sourceIndex destinationIndex:(NSUInteger)destinationIndex NS_DESIGNATED_INITIALIZER;
/**
 @returns YES when two movements are equal
 */
- (BOOL)isEqualToArrayDeltaMatch:(MUKArrayDeltaMatch *__nonnull)match;
@end


/**
 Comparator which takes two items and returns match type
 */
typedef MUKArrayDeltaMatchType (^MUKArrayDeltaMatchTest)(id __nonnull object1, id __nonnull object2);

NS_ASSUME_NONNULL_BEGIN
/**
 An object which tells you diffs between two arrays
 */
@interface MUKArrayDelta : NSObject
/**
 Source array
 */
@property (nonatomic, copy, readonly, nullable) NSArray *sourceArray;
/**
 Destination array
 */
@property (nonatomic, copy, readonly, nullable) NSArray *destinationArray;
/**
 Inserted indexes. Indexes refer to destinationArray.
 */
@property (nonatomic, readonly) NSIndexSet *insertedIndexes;
/**
 Deleted indexes. Indexes refer to sourceArray.
 */
@property (nonatomic, readonly) NSIndexSet *deletedIndexes;
/**
 Set of MUKArrayDeltaMatch objects which represent equal matches
 */
@property (nonatomic, readonly) NSSet *equalMatches;
/**
 Set of MUKArrayDeltaMatch objects which represent partial matches
 */
@property (nonatomic, readonly) NSSet *changes;
/**
 Set of MUKArrayDeltaMatch objects which represent movements.
 A match contained in movements set is contained inside equalMatches or
 changes set, too.
 */
@property (nonatomic, readonly) NSSet *movements;
/**
 Designated initializer.
 @param sourceArray         Source array
 @param destinationArray    Destination array
 @param matchTest           A block to compare source and destination items.
                            It may be nil but you lose changes detection.
 @returns A fully initialized delta between sourceArray and destinationArray
 */
- (instancetype)initWithSourceArray:(NSArray *__nullable)sourceArray destinationArray:(NSArray *__nullable)destinationArray matchTest:(nullable MUKArrayDeltaMatchTest)matchTest NS_DESIGNATED_INITIALIZER;
/**
 @returns YES when two deltas are equal
 */
- (BOOL)isEqualToArrayDelta:(MUKArrayDelta *)arrayDelta;
/**
 @returns Projected source index to destination taking into account only insertions
 before, deletions before and movements happened so far
 */
- (NSUInteger)intermediateDestinationIndexForMovement:(MUKArrayDeltaMatch *)movement;
@end
NS_ASSUME_NONNULL_END
