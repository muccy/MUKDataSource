//
//  MUKDataSourceTableSection.h
//  
//
//  Created by Marco on 10/06/15.
//
//

#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceContentSection.h>
#import <MUKDataSource/MUKDataSourceIdentifiable.h>

@interface MUKDataSourceTableSection : NSObject <MUKDataSourceContentSection, MUKDataSourceIdentifiable>
@property (nonatomic, copy, readonly) NSString *headerTitle;
@property (nonatomic, copy, readonly) NSString *footerTitle;
- (instancetype)initWithIdentifier:(id<NSCopying>)identifier items:(NSArray *)items headerTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle;
- (BOOL)isEqualToDataSourceTableSection:(MUKDataSourceTableSection *)tableSection;
@end
