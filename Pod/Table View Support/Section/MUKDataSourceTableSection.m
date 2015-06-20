#import "MUKDataSourceTableSection.h"

@implementation MUKDataSourceTableSection

- (instancetype)initWithIdentifier:(id<NSCopying>)identifier items:(NSArray *)items headerTitle:(NSString *)headerTitle footerTitle:(NSString *)footerTitle
{
    self = [super initWithIdentifier:identifier items:items];
    if (self) {
        _headerTitle = [headerTitle copy];
        _footerTitle = [footerTitle copy];
    }

    return self;
}

- (BOOL)isEqualToDataSourceTableSection:(MUKDataSourceTableSection *)tableSection
{
    if (![self isEqualToDataSourceContentSection:tableSection]) {
        return NO;
    }

    BOOL const sameHeaderTitle = (!self.headerTitle && !tableSection.headerTitle) || [self.headerTitle isEqualToString:tableSection.headerTitle];
    BOOL const sameFooterTitle = (!self.footerTitle && !tableSection.footerTitle) || [self.footerTitle isEqualToString:tableSection.footerTitle];
    
    return sameHeaderTitle && sameFooterTitle;
}

#pragma mark - Overrides

- (instancetype)sectionByReplacingItemsWithItems:(NSArray *)newItems {
    MUKDataSourceTableSection *const tableSection = [super sectionByReplacingItemsWithItems:newItems];
    tableSection->_headerTitle = self.headerTitle;
    tableSection->_footerTitle = self.footerTitle;
    
    return tableSection;
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
    return 63429 ^ [self.identifier hash] ^ [self.items hash] ^ [self.headerTitle hash] ^ [self.footerTitle hash];
}

@end
