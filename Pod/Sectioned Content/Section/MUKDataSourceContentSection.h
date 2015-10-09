#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceIdentifiable.h>

NS_ASSUME_NONNULL_BEGIN

typedef __kindof id<MUKDataSourceIdentifiable> MUKDataSourceContentSectionItem;
typedef __kindof id<NSObject> MUKDataSourceContentSectionHeaderFooter;

/**
 Base class to implement MUKDataSourceContentSection protocol
 */
@interface MUKDataSourceContentSection : NSObject <MUKDataSourceIdentifiable>
/**
 @brief         Section identifier
 @discussion    You should give a value when you're interested in detecting
                changes
 */
@property (nonatomic, copy, readonly, nullable) id<NSObject, NSCopying> identifier;
/**
 Items inside the section
 */
@property (nonatomic, copy, readonly, nullable) NSArray<MUKDataSourceContentSectionItem> *items;
/**
 Object which identifies represents header
 */
@property (nonatomic, readonly, nullable) MUKDataSourceContentSectionHeaderFooter header;
/**
 Object which identifies represents footer
 */
@property (nonatomic, readonly, nullable) MUKDataSourceContentSectionHeaderFooter footer;
/**
 Designated initializer
 */
- (instancetype)initWithIdentifier:(nullable MUKDataSourceIdentifier)identifier items:(nullable NSArray<MUKDataSourceContentSectionItem> *)items header:(nullable MUKDataSourceContentSectionHeaderFooter)header footer:(nullable MUKDataSourceContentSectionHeaderFooter)footer NS_DESIGNATED_INITIALIZER;
/**
 Convenience identifier which sets to nil both header and footer
 */
- (instancetype)initWithIdentifier:(nullable MUKDataSourceIdentifier)identifier items:(nullable NSArray<MUKDataSourceContentSectionItem> *)items;
/**
 @returns YES when section is equal to self
 */
- (BOOL)isEqualToDataSourceContentSection:(MUKDataSourceContentSection *)section;
/**
 @param newItems New items of resulting section
 @returns New section with same identifier but with newItems instead of current ones
 */
- (instancetype)sectionByReplacingItemsWithItems:(nullable NSArray<MUKDataSourceContentSectionItem> *)newItems;
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
 @param item Item to insert
 @param idx Index where to insert item
 @returns New section with same identifier but with item inserted at given index
 */
- (instancetype)sectionByInsertingItem:(MUKDataSourceContentSectionItem)item atIndex:(NSUInteger)idx;
/**
 @brief Shortend to sectionByReplacingItemsWithItems: to replace an item with
 another
 @discussion If you have overridden sectionByReplacingItemsWithItems: you don't
 have to override also this method
 @param idx Index of item to replace
 @param newItem New item to insert in place of old one
 @returns New section with same identifier but with item replaced
 */
- (instancetype)sectionByReplacingItemAtIndex:(NSUInteger)idx withItem:(MUKDataSourceContentSectionItem)newItem;
@end

NS_ASSUME_NONNULL_END
