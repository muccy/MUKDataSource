#import <Foundation/Foundation.h>

typedef __kindof id<NSObject, NSCopying> MUKDataSourceIdentifier;

/**
 An identifiable object.
 If your classes conforms this protocol, more features are enabled automatically
 (e.g.: moving rows in a table view)
 */
@protocol MUKDataSourceIdentifiable <NSObject>
@required
/**
 A value which identifies an object helps to find its change between two immutable
 states (e.g.: a changed object inside between two immutable arrays)
 */
@property (nonatomic, copy, readonly, nullable) MUKDataSourceIdentifier identifier;
@end
