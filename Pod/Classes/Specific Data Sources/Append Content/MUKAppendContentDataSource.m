#import "MUKAppendContentDataSource.h"
#import "MUKDataSource+TableView.h"
#import "MUKDataSourceAppendContentView.h"

@implementation MUKAppendContentDataSource

#pragma mark - Overrides

- (UITableViewCell *)dequeueOrCreateCellForRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    UITableViewCell *cell = [super dequeueOrCreateCellForRowAtIndexPath:tableIndexPath inTableView:tableView];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section tableView:(UITableView *)tableView
{
    return nil;
}

- (Class)viewClass {
    return [MUKDataSourceAppendContentView class];
}

- (void)configureView:(UIView *)view {
    [super configureView:view];
    
    if ([view isKindOfClass:[MUKDataSourceAppendContentView class]]) {
        MUKDataSourceAppendContentView *appendContentView = (MUKDataSourceAppendContentView *)view;
        appendContentView.textLabel.text = self.title;
        
        if (self.showsActivityIndicator && appendContentView.activityIndicatorView.isHidden)
        {
            [appendContentView.activityIndicatorView startAnimating];
        }
        else if (!self.showsActivityIndicator && !appendContentView.activityIndicatorView.isHidden)
        {
            [appendContentView.activityIndicatorView stopAnimating];
        }

        [appendContentView setNeedsLayout];
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

- (void)setShowsActivityIndicator:(BOOL)showsActivityIndicator {
    if (showsActivityIndicator != _showsActivityIndicator) {
        _showsActivityIndicator = showsActivityIndicator;
        [self setNeedsUpdateView];
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

#pragma mark - <NSSecureCoding>

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _showsActivityIndicator = [aDecoder decodeBoolForKey:@"showsActivityIndicator"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:_showsActivityIndicator forKey:@"showsActivityIndicator"];
}

@end
