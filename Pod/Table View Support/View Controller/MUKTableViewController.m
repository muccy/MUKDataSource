#import "MUKTableViewController.h"
#import <KVOController/FBKVOController.h>
#import "MUKDataSourceContentPlaceholderView.h"

@interface MUKTableViewController ()
@property (nonatomic, weak) UIView *contentPlaceholderView;
@property (nonatomic) UITableViewCellSeparatorStyle separatorStyleBeforeContentPlaceholderView;
@end

@implementation MUKTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Keep table view data source bound with self.dataSource from now on
    NSString *const dataSourceKeyPath = NSStringFromSelector(@selector(dataSource));
    [self.KVOController observe:self keyPath:dataSourceKeyPath options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(MUKTableViewController *observer, MUKTableViewController *object, NSDictionary *change)
    {
        [observer.dataSource registerReusableViewsForTableView:observer.tableView];
        observer.tableView.dataSource = observer.dataSource;
    }];
    
    // Observe placeholder
    NSString *const contentKeyPath = [dataSourceKeyPath stringByAppendingFormat:@".%@", NSStringFromSelector(@selector(content))];
    [self.KVOController observe:self keyPath:contentKeyPath options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(MUKTableViewController *observer, MUKTableViewController *object, NSDictionary *change)
    {
        if ([observer.dataSource.content isKindOfClass:[MUKDataSourceContentPlaceholder class]])
        {
            [observer didSetContentPlaceholder:(MUKDataSourceContentPlaceholder *)observer.dataSource.content];
        }
        else {
            [observer didSetContentPlaceholder:nil];
        }
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.contentPlaceholderView) {
        [self.tableView bringSubviewToFront:self.contentPlaceholderView];
        
        if (!self.tableView.isTracking && !self.tableView.isDragging && !self.tableView.isDecelerating)
        {
            self.contentPlaceholderView.frame = self.tableView.bounds;
        }
    }
}

#pragma mark - Content Placeholder

- (UIView * __nullable)viewForContentPlaceholder:(MUKDataSourceContentPlaceholder * __nonnull)placeholder
{
    MUKDataSourceContentPlaceholderView *const view = [[MUKDataSourceContentPlaceholderView alloc] initWithFrame:self.tableView.bounds];
    view.titleLabel.text = placeholder.title;
    view.textLabel.text = placeholder.subtitle;
    view.imageView.image = placeholder.image;
    
    return view;
}

#pragma mark - Private

- (void)didSetContentPlaceholder:(MUKDataSourceContentPlaceholder * __nullable)placeholder
{
    static NSTimeInterval const kAnimationDuration = 0.2;
    
    if (placeholder) {
        // Insert placeholder view
        UIView *const contentPlaceholderView = [self viewForContentPlaceholder:placeholder];
        
        if (self.contentPlaceholderView) {
            // A placeholder view is already displayed
            [self.contentPlaceholderView removeFromSuperview];
        }
        else {
            // No placeholder view displayed
            self.separatorStyleBeforeContentPlaceholderView = self.tableView.separatorStyle;
        }
        
        contentPlaceholderView.alpha = 0.0f;
        contentPlaceholderView.backgroundColor = [UIColor clearColor];
        contentPlaceholderView.frame = self.tableView.bounds;
        
        [self.tableView addSubview:contentPlaceholderView];
        self.contentPlaceholderView = contentPlaceholderView;
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            contentPlaceholderView.alpha = 1.0f;
        }];
    }
    else if (self.contentPlaceholderView) {
        // Remove placeholder view
        UIView *const contentPlaceholderView = self.contentPlaceholderView;
        UITableViewCellSeparatorStyle const separatorStyleBeforeContentPlaceholderView = self.separatorStyleBeforeContentPlaceholderView;
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            contentPlaceholderView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [contentPlaceholderView removeFromSuperview];
            self.tableView.separatorStyle = separatorStyleBeforeContentPlaceholderView;
        }];
    }
}

@end
