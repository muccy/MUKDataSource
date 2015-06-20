#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceIdentifiable.h>

/**
 A section of content
 */
@protocol MUKDataSourceContentSection <MUKDataSourceIdentifiable>
@required
/**
 Items inside the section
 */
@property (nonatomic, copy, readonly) NSArray *items;
@end


/**
 Base class to implement MUKDataSourceContentSection protocol
 */
@interface MUKDataSourceContentSection : NSObject <MUKDataSourceContentSection>
/**
 @brief         Section identifier
 @discussion    You should give a value when you're interested in detecting
                changes
 */
@property (nonatomic, copy, readonly) id<NSObject, NSCopying> identifier;
/**
 Designated initializer
 */
- (instancetype)initWithIdentifier:(id<NSCopying>)identifier items:(NSArray *)items;
/**
 @returns YES when section is equal to self
 */
- (BOOL)isEqualToDataSourceContentSection:(MUKDataSourceContentSection *)section;
/**
 @param newItems New items of resulting section
 @returns New section with same identifier but with newItems instead of current ones
 */
- (instancetype)sectionByReplacingItemsWithItems:(NSArray *)newItems;
/**
 @brief Shortend to sectionByReplacingItemsWithItems: to remove an item
 @discussion If you have overridden sectionByReplacingItemsWithItems: you don't
 have to override also this method
 @param idx Item index to remove
 @returns New section with same identifier but without item at given index
 */
- (instancetype)sectionByRemovingItemAtIndex:(NSUInteger)idx;
/**
 @brief Shortend to sectionByReplacingItemsWithItems: to insert an item
 @discussion If you have overridden sectionByReplacingItemsWithItems: you don't
 have to override also this method
 @param idx Index where to insert item
 @returns New section with same identifier but with item inserted at given index
 */
- (instancetype)sectionByInsertingItem:(id)item atIndex:(NSUInteger)idx;
@end
