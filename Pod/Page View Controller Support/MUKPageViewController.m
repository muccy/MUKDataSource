#import "MUKPageViewController.h"
#import <KVOController/FBKVOController.h>

@interface MUKPageViewController ()
@property (nonatomic, readwrite, getter=isPageViewControllerTransitionInProgress) BOOL pageViewControllerTransitionInProgress;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.KVOController observe:self keyPath:NSStringFromSelector(@selector(pageDataSource)) options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(MUKPageViewController *observer, MUKPageViewController *object, NSDictionary *change)
    {
        observer.dataSource = observer.pageDataSource;
    }];

    // Observe placeholder
//    NSString *const contentKeyPath = [dataSourceKeyPath stringByAppendingFormat:@".%@", NSStringFromSelector(@selector(content))];
//    [self.KVOController observe:self keyPath:contentKeyPath options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew block:^(MUKCollectionViewController *observer, MUKCollectionViewController *object, NSDictionary *change)
//     {
//         if ([observer.dataSource.content isKindOfClass:[MUKDataSourceContentPlaceholder class]])
//         {
//             [observer didSetContentPlaceholder:(MUKDataSourceContentPlaceholder *)observer.dataSource.content];
//         }
//         else {
//             [observer didSetContentPlaceholder:nil];
//         }
//     }];
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
