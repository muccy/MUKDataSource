#import "MUKPageViewController.h"
#import <KVOController/FBKVOController.h>
#import "MUKDataSourceContentPlaceholderView.h"

@interface MUKPageViewController ()
@property (nonatomic, readwrite, getter=isPageViewControllerTransitionInProgress) BOOL pageViewControllerTransitionInProgress;
@property (nonatomic, getter=isObservingDataSourceContent) BOOL observingDataSourceContent;
@end

@implementation MUKPageViewController
@dynamic currentPages;

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

#pragma mark - Accessors

- (void)setPageDataSource:(MUKDataSource *)pageDataSource {
    if (pageDataSource != _pageDataSource) {
        _pageDataSource = pageDataSource;
        self.dataSource = pageDataSource;
    }
}

#pragma mark - Content Placeholder

- (UIView * __nullable)viewForContentPlaceholder:(MUKDataSourceContentPlaceholder * __nonnull)placeholder
{
    MUKDataSourceContentPlaceholderView *const view = [[MUKDataSourceContentPlaceholderView alloc] initWithFrame:self.view.bounds];
    view.titleLabel.text = placeholder.title;
    view.textLabel.text = placeholder.subtitle;
    view.imageView.image = placeholder.image;
    
    return view;
}

#pragma mark - Overrides

// http://stackoverflow.com/a/25549277
- (void)setViewControllers:(NSArray*)viewControllers direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL))completionHandler
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

- (NSArray * __nonnull)currentPages {
    NSMutableArray *const pages = [NSMutableArray arrayWithCapacity:1];
    
    for (UIViewController *viewController in self.viewControllers) {
        id<MUKDataSourceIdentifiable> const page = [self.pageDataSource pageForViewController:viewController];
        
        if (page) {
            [pages addObject:page];
        }
    } // for
    
    if (pages.count) {
        return [pages copy];
    }
    
    return nil;
}

#pragma mark - Methods

- (void)setCurrentPages:(NSArray * __nonnull)pages animated:(BOOL)animated completion:(void (^ __nullable)(BOOL))completionHandler
{
    if (pages.count < 1) {
        if (completionHandler) {
            completionHandler(NO);
        }
        
        return;
    }
    
    // Create matching view controllers
    NSMutableArray *const viewControllers = [NSMutableArray arrayWithCapacity:pages.count];
    for (id<MUKDataSourceIdentifiable> page in pages) {
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
    [self willChangeValueForKey:NSStringFromSelector(@selector(currentPages))];

    __weak typeof(self) weakSelf = self;
    [self setViewControllers:[viewControllers copy] direction:direction animated:animated completion:^(BOOL finished)
    {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf didChangeValueForKey:NSStringFromSelector(@selector(currentPages))];
    }];
}

#pragma mark - Private

+ (NSString *__nonnull)dataSourceContentKeyPath {
    return [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(pageDataSource)), NSStringFromSelector(@selector(content))];
}

- (void)observeDataSourceContent {
    [self.KVOControllerNonRetaining observe:self keyPath:[[self class] dataSourceContentKeyPath] options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(MUKPageViewController *observer, MUKPageViewController *object, NSDictionary *change)
    {
        if ([observer.pageDataSource.content isKindOfClass:[MUKDataSourceContentPlaceholder class]])
        {
            [observer didSetContentPlaceholder:(MUKDataSourceContentPlaceholder *)observer.pageDataSource.content];
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
        [self willChangeValueForKey:NSStringFromSelector(@selector(currentPages))];
        [self setViewControllers:@[ viewController ] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        [self didChangeValueForKey:NSStringFromSelector(@selector(currentPages))];
    }
    
    // Nothing to do in "else" case because view controllers are overwritten
}

#pragma mark - <UIPageViewControllerDelegate>

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    self.pageViewControllerTransitionInProgress = YES;
    [self willChangeValueForKey:NSStringFromSelector(@selector(currentPages))];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    [self didChangeValueForKey:NSStringFromSelector(@selector(currentPages))];
    self.pageViewControllerTransitionInProgress = NO;
}

@end
