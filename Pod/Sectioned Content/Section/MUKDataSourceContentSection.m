#import "MUKDataSourceContentSection.h"

@implementation MUKDataSourceContentSection
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

- (BOOL)isEqualToDataSourceContentSection:(MUKDataSourceContentSection *)section
{
    BOOL const sameIdentifier = (!self.identifier && !section.identifier) || [self.identifier isEqual:section.identifier];
    BOOL const sameItems = (!self.items && !section.items) || [self.items isEqualToArray:section.items];
    
    return sameIdentifier && sameItems;
}

- (instancetype)sectionByReplacingItemsWithItems:(NSArray *)newItems {
    return [[[self class] alloc] initWithIdentifier:self.identifier items:newItems];
}

- (instancetype)sectionByRemovingItemAtIndex:(NSUInteger)idx {
    if (idx >= self.items.count) {
        return self;
    }
    
    NSMutableArray *const items = [self.items mutableCopy];
    [items removeObjectAtIndex:idx];
    
    return [self sectionByReplacingItemsWithItems:items];
}

- (instancetype)sectionByInsertingItem:(id)item atIndex:(NSUInteger)idx {
    if (!item || idx > self.items.count) {
        return self;
    }
    
    NSMutableArray *const items = [self.items mutableCopy];
    [items insertObject:item atIndex:idx];
    
    return [self sectionByReplacingItemsWithItems:items];
}

- (instancetype)sectionByReplacingItemAtIndex:(NSUInteger)idx withItem:(id<MUKDataSourceIdentifiable>)newItem
{
    if (!newItem || idx >= self.items.count) {
        return self;
    }
    
    NSMutableArray *const items = [self.items mutableCopy];
    [items replaceObjectAtIndex:idx withObject:newItem];
    
    return [self sectionByReplacingItemsWithItems:items];
}

#pragma mark - Overrides

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
    return 634209 ^ [self.identifier hash] ^ [self.items hash];
}

@end
