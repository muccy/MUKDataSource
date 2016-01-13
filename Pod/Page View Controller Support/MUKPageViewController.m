#import "MUKPageViewController.h"
#import <KVOController/FBKVOController.h>
#import "MUKDataSourceContentPlaceholderView.h"

@interface MUKPageViewControllerReserved : NSObject
@property (nonatomic, copy, nullable) dispatch_block_t postponedPlaceholderViewManipulation;
@property (nonatomic) BOOL isInsideViewWillAppearSession;
@end

@implementation MUKPageViewControllerReserved
@end

@interface MUKPageViewController ()
@property (nonatomic, readwrite, getter=isPageViewControllerTransitionInProgress) BOOL pageViewControllerTransitionInProgress;
@property (nonatomic, readonly, nonnull) MUKPageViewControllerReserved *reserved;
@end

@implementation MUKPageViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.delegate = self;
    }
    
    return self;
}

- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation options:(NSDictionary *)options
{
    self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
    if (self) {
        self.delegate = self;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.reserved.isInsideViewWillAppearSession = YES;
    
    if (self.reserved.postponedPlaceholderViewManipulation) {
        self.reserved.postponedPlaceholderViewManipulation();
        self.reserved.postponedPlaceholderViewManipulation = nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.reserved.isInsideViewWillAppearSession = NO;
}

#pragma mark - Accessors

- (void)setPageDataSource:(MUKDataSource *)newPageDataSource {
    if (newPageDataSource != _pageDataSource) {
        MUKDataSource *const oldPageDataSource = _pageDataSource;

        _pageDataSource = newPageDataSource;
        self.dataSource = newPageDataSource;
        
        // Observe content
        if (oldPageDataSource) {
            [self unobserveContentOfDataSource:oldPageDataSource];
        }
        
        if (newPageDataSource) {
            [self observeContentOfDataSource:newPageDataSource];
        }
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

- (NSArray<MUKDataSourceContentPage> *)currentPages {
    NSMutableArray<MUKDataSourceContentPage> *const pages = [NSMutableArray arrayWithCapacity:1];
    
    for (UIViewController *viewController in self.viewControllers) {
        MUKDataSourceContentPage const page = [self.pageDataSource pageForViewController:viewController];
        
        if (page) {
            [pages addObject:page];
        }
    } // for
    
    return pages.count > 0 ? [pages copy] : nil;
}

#pragma mark - Methods

- (void)setCurrentPages:(NSArray<MUKDataSourceContentPage> *)pages animated:(BOOL)animated completion:(void (^)(BOOL))completionHandler
{
    if (pages.count < 1) {
        if (completionHandler) {
            completionHandler(NO);
        }
        
        return;
    }
    
    // Create matching view controllers
    NSMutableArray<UIViewController *> *const viewControllers = [NSMutableArray arrayWithCapacity:pages.count];
    for (MUKDataSourceContentPage page in pages) {
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
    NSArray<MUKDataSourceContentPage> *const currentPages = self.currentPages;
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

- (void)observeContentOfDataSource:(nonnull MUKDataSource *)dataSource {
    [self.KVOController observe:dataSource keyPath:NSStringFromSelector(@selector(content)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(MUKPageViewController *observer, MUKDataSource *object, NSDictionary *change)
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
    __weak typeof(self) weakSelf = self;
    dispatch_block_t const job = ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (placeholder) {
            // Insert placeholder view
            UIView *const contentPlaceholderView = [strongSelf viewForContentPlaceholder:placeholder];
            
            // Create wrapper view controller
            UIViewController *const viewController = [[UIViewController alloc] init];
            contentPlaceholderView.frame = viewController.view.bounds;
            contentPlaceholderView.translatesAutoresizingMaskIntoConstraints = NO;
            [viewController.view addSubview:contentPlaceholderView];
            
            [contentPlaceholderView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[contentPlaceholderView]-(0)-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentPlaceholderView)]];
            
            id const topGuide = viewController.topLayoutGuide;
            id const bottomGuide = viewController.bottomLayoutGuide;
            [contentPlaceholderView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-(0)-[contentPlaceholderView]-(0)-[bottomGuide]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentPlaceholderView, topGuide, bottomGuide)]];
     
            // Set view controllers
            [strongSelf willChangeCurrentPages];
            [strongSelf setViewControllers:@[ viewController ] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            [strongSelf didChangeCurrentPages];
        }
        
        // Nothing to do in "else" case because view controllers are overwritten
    }; // job
    
    BOOL const isOnscreen = self.reserved.isInsideViewWillAppearSession || ([self isViewLoaded] && self.view.window);
    if (isOnscreen) {
        self.reserved.postponedPlaceholderViewManipulation = nil; // Cancel previous
        job();
    }
    else {
        self.reserved.postponedPlaceholderViewManipulation = job; // Postpone
    }
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
