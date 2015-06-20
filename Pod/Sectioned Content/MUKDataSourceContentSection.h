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
