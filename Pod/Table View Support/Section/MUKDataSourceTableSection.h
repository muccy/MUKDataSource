#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceContentSection.h>

/**
 Representation of a table section
 */
@interface MUKDataSourceTableSection : MUKDataSourceContentSection
/**
 Header title
 */
@property (nonatomic, copy, readonly) NSString *headerTitle;
/**
 Footer title
 */
@property (nonatomic, copy, readonly) NSString *footerTitle;
/**
 Designated initializer
 */
- (instancetype)initWithIdentifier:(id<NSCopying>)identifier items:(NSArray *)items headerTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle;
/**
 @returns YES when tableSection is equal to self
 */
- (BOOL)isEqualToDataSourceTableSection:(MUKDataSourceTableSection *)tableSection;
@end
