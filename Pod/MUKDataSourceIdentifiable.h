#import <Foundation/Foundation.h>

/**
 An identifiable object, optionally
 */
@protocol MUKDataSourceIdentifiable <NSObject>
@optional
/**
 A value which identifies an object helps to find its change between two immutable 
 states (e.g.: a changed object inside between two immutable arrays)
 */
@property (nonatomic, copy, readonly, nullable) id<NSObject, NSCopying> identifier;
@end
