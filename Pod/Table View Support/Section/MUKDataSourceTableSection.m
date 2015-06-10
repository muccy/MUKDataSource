//
//  MUKDataSourceTableSection.m
//  
//
//  Created by Marco on 10/06/15.
//
//

#import "MUKDataSourceTableSection.h"

@implementation MUKDataSourceTableSection
@synthesize identifier = _identifier;
@synthesize items = _items;

- (instancetype)initWithIdentifier:(id<NSCopying>)identifier items:(NSArray *)items headerTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle
{
    self = [super init];
    if (self) {
        _identifier = [(id)identifier copy];
        _items = [items copy];
        _headerTitle = [headerTitle copy];
        _footerTitle = [footerTitle copy];
    }

    return self;
}

- (BOOL)isEqualToDataSourceTableSection:(MUKDataSourceTableSection *)tableSection
{
    BOOL const sameIdentifier = (!self.identifier && !tableSection.identifier) || [self.identifier isEqual:tableSection.identifier];
    BOOL const sameItems = (!self.items && !tableSection.items) || [self.items isEqualToArray:tableSection.items];
    BOOL const sameHeaderTitle = (!self.headerTitle && !tableSection.headerTitle) || [self.headerTitle isEqualToString:tableSection.headerTitle];
    BOOL const sameFooterTitle = (!self.footerTitle && !tableSection.footerTitle) || [self.footerTitle isEqualToString:tableSection.footerTitle];
    
    return sameIdentifier && sameItems && sameHeaderTitle && sameFooterTitle;
}

#pragma mark - Overrides

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self isEqualToDataSourceTableSection:object];
    }
    
    return NO;
}

- (NSUInteger)hash {
    return 634209 ^ [self.identifier hash] ^ [self.items hash] ^ [self.headerTitle hash] ^ [self.footerTitle hash];
}

@end
