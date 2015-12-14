#import "MUKCollectionViewController.h"
#import <KVOController/FBKVOController.h>
#import "MUKDataSourceContentPlaceholderView.h"

@interface MUKCollectionViewController ()
@property (nonatomic, weak) UIView *contentPlaceholderView;
@property (nonatomic, copy, nullable) dispatch_block_t postponedPlaceholderViewManipulation;
@end

@implementation MUKCollectionViewController

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
        [self.collectionView bringSubviewToFront:self.contentPlaceholderView];
        
        if (!self.collectionView.isTracking && !self.collectionView.isDragging && !self.collectionView.isDecelerating)
        {
            self.contentPlaceholderView.frame = self.collectionView.bounds;
        }
    }
}

#pragma mark - Accessors

- (void)setDataSource:(MUKDataSource *)newDataSource {
    if (newDataSource != _dataSource) {
        MUKDataSource *const oldDataSource = _dataSource;
        _dataSource = newDataSource;
        
        [newDataSource registerReusableViewsForCollectionView:self.collectionView];
        self.collectionView.dataSource = newDataSource;
        
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
    MUKDataSourceContentPlaceholderView *const view = [[MUKDataSourceContentPlaceholderView alloc] initWithFrame:self.collectionView.bounds];
    view.titleLabel.text = placeholder.title;
    view.textLabel.text = placeholder.subtitle;
    view.imageView.image = placeholder.image;
    
    return view;
}

#pragma mark - Private

- (void)observeContentOfDataSource:(nonnull MUKDataSource *)dataSource {
    [self.KVOController observe:dataSource keyPath:NSStringFromSelector(@selector(content)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(MUKCollectionViewController *observer, MUKDataSource *object, NSDictionary *change)
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

- (void)didSetContentPlaceholder:(MUKDataSourceContentPlaceholder * __nullable)placeholder
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
                needsAnimation = isOnscreen;
            }
            
            contentPlaceholderView.alpha = needsAnimation ? 0.0f : 1.0f;
            contentPlaceholderView.backgroundColor = [UIColor clearColor];
            contentPlaceholderView.frame = strongSelf.collectionView.bounds;
            
            [strongSelf.collectionView addSubview:contentPlaceholderView];
            strongSelf.contentPlaceholderView = contentPlaceholderView;
            
            if (needsAnimation) {
                [UIView animateWithDuration:0.25 animations:^{
                    contentPlaceholderView.alpha = 1.0f;
                }];
            }
        }
        else if (strongSelf.contentPlaceholderView) {
            // Remove placeholder view
            UIView *const contentPlaceholderView = strongSelf.contentPlaceholderView;
            
            [UIView animateWithDuration:0.25 animations:^{
                contentPlaceholderView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [contentPlaceholderView removeFromSuperview];
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
