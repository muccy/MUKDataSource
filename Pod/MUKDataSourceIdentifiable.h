//
//  MUKDataSourceIdentifiable.h
//  
//
//  Created by Marco on 10/06/15.
//
//

#import <Foundation/Foundation.h>

@protocol MUKDataSourceIdentifiable <NSObject>
@required
@property (nonatomic, copy, readonly) id<NSObject, NSCopying> identifier;
@end
