#import "MUKCollectionViewController.h"
#import <KVOController/FBKVOController.h>
#import "MUKDataSourceContentPlaceholderView.h"

@interface MUKCollectionViewController ()
@property (nonatomic, weak) UIView *contentPlaceholderView;
@end

@implementation MUKCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Keep collection view data source bound with self.dataSource from now on
    NSString *const dataSourceKeyPath = NSStringFromSelector(@selector(dataSource));
    [self.KVOController observe:self keyPath:dataSourceKeyPath options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(MUKCollectionViewController *observer, MUKCollectionViewController *object, NSDictionary *change)
     {
         [observer.dataSource registerReusableViewsForCollectionView:observer.collectionView];
         observer.collectionView.dataSource = observer.dataSource;
     }];
    
    // Observe placeholder
    NSString *const contentKeyPath = [dataSourceKeyPath stringByAppendingFormat:@".%@", NSStringFromSelector(@selector(content))];
    [self.KVOController observe:self keyPath:contentKeyPath options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(MUKCollectionViewController *observer, MUKCollectionViewController *object, NSDictionary *change)
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
        [self.collectionView bringSubviewToFront:self.contentPlaceholderView];
        
        if (!self.collectionView.isTracking && !self.collectionView.isDragging && !self.collectionView.isDecelerating)
        {
            self.contentPlaceholderView.frame = self.collectionView.bounds;
        }
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
        
        contentPlaceholderView.alpha = 0.0f;
        contentPlaceholderView.backgroundColor = [UIColor clearColor];
        contentPlaceholderView.frame = self.collectionView.bounds;
        
        [self.collectionView addSubview:contentPlaceholderView];
        self.contentPlaceholderView = contentPlaceholderView;
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            contentPlaceholderView.alpha = 1.0f;
        }];
    }
    else if (self.contentPlaceholderView) {
        // Remove placeholder view
        UIView *const contentPlaceholderView = self.contentPlaceholderView;
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            contentPlaceholderView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [contentPlaceholderView removeFromSuperview];
        }];
    }
}

@end
