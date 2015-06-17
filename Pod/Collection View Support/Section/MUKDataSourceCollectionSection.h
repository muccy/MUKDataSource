//
//  MUKDataSourceCollectionSection.h
//  
//
//  Created by Marco on 16/06/15.
//
//

#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceContentSection.h>

@interface MUKDataSourceCollectionSection : NSObject <MUKDataSourceContentSection>
- (instancetype)initWithIdentifier:(id<NSCopying>)identifier items:(NSArray *)items;
@end
