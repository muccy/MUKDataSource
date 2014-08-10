#import "MUKPlaceholderDataSource.h"
#import "MUKDataSource+TableView.h"

static NSString *const kPlaceholderItem = @"MUKPlaceholderDataSourceItem";

@implementation MUKPlaceholderDataSource
@dynamic hidden;

- (id)init {
    self = [super init];
    if (self) {
        _placeholderView = [[MUKDataSourcePlaceholderView alloc] initWithFrame:CGRectZero];
        self.items = @[kPlaceholderItem];
    }
    
    return self;
}

#pragma mark - Accessors

- (BOOL)isHidden {
    return ![self.items containsObject:kPlaceholderItem];
}

- (void)setHidden:(BOOL)hidden {
    [self setHidden:hidden animated:NO];
}

- (void)setPlaceholderView:(UIView *)placeholderView {
    if (![_placeholderView isEqual:placeholderView]) {
        _placeholderView = placeholderView;

        // Notify data source refreshed
        NSInteger const idx = [self.parentDataSource.childDataSources indexOfObject:self];
        if (idx != NSNotFound) {
            [self didRefreshChildDataSourcesAtIndexes:[NSIndexSet indexSetWithIndex:idx] inDataSource:self.parentDataSource];
        }
    }
}

#pragma mark - Methods

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated {
    if (hidden) {
        [self setItems:@[] animated:animated];
    }
    else {
        [self.placeholderView setNeedsLayout];
        [self setItems:@[kPlaceholderItem] animated:animated];
    }
}

#pragma mark - Overrides

- (UITableViewCell *)dequeueOrCreateCellForRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    static NSString *const kCellIdentifier = @"MUKPlaceholderDataSourceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    [super configureCell:cell forRowAtIndexPath:tableIndexPath inTableView:tableView];
    
    // Make sure cell contains current view
    if (![self.placeholderView.superview isEqual:cell.contentView]) {
        // Clean
        for (UIView *subview in cell.contentView.subviews) {
            [subview removeFromSuperview];
        }
        
        // Insert
        self.placeholderView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.placeholderView.frame = cell.contentView.bounds;
        [cell.contentView addSubview:self.placeholderView];
    }
}

@end
