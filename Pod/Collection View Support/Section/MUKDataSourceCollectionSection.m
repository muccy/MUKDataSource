//
//  MUKDataSourceCollectionSection.m
//  
//
//  Created by Marco on 16/06/15.
//
//

#import "MUKDataSourceCollectionSection.h"

@implementation MUKDataSourceCollectionSection
@synthesize identifier = _identifier;
@synthesize items = _items;

- (instancetype)initWithIdentifier:(id<NSCopying>)identifier items:(NSArray *)items
{
    self = [super init];
    if (self) {
        _identifier = [(id)identifier copy];
        _items = [items copy];
    }
    
    return self;
}

- (BOOL)isEqualToDataSourceCollectionSection:(MUKDataSourceCollectionSection *)collectionSection
{
    BOOL const sameIdentifier = (!self.identifier && !collectionSection.identifier) || [self.identifier isEqual:collectionSection.identifier];
    BOOL const sameItems = (!self.items && !collectionSection.items) || [self.items isEqualToArray:collectionSection.items];
   
    return sameIdentifier && sameItems;
}

#pragma mark - Overrides

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self isEqualToDataSourceCollectionSection:object];
    }
    
    return NO;
}

- (NSUInteger)hash {
    return 634289 ^ [self.identifier hash] ^ [self.items hash];
}

@end
