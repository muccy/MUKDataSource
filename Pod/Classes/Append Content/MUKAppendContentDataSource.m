#import "MUKAppendContentDataSource.h"
#import "MUKDataSource+TableView.h"

static NSString *const kItemAppendingContent = @"MUKAppendContentDataSourceItemAppendingContent";
static NSString *const kItemCouldAppendContent = @"MUKAppendContentDataSourceItemCouldAppendContent";

@implementation MUKAppendContentDataSource
@dynamic isShowingAppendingContent, isShowingCouldAppendContent;

#pragma mark - Overrides

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    [super configureCell:cell forRowAtIndexPath:tableIndexPath inTableView:tableView];
    
    if (self.isShowingCouldAppendContent) {
        [self configureCouldAppendContentTableViewCell:cell];
    }
    else if (self.isShowingAppendingContent) {
        [self configureAppendingContentTableViewCell:cell];
    }
}

#pragma mark - Methods

- (BOOL)isShowingCouldAppendContent {
    return [self.items containsObject:kItemCouldAppendContent];
}

- (BOOL)isShowingAppendingContent {
    return [self.items containsObject:kItemAppendingContent];
}

- (BOOL)showAppendingContentIfNeededWithContentLoading:(MUKDataSourceContentLoading *)contentLoading animated:(BOOL)animated
{
    if ([contentLoading.dataSource.loadingState isEqualToString:MUKDataSourceContentLoadStateAppending])
    {
        [self setItems:@[kItemAppendingContent] animated:animated];
        return YES;
    }
    
    return NO;
}

- (BOOL)showCouldAppendContentIfNeededWithContentLoading:(MUKDataSourceContentLoading *)contentLoading resultType:(MUKDataSourceContentLoadingResultType)resultType animated:(BOOL)animated
{
    BOOL willShow;
    
    switch (resultType) {
        case MUKDataSourceContentLoadingResultTypeComplete:
            [self setItems:@[kItemCouldAppendContent] animated:animated];
            willShow = YES;
            break;
            
        case MUKDataSourceContentLoadingResultTypePartial:
        case MUKDataSourceContentLoadingResultTypeEmpty:
            [self setItems:@[] animated:animated];
            willShow = NO;
            break;
            
        case MUKDataSourceContentLoadingResultTypeError: {
            if ([contentLoading.sourceState isEqualToString:MUKDataSourceContentLoadStateAppending])
            {
                [self setItems:@[kItemCouldAppendContent] animated:animated];
                willShow = YES;
            }
            else {
               [self setItems:@[] animated:animated];
                willShow = NO;
            }
            
            break;
        }
            
        default:
            willShow = NO;
            break;
    }
    
    return willShow;
}

#pragma mark - Table View

- (void)configureAppendingContentTableViewCell:(UITableViewCell *)cell {
    //
}

- (void)configureCouldAppendContentTableViewCell:(UITableViewCell *)cell {
    //
}

@end
