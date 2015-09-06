#import "MUKTableViewController.h"
#import <KVOController/FBKVOController.h>
#import "MUKDataSourceContentPlaceholderView.h"

@interface MUKTableViewController ()
@property (nonatomic, weak) UIView *contentPlaceholderView;
@property (nonatomic) UITableViewCellSeparatorStyle separatorStyleBeforeContentPlaceholderView;
@property (nonatomic, getter=isObservingDataSourceContent) BOOL observingDataSourceContent;
@end

@implementation MUKTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.isObservingDataSourceContent) {
        [self observeDataSourceContent];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.isObservingDataSourceContent) {
        [self unobserveDataSourceContent];
    }
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

#pragma mark - Accessors

- (void)setDataSource:(MUKDataSource *)dataSource {
    if (dataSource != _dataSource) {
        _dataSource = dataSource;
        
        [dataSource registerReusableViewsForTableView:self.tableView];
        self.tableView.dataSource = dataSource;
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

+ (NSString *__nonnull)dataSourceContentKeyPath {
    return [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(dataSource)), NSStringFromSelector(@selector(content))];
}

- (void)observeDataSourceContent {
    [self.KVOControllerNonRetaining observe:self keyPath:[[self class] dataSourceContentKeyPath] options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(MUKTableViewController *observer, MUKTableViewController *object, NSDictionary *change)
    {
        if ([observer.dataSource.content isKindOfClass:[MUKDataSourceContentPlaceholder class]])
        {
            [observer didSetContentPlaceholder:(MUKDataSourceContentPlaceholder *)observer.dataSource.content];
        }
        else {
            [observer didSetContentPlaceholder:nil];
        }
    }];
    
    self.observingDataSourceContent = YES;
}

- (void)unobserveDataSourceContent {
    [self.KVOControllerNonRetaining unobserve:self keyPath:[[self class] dataSourceContentKeyPath]];
    self.observingDataSourceContent = NO;
}

- (void)didSetContentPlaceholder:(MUKDataSourceContentPlaceholder * __nullable)placeholder
{
    if (placeholder) {
        // Insert placeholder view
        UIView *const contentPlaceholderView = [self viewForContentPlaceholder:placeholder];
        
        BOOL needsAnimation;
        if (self.contentPlaceholderView) {
            // A placeholder view is already displayed
            [self.contentPlaceholderView removeFromSuperview];
            needsAnimation = NO;
        }
        else {
            // No placeholder view displayed
            self.separatorStyleBeforeContentPlaceholderView = self.tableView.separatorStyle;
            needsAnimation = YES;
        }
        
        contentPlaceholderView.alpha = needsAnimation ? 0.0f : 1.0f;
        contentPlaceholderView.backgroundColor = [UIColor clearColor];
        contentPlaceholderView.frame = self.tableView.bounds;
        
        [self.tableView addSubview:contentPlaceholderView];
        self.contentPlaceholderView = contentPlaceholderView;
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if (needsAnimation) {
            [UIView animateWithDuration:0.25 animations:^{
                contentPlaceholderView.alpha = 1.0f;
            }];
        }
    }
    else if (self.contentPlaceholderView) {
        // Remove placeholder view
        UIView *const contentPlaceholderView = self.contentPlaceholderView;
        UITableViewCellSeparatorStyle const separatorStyleBeforeContentPlaceholderView = self.separatorStyleBeforeContentPlaceholderView;
        
        [UIView animateWithDuration:0.25 animations:^{
            contentPlaceholderView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [contentPlaceholderView removeFromSuperview];
            self.tableView.separatorStyle = separatorStyleBeforeContentPlaceholderView;
        }];
    }
}

@end
