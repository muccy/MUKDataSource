#import "MUKPlaceholderDataSource.h"
#import "MUKDataSource+TableView.h"
#import "MUKDataSourcePlaceholderView.h"

@implementation MUKPlaceholderDataSource

#pragma mark - Overrides

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated {
    [self.parentDataSource willChangeValueForKey:@"displaysPlaceholderDataSource"];
    [super setHidden:hidden animated:animated];
    [self.parentDataSource didChangeValueForKey:@"displaysPlaceholderDataSource"];
}

- (UITableViewCell *)dequeueOrCreateCellForRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    UITableViewCell *cell = [super dequeueOrCreateCellForRowAtIndexPath:tableIndexPath inTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView
{
    return nil;
}

- (Class)viewClass {
    return [MUKDataSourcePlaceholderView class];
}

- (void)configureView:(UIView *)view {
    [super configureView:view];
    
    if ([view isKindOfClass:[MUKDataSourcePlaceholderView class]]) {
        MUKDataSourcePlaceholderView *placeholderView = (MUKDataSourcePlaceholderView *)view;
        placeholderView.titleLabel.text = self.title;
        placeholderView.textLabel.text = self.text;
        placeholderView.imageView.image = self.image;
        [placeholderView setNeedsLayout];
    }
}

#pragma mark - Accessors

- (void)setTitle:(NSString *)title {
    BOOL different = ![self.title isEqualToString:title];
    [super setTitle:title];
    
    if (different) {
        [self setNeedsUpdateView];
    }
}

- (void)setText:(NSString *)text {
    if (![text isEqualToString:_text]) {
        _text = [text copy];
        [self setNeedsUpdateView];
    }
}

- (void)setImage:(UIImage *)image {
    if (![image isEqual:_image]) {
        _image = image;
        [self setNeedsUpdateView];
    }
}

#pragma mark - <NSSecureCoding>

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _text = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"text"];
        _image = [aDecoder decodeObjectOfClass:[UIImage class] forKey:@"image"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_text forKey:@"text"];
    [aCoder encodeObject:_image forKey:@"image"];
}

@end
