#import "MUKAppendContentDataSource.h"
#import "MUKDataSource+TableView.h"

static NSString *const kAppendContentItem = @"MUKAppendContentDataSourceItem";

@implementation MUKAppendContentDataSource
@dynamic hidden;

- (id)init {
    self = [super init];
    if (self) {
        _appendContentView = [[MUKDataSourceAppendContentView alloc] initWithFrame:CGRectZero];
    }
    
    return self;
}

#pragma mark - Overrides

- (UITableViewCell *)dequeueOrCreateCellForRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    static NSString *const kCellIdentifier = @"MUKAppendContentDataSourceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    [super configureCell:cell forRowAtIndexPath:tableIndexPath inTableView:tableView];
    
    // Make sure cell contains current view
    if (![self.appendContentView.superview isEqual:cell.contentView]) {
        // Clean
        for (UIView *subview in cell.contentView.subviews) {
            [subview removeFromSuperview];
        }
        
        // Insert
        self.appendContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.appendContentView.frame = cell.contentView.bounds;
        [cell.contentView addSubview:self.appendContentView];
    }
}

#pragma mark - Accessors

- (BOOL)isHidden {
    return ![self.items containsObject:kAppendContentItem];
}

- (void)setHidden:(BOOL)hidden {
    [self setHidden:hidden animated:NO];
}

- (void)setAppendContentView:(UIView *)appendContentView {
    if (![_appendContentView isEqual:appendContentView]) {
        _appendContentView = appendContentView;
        
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
        [self.appendContentView setNeedsLayout];
        [self setItems:@[kAppendContentItem] animated:animated];
    }
}

#pragma mark - Utils

+ (BOOL)shouldTypicallyHideWhenWillLoadContent:(MUKDataSourceContentLoading *)contentLoading
{
    return ![contentLoading.dataSource.loadingState isEqualToString:MUKDataSourceContentLoadStateAppending];
}

+ (BOOL)shouldTypicallyHideWhenDidLoadContent:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType
{
    BOOL shouldHide;
    
    switch (resultType) {
        case MUKDataSourceContentLoadingResultTypeComplete:
            shouldHide = NO;
            break;
            
        case MUKDataSourceContentLoadingResultTypePartial:
        case MUKDataSourceContentLoadingResultTypeEmpty:
            shouldHide = YES;
            break;
            
        case MUKDataSourceContentLoadingResultTypeError: {
            if ([contentLoading.sourceState isEqualToString:MUKDataSourceContentLoadStateAppending])
            {
                shouldHide = NO;
            }
            else {
                shouldHide = YES;
            }
            
            break;
        }
            
        default:
            shouldHide = YES;
            break;
    }
    
    return shouldHide;
}

@end
