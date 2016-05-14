#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceIdentifiable.h>

NS_ASSUME_NONNULL_BEGIN

typedef __kindof id<NSObject> MUKDataSourceContentSectionHeaderFooter;

/// A section of content used with MUKSectionedDataSource
@interface MUKDataSourceContentSection<__covariant ItemType> : NSObject <MUKDataSourceIdentifiable>
/**
 Items inside the section
 */
@property (nonatomic, copy, readonly, nullable) NSArray<ItemType> *items;
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
- (instancetype)initWithIdentifier:(nullable MUKDataSourceIdentifier)identifier items:(nullable NSArray<ItemType> *)items header:(nullable MUKDataSourceContentSectionHeaderFooter)header footer:(nullable MUKDataSourceContentSectionHeaderFooter)footer NS_DESIGNATED_INITIALIZER;
/**
 Convenience identifier which sets to nil both header and footer
 */
- (instancetype)initWithIdentifier:(nullable MUKDataSourceIdentifier)identifier items:(nullable NSArray<ItemType> *)items;
/**
 @returns YES when section is equal to self
 */
- (BOOL)isEqualToDataSourceContentSection:(MUKDataSourceContentSection<ItemType> *)section;
/**
 @param newItems New items of resulting section
 @returns New section with same identifier but with newItems instead of current ones
 */
- (instancetype)sectionByReplacingItemsWithItems:(nullable NSArray<ItemType> *)newItems;
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
- (instancetype)sectionByInsertingItem:(ItemType)item atIndex:(NSUInteger)idx;
/**
 @brief Shortend to sectionByReplacingItemsWithItems: to replace an item with
 another
 @discussion If you have overridden sectionByReplacingItemsWithItems: you don't
 have to override also this method
 @param idx Index of item to replace
 @param newItem New item to insert in place of old one
 @returns New section with same identifier but with item replaced
 */
- (instancetype)sectionByReplacingItemAtIndex:(NSUInteger)idx withItem:(ItemType)newItem;
@end

NS_ASSUME_NONNULL_END
