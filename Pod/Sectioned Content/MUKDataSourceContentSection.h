//
//  MUKDataSourceContentSection.h
//  
//
//  Created by Marco on 10/06/15.
//
//

#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceIdentifiable.h>

@protocol MUKDataSourceContentSection <MUKDataSourceIdentifiable>
@required
@property (nonatomic, copy, readonly) NSArray *items;
@end
