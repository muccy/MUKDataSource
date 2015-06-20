#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceContentSection.h>

/**
 Representation of a collection section
 */
@interface MUKDataSourceCollectionSection : MUKDataSourceContentSection
/**
 @returns YES when tableSection is equal to self
 */
- (BOOL)isEqualToDataSourceCollectionSection:(MUKDataSourceCollectionSection *)collectionSection;
@end
