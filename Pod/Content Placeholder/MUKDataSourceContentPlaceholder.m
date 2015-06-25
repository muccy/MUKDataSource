#import "MUKDataSourceContentPlaceholder.h"

@implementation MUKDataSourceContentPlaceholder

- (instancetype)initWithTitle:(NSString * __nullable)title subtitle:(NSString * __nullable)subtitle image:(UIImage * __nullable)image
{
    self = [super init];
    if (self) {
        _title = [title copy];
        _subtitle = [subtitle copy];
        _image = image;
    }
    
    return self;
}

- (BOOL)isEqualToContentPlaceholder:(MUKDataSourceContentPlaceholder * __nonnull)placeholder
{
    BOOL const sameTitle = (!self.title && !placeholder.title) || [self.title isEqualToString:placeholder.title];
    BOOL const sameSubtitle = (!self.subtitle && !placeholder.subtitle) || [self.subtitle isEqualToString:placeholder.subtitle];
    BOOL sameImage = (!self.image && !placeholder.image) || [self.image isEqual:placeholder.image];
    return sameTitle && sameSubtitle && sameImage;
}

#pragma mark - Overrides

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self isEqualToContentPlaceholder:object];
    }
    
    return NO;
}

- (NSUInteger)hash {
    return 26394 ^ [self.title hash] ^ [self.subtitle hash] ^ [self.image hash];
}

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] allocWithZone:zone] initWithTitle:self.title subtitle:self.subtitle image:self.image];
}

@end
