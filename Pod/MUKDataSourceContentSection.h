//
//  MUKDataSourceContentSection.h
//  
//
//  Created by Marco on 10/06/15.
//
//

#import <Foundation/Foundation.h>

@protocol MUKDataSourceContentSection <NSObject>
@required
@property (nonatomic, copy, readonly) NSArray *items;
@end
