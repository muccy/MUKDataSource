#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 @brief         State of content which should cover all items
 @discussion    You can set a MUKDataSourceContentPlaceholder object as
                dataSource.content to cover every item
 */
@interface MUKDataSourceContentPlaceholder : NSObject <NSCopying>
/**
 Placeholder image
 */
@property (nonatomic, readonly, nullable) UIImage *image;
/**
 Placeholder title
 */
@property (nonatomic, readonly, copy, nullable) NSString *title;
/**
 Placeholder subtitle
 */
@property (nonatomic, readonly, copy, nullable) NSString *subtitle;
/**
 Designated initializer
 */
- (instancetype)initWithTitle:(NSString *__nullable)title subtitle:(NSString *__nullable)subtitle image:(UIImage *__nullable)image NS_DESIGNATED_INITIALIZER;
/**
 @returns YES if passed placeholder is equal to self
 */
- (BOOL)isEqualToContentPlaceholder:(MUKDataSourceContentPlaceholder *)placeholder;
@end

NS_ASSUME_NONNULL_END
