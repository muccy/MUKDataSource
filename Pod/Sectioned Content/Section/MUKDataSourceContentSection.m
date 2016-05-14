#import "MUKDataSourceContentSection.h"

@implementation MUKDataSourceContentSection
@synthesize identifier = _identifier;
@synthesize items = _items;

- (instancetype)initWithIdentifier:(MUKDataSourceIdentifier)identifier items:(NSArray *)items header:(nullable MUKDataSourceContentSectionHeaderFooter)header footer:(nullable MUKDataSourceContentSectionHeaderFooter)footer
{
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
        _items = [items copy];
        _header = header;
        _footer = footer;
    }
    
    return self;
}

- (instancetype)initWithIdentifier:(MUKDataSourceIdentifier)identifier items:(NSArray *)items
{
    return [self initWithIdentifier:identifier items:items header:nil footer:nil];
}

- (BOOL)isEqualToDataSourceContentSection:(MUKDataSourceContentSection *)section
{
    BOOL const sameIdentifier = (!self.identifier && !section.identifier) || [self.identifier isEqual:section.identifier];
    BOOL const sameItems = (!self.items && !section.items) || [self.items isEqualToArray:section.items];
    BOOL const sameHeader = (!self.header && !section.header) || [self.header isEqual:section.header];
    BOOL const sameFooter = (!self.footer && !section.footer) || [self.footer isEqual:section.footer];
    
    return sameIdentifier && sameItems && sameHeader && sameFooter;
}

- (instancetype)sectionByReplacingItemsWithItems:(NSArray *)newItems
{
    return [[[self class] alloc] initWithIdentifier:self.identifier items:newItems header:self.header footer:self.footer];
}

- (instancetype)sectionByRemovingItemAtIndex:(NSUInteger)idx {
    if (idx >= self.items.count) {
        return self;
    }
    
    NSMutableArray *const items = [self.items mutableCopy];
    [items removeObjectAtIndex:idx];
    
    return [self sectionByReplacingItemsWithItems:items];
}

- (instancetype)sectionByInsertingItem:(id)item atIndex:(NSUInteger)idx
{
    if (!item || idx > self.items.count) {
        return self;
    }
    
    NSMutableArray *const items = [self.items mutableCopy];
    [items insertObject:item atIndex:idx];
    
    return [self sectionByReplacingItemsWithItems:items];
}

- (instancetype)sectionByReplacingItemAtIndex:(NSUInteger)idx withItem:(id)newItem
{
    if (!newItem || idx >= self.items.count) {
        return self;
    }
    
    NSMutableArray *const items = [self.items mutableCopy];
    [items replaceObjectAtIndex:idx withObject:newItem];
    
    return [self sectionByReplacingItemsWithItems:items];
}

#pragma mark - Overrides

- (instancetype)init {
    return [self initWithIdentifier:nil items:nil header:nil footer:nil];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self isEqualToDataSourceContentSection:object];
    }
    
    return NO;
}

- (NSUInteger)hash {
    return 634209 ^ [self.identifier hash] ^ [self.items hash] ^ [self.header hash] ^ [self.footer hash];
}

@end
