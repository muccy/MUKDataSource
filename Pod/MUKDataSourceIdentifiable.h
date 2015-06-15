//
//  MUKDataSourceIdentifiable.h
//  
//
//  Created by Marco on 10/06/15.
//
//

#import <Foundation/Foundation.h>

@protocol MUKDataSourceIdentifiable <NSObject>
@optional
@property (nonatomic, copy, readonly) id<NSObject, NSCopying> identifier;
@end
