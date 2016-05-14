#import "MUKPageViewController.h"
#import <MUKSignal/MUKSignal.h>
#import "MUKDataSourceContentPlaceholderView.h"

@interface MUKPageViewControllerReserved : NSObject
@property (nonatomic, weak, readonly) MUKPageViewController *owner;
@property (nonatomic, nonnull, readonly) MUKSignalObservation<MUKKVOSignal *> *contentObservation;
@end

@implementation MUKPageViewControllerReserved

- (instancetype)initWithOwner:(MUKPageViewController *)owner {
    self = [super init];
    if (self) {
        _owner = owner;
        
        MUKKVOSignal *const signal = [[MUKKVOSignal alloc] initWithObject:owner keyPath:@"pageDataSource.content"];
        
        __weak __typeof__(self) weakSelf = self;
        _contentObservation = [MUKSignalObservation observationWithSignal:signal token:[signal subscribe:^(MUKKVOSignalChange * _Nonnull change)
        {
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            
            if ([change.value isKindOfClass:[MUKDataSourceContentPlaceholder class]])
            {
                [strongSelf didSetContentPlaceholder:change.value];
            }
            else {
                [strongSelf didSetContentPlaceholder:nil];
            }
        }]];
        
        // Wait for first -viewWillAppear:
        [_contentObservation suspend];
    }
    
    return self;
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
    
    MUKPageViewController *const viewController = self.owner;
    
    if (placeholder) {
        // Insert placeholder view
        UIView *const contentPlaceholderView = [viewController viewForContentPlaceholder:placeholder];
        
        // Create wrapper view controller
        UIViewController *const wrapperViewController = [[UIViewController alloc] init];
        contentPlaceholderView.frame = wrapperViewController.view.bounds;
        contentPlaceholderView.translatesAutoresizingMaskIntoConstraints = NO;
        [wrapperViewController.view addSubview:contentPlaceholderView];
        
        [contentPlaceholderView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[contentPlaceholderView]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentPlaceholderView)]];
        
        id const topGuide = wrapperViewController.topLayoutGuide;
        id const bottomGuide = wrapperViewController.bottomLayoutGuide;
        [contentPlaceholderView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-(0)-[contentPlaceholderView]-(0)-[bottomGuide]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentPlaceholderView, topGuide, bottomGuide)]];
        
        // Set view controllers
        [viewController willChangeCurrentPages];
        [viewController setViewControllers:@[ wrapperViewController ] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        [viewController didChangeCurrentPages];
    }
    
    // Nothing to do in "else" case because view controllers are overwritten
}

@end

#pragma mark -

@interface MUKPageViewController ()
@property (nonatomic, readwrite, getter=isPageViewControllerTransitionInProgress) BOOL pageViewControllerTransitionInProgress;
@property (nonatomic, readonly, nonnull) MUKPageViewControllerReserved *reserved;
@end

@implementation MUKPageViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)options
{
    self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.reserved.contentObservation resume];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.reserved.contentObservation suspend];
}

#pragma mark - Accessors

- (void)setPageDataSource:(MUKDataSource *)newPageDataSource {
    if (newPageDataSource != _pageDataSource) {
        _pageDataSource = newPageDataSource;
        self.dataSource = newPageDataSource;
    }
}

#pragma mark - Content Placeholder

- (UIView *)viewForContentPlaceholder:(MUKDataSourceContentPlaceholder *)placeholder
{
    MUKDataSourceContentPlaceholderView *const view = [[MUKDataSourceContentPlaceholderView alloc] initWithFrame:self.view.bounds];
    view.titleLabel.text = placeholder.title;
    view.textLabel.text = placeholder.subtitle;
    view.imageView.image = placeholder.image;
    
    return view;
}

#pragma mark - Overrides

// http://stackoverflow.com/a/25549277
- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL))completionHandler
{
    if (!animated) {
        [super setViewControllers:viewControllers direction:direction animated:NO completion:completionHandler];
        return;
    }
    
    [super setViewControllers:viewControllers direction:direction animated:YES completion:^(BOOL finished)
    {
        if (finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [super setViewControllers:viewControllers direction:direction animated:NO completion:completionHandler];
            });
        }
        else {
            if (completionHandler) {
                completionHandler(finished);
            }
        }
    }];
}

#pragma mark - Accessors

- (NSArray *)currentPages {
    NSMutableArray *const pages = [NSMutableArray arrayWithCapacity:1];
    
    for (UIViewController *viewController in self.viewControllers) {
        id const page = [self.pageDataSource pageForViewController:viewController];
        
        if (page) {
            [pages addObject:page];
        }
    } // for
    
    return pages.count > 0 ? [pages copy] : nil;
}

#pragma mark - Methods

- (void)setCurrentPages:(NSArray *)pages animated:(BOOL)animated completion:(void (^)(BOOL))completionHandler
{
    if (pages.count < 1) {
        if (completionHandler) {
            completionHandler(NO);
        }
        
        return;
    }
    
    // Create matching view controllers
    NSMutableArray<UIViewController *> *const viewControllers = [NSMutableArray arrayWithCapacity:pages.count];
    for (id page in pages) {
        UIViewController *const viewController = [self.pageDataSource newViewControllerForPage:page];
        
        if (viewController) {
            [viewControllers addObject:viewController];
        }
    } // for
    
    if (viewControllers.count < 1) {
        if (completionHandler) {
            completionHandler(NO);
        }
        
        return;
    }
    
    // Choose direction
    UIPageViewControllerNavigationDirection direction;
    NSArray *const currentPages = self.currentPages;
    if (currentPages.count == 0) {
        direction = UIPageViewControllerNavigationDirectionForward;
    }
    else {
        direction = [self.pageDataSource page:pages.lastObject precedesPage:currentPages.firstObject] ? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward;
    }
    
    // Make transition
    [self willChangeCurrentPages];
    
    __weak typeof(self) weakSelf = self;
    [self setViewControllers:[viewControllers copy] direction:direction animated:animated completion:^(BOOL finished)
    {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf didChangeCurrentPages];
    }];
}

- (void)willChangeCurrentPages {
    [self willChangeValueForKey:NSStringFromSelector(@selector(currentPages))];
}

- (void)didChangeCurrentPages {
    [self didChangeValueForKey:NSStringFromSelector(@selector(currentPages))];
}

#pragma mark - Private

static void CommonInit(MUKPageViewController * _Nonnull me) {
    me->_reserved = [[MUKPageViewControllerReserved alloc] initWithOwner:me];
    me.delegate = me;
}

#pragma mark - <UIPageViewControllerDelegate>

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    self.pageViewControllerTransitionInProgress = YES;
    [self willChangeCurrentPages];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    [self didChangeCurrentPages];
    self.pageViewControllerTransitionInProgress = NO;
}

@end
