#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceContentSection.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Representation of a table section
 */
@interface MUKDataSourceTableSection : MUKDataSourceContentSection
/**
 Header title
 */
@property (nonatomic, copy, readonly, nullable) NSString *headerTitle;
/**
 Footer title
 */
@property (nonatomic, copy, readonly, nullable) NSString *footerTitle;
/**
 Designated initializer
 */
- (instancetype)initWithIdentifier:(nullable id<NSCopying>)identifier items:(NSArray *__nullable)items headerTitle:(NSString *__nullable)headerTitle footerTitle:(NSString *__nullable)footerTitle NS_DESIGNATED_INITIALIZER;
/**
 @returns YES when tableSection is equal to self
 */
- (BOOL)isEqualToDataSourceTableSection:(MUKDataSourceTableSection *)tableSection;
@end

NS_ASSUME_NONNULL_END
