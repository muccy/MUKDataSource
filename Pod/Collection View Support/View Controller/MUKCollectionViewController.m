#import "MUKCollectionViewController.h"
#import <MUKSignal/MUKSignal.h>
#import "MUKDataSourceContentPlaceholderView.h"

@interface MUKCollectionViewControllerReserved : NSObject
@property (nonatomic, weak, readonly) MUKCollectionViewController *owner;
@property (nonatomic, weak) UIView *contentPlaceholderView;
@property (nonatomic, nonnull, readonly) MUKSignalObservation<MUKSignal<MUKDataSourceContentChange *> *> *contentObservation;
@end

@implementation MUKCollectionViewControllerReserved

- (instancetype)initWithOwner:(MUKCollectionViewController *)owner {
    self = [super init];
    if (self) {
        _owner = owner;
    }
    
    return self;
}

- (void)setupContentObservation {
    MUKDataSource *const dataSource = self.owner.dataSource;
    
    if (dataSource) {
        BOOL const observationWasRunning = self.contentObservation && ![self.contentObservation.signal isSuspended:self.contentObservation.token];

        __weak __typeof__(self) weakSelf = self;
        _contentObservation = [MUKSignalObservation observationWithSignal:dataSource.contentChangedSignal token:[dataSource.contentChangedSignal subscribe:^(MUKDataSourceContentChange * _Nonnull change)
        {
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            
            if ([change.content isKindOfClass:[MUKDataSourceContentPlaceholder class]])
            {
                [strongSelf didSetContentPlaceholder:change.content];
            }
            else {
                [strongSelf didSetContentPlaceholder:nil];
            }
        }]];
        
        if (!observationWasRunning) {
            [self.contentObservation suspend];
        }
    }
    else {
        _contentObservation = nil;
    }
}

/*
 This method is always called when view is onscreen because observation is
 suspended in -viewDidDisappear:
 */
- (void)didSetContentPlaceholder:(nullable MUKDataSourceContentPlaceholder *)placeholder
{
    // Ensure a strong reference to owning view controller
    if (!self.owner) {
        return;
    }
    
    MUKCollectionViewController *const viewController = self.owner;
    
    if (placeholder) {
        // Insert placeholder view
        UIView *const contentPlaceholderView = [viewController viewForContentPlaceholder:placeholder];
        
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
        contentPlaceholderView.frame = viewController.collectionView.bounds;
        
        [viewController.collectionView addSubview:contentPlaceholderView];
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

@interface MUKCollectionViewController ()
@property (nonatomic, readonly, nonnull) MUKCollectionViewControllerReserved *reserved;
@end

@implementation MUKCollectionViewController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.dataSource) {
        [self.dataSource registerReusableViewsForCollectionView:self.collectionView];
        self.collectionView.dataSource = self.dataSource;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.reserved.contentObservation resume];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.reserved.contentObservation suspend];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.reserved.contentPlaceholderView) {
        [self.collectionView bringSubviewToFront:self.reserved.contentPlaceholderView];
        
        if (!self.collectionView.isTracking && !self.collectionView.isDragging && !self.collectionView.isDecelerating)
        {
            self.reserved.contentPlaceholderView.frame = self.collectionView.bounds;
        }
    }
}

#pragma mark - Accessors

- (void)setDataSource:(MUKDataSource *)newDataSource {
    if (newDataSource != _dataSource) {
        _dataSource = newDataSource;
        [self.reserved setupContentObservation];
        
        if ([self isViewLoaded]) {
            [newDataSource registerReusableViewsForCollectionView:self.collectionView];
            self.collectionView.dataSource = newDataSource;
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

static void CommonInit(MUKCollectionViewController * _Nonnull me) {
    me->_reserved = [[MUKCollectionViewControllerReserved alloc] initWithOwner:me];
}

@end
