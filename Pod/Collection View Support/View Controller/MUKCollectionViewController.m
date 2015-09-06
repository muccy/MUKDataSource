#import "MUKCollectionViewController.h"
#import <KVOController/FBKVOController.h>
#import "MUKDataSourceContentPlaceholderView.h"

@interface MUKCollectionViewController ()
@property (nonatomic, weak) UIView *contentPlaceholderView;
@property (nonatomic, getter=isObservingDataSourceContent) BOOL observingDataSourceContent;
@end

@implementation MUKCollectionViewController

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
        [self.collectionView bringSubviewToFront:self.contentPlaceholderView];
        
        if (!self.collectionView.isTracking && !self.collectionView.isDragging && !self.collectionView.isDecelerating)
        {
            self.contentPlaceholderView.frame = self.collectionView.bounds;
        }
    }
}

#pragma mark - Accessors

- (void)setDataSource:(MUKDataSource *)dataSource {
    if (dataSource != _dataSource) {
        _dataSource = dataSource;
        
        [dataSource registerReusableViewsForCollectionView:self.collectionView];
        self.collectionView.dataSource = dataSource;
    }
}

#pragma mark - Content Placeholder

- (UIView * __nullable)viewForContentPlaceholder:(MUKDataSourceContentPlaceholder * __nonnull)placeholder
{
    MUKDataSourceContentPlaceholderView *const view = [[MUKDataSourceContentPlaceholderView alloc] initWithFrame:self.collectionView.bounds];
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
    [self.KVOControllerNonRetaining observe:self keyPath:[[self class] dataSourceContentKeyPath] options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(MUKCollectionViewController *observer, MUKCollectionViewController *object, NSDictionary *change)
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
            needsAnimation = YES;
        }
        
        contentPlaceholderView.alpha = needsAnimation ? 0.0f : 1.0f;
        contentPlaceholderView.backgroundColor = [UIColor clearColor];
        contentPlaceholderView.frame = self.collectionView.bounds;
        
        [self.collectionView addSubview:contentPlaceholderView];
        self.contentPlaceholderView = contentPlaceholderView;
        
        if (needsAnimation) {
            [UIView animateWithDuration:0.25 animations:^{
                contentPlaceholderView.alpha = 1.0f;
            }];
        }
    }
    else if (self.contentPlaceholderView) {
        // Remove placeholder view
        UIView *const contentPlaceholderView = self.contentPlaceholderView;
        
        [UIView animateWithDuration:0.25 animations:^{
            contentPlaceholderView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [contentPlaceholderView removeFromSuperview];
        }];
    }
}

@end
