#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 An object which conforms content placeholder protocol represents a particular
 state of content which should cover all items
 */
@protocol MUKDataSourceContentPlaceholder <NSObject, NSCopying>
@end

/**
 @brief         A concrete implementation of content placeholder protocol.
 @discussion    You can set a MUKDataSourceContentPlaceholder object as
                dataSource.content to cover every item
 */
@interface MUKDataSourceContentPlaceholder : NSObject <MUKDataSourceContentPlaceholder>
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
