#import "MUKTableViewController.h"
#import <KVOController/FBKVOController.h>
#import "MUKDataSourceContentPlaceholderView.h"

@interface MUKTableViewController ()
@property (nonatomic, weak) UIView *contentPlaceholderView;
@property (nonatomic) UITableViewCellSeparatorStyle separatorStyleBeforeContentPlaceholderView;
@property (nonatomic) BOOL suppressesSeparators;

@property (nonatomic, copy, nullable) dispatch_block_t postponedPlaceholderViewManipulation;
@end

@implementation MUKTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.dataSource) {
        [self.dataSource registerReusableViewsForTableView:self.tableView];
        self.tableView.dataSource = self.dataSource;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.postponedPlaceholderViewManipulation) {
        self.postponedPlaceholderViewManipulation();
        self.postponedPlaceholderViewManipulation = nil;
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

- (void)setDataSource:(MUKDataSource *)newDataSource {
    if (newDataSource != _dataSource) {
        MUKDataSource *const oldDataSource = _dataSource;
        _dataSource = newDataSource;
        
        if ([self isViewLoaded]) {
            [newDataSource registerReusableViewsForTableView:self.tableView];
            self.tableView.dataSource = newDataSource;
        }
        
        // Observe content
        if (oldDataSource) {
            [self unobserveContentOfDataSource:oldDataSource];
        }
        
        if (newDataSource) {
            [self observeContentOfDataSource:newDataSource];
        }
    }
}

#pragma mark - Content Placeholder

- (UIView *)viewForContentPlaceholder:(MUKDataSourceContentPlaceholder *)placeholder
{
    MUKDataSourceContentPlaceholderView *const view = [[MUKDataSourceContentPlaceholderView alloc] initWithFrame:self.tableView.bounds];
    view.titleLabel.text = placeholder.title;
    view.textLabel.text = placeholder.subtitle;
    view.imageView.image = placeholder.image;
    
    return view;
}

#pragma mark - Private

- (void)observeContentOfDataSource:(nonnull MUKDataSource *)dataSource {
    [self.KVOController observe:dataSource keyPath:NSStringFromSelector(@selector(content)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(MUKTableViewController *observer, MUKDataSource *object, NSDictionary *change)
    {
        if ([object.content isKindOfClass:[MUKDataSourceContentPlaceholder class]])
        {
            [observer didSetContentPlaceholder:(MUKDataSourceContentPlaceholder *)object.content];
        }
        else {
            [observer didSetContentPlaceholder:nil];
        }
    }];
}

- (void)unobserveContentOfDataSource:(nonnull MUKDataSource *)dataSource {
    [self.KVOController unobserve:dataSource keyPath:NSStringFromSelector(@selector(content))];
}

- (void)didSetContentPlaceholder:(nullable MUKDataSourceContentPlaceholder *)placeholder
{
    BOOL const isOnscreen = [self isViewLoaded] && self.view.window;
    
    __weak typeof(self) weakSelf = self;
    dispatch_block_t const job = ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        
        if (placeholder) {
            // Insert placeholder view
            UIView *const contentPlaceholderView = [strongSelf viewForContentPlaceholder:placeholder];
            
            BOOL needsAnimation;
            if (strongSelf.contentPlaceholderView) {
                // A placeholder view is already displayed
                [strongSelf.contentPlaceholderView removeFromSuperview];
                needsAnimation = NO;
            }
            else {
                // No placeholder view displayed
                
                // Catch separator style before to suppress them
                if (!strongSelf.suppressesSeparators) {
                    strongSelf.separatorStyleBeforeContentPlaceholderView = strongSelf.tableView.separatorStyle;
                }
                
                needsAnimation = isOnscreen;
            }
            
            contentPlaceholderView.alpha = needsAnimation ? 0.0f : 1.0f;
            contentPlaceholderView.backgroundColor = [UIColor clearColor];
            contentPlaceholderView.frame = strongSelf.tableView.bounds;
            
            [strongSelf.tableView addSubview:contentPlaceholderView];
            strongSelf.contentPlaceholderView = contentPlaceholderView;
            
            strongSelf.suppressesSeparators = YES;
            strongSelf.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            if (needsAnimation) {
                [UIView animateWithDuration:0.25 animations:^{
                    contentPlaceholderView.alpha = 1.0f;
                }];
            }
        }
        else if (strongSelf.contentPlaceholderView) {
            // Remove placeholder view
            UIView *const contentPlaceholderView = strongSelf.contentPlaceholderView;
            
            // Re-enable separators
            UITableViewCellSeparatorStyle const separatorStyleBeforeContentPlaceholderView = strongSelf.separatorStyleBeforeContentPlaceholderView;
            strongSelf.suppressesSeparators = NO;
            
            __weak typeof(strongSelf) weakSelf = strongSelf;
            [UIView animateWithDuration:0.25 animations:^{
                contentPlaceholderView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                __strong __typeof(weakSelf) strongSelf = weakSelf;
                [contentPlaceholderView removeFromSuperview];
                
                // Doublecheck separators could be enabled
                if (!strongSelf.suppressesSeparators) {
                    strongSelf.tableView.separatorStyle = separatorStyleBeforeContentPlaceholderView;
                }
            }];
        }
    }; // job
    
    if (isOnscreen) {
        self.postponedPlaceholderViewManipulation = nil; // Cancel previous
        job();
    }
    else {
        self.postponedPlaceholderViewManipulation = job; // Postpone
    }
}

@end
