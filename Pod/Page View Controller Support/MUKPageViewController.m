#import "MUKPageViewController.h"
#import <KVOController/FBKVOController.h>
#import "MUKDataSourceContentPlaceholderView.h"

@interface MUKPageViewController ()
@property (nonatomic, readwrite, getter=isPageViewControllerTransitionInProgress) BOOL pageViewControllerTransitionInProgress;
@property (nonatomic, getter=isObservingDataSourceContent) BOOL observingDataSourceContent;
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

+ (NSString *)dataSourceContentKeyPath {
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

- (void)didSetContentPlaceholder:(nullable MUKDataSourceContentPlaceholder *)placeholder
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
        [self willChangeCurrentPages];
        [self setViewControllers:@[ viewController ] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        [self didChangeCurrentPages];
    }
    
    // Nothing to do in "else" case because view controllers are overwritten
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