#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKDataSource.h>
#import <MUKDataSource/MUKDataSourceContentPlaceholder.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Simple page view controller which holds a data source and sets as delegate itself
 */
@interface MUKPageViewController<__covariant PageType> : UIPageViewController
/**
 When you set pageDataSource you set self.dataSource to it, too
 */
@property (nonatomic, nullable) __kindof MUKDataSource<PageType> *pageDataSource;
/**
 Currently displayed pages
 */
@property (nonatomic, readonly) NSArray<PageType> *currentPages;
/**
 YES if user is changing page with a gesture
 */
@property (nonatomic, readonly, getter=isPageViewControllerTransitionInProgress) BOOL pageViewControllerTransitionInProgress;
/**
 Set view controller with given pages
 @param pages Items used to create representative view controllers
 @param animated YES if transition should be animated
 @param completionHandler Block called when transition is completed
 */
- (void)setCurrentPages:(NSArray<PageType> *)pages animated:(BOOL)animated completion:(void (^_Nullable)(BOOL finished))completionHandler;
/**
 Callback called when self.currentPages is about to change
 */
- (void)willChangeCurrentPages NS_REQUIRES_SUPER;
/**
 Callback invoked when the change initiated by -willChangeCurrentPages has finished
 */
- (void)didChangeCurrentPages NS_REQUIRES_SUPER;
@end

@interface MUKPageViewController (ContentPlaceholder)
/**
 @param placeholder Placeholder set as data source content
 @returns View to display when a placeholder is set. You can return nil not to
 show a view. By default it returns a MUKDataSourceContentPlaceholderView instance.
 */
- (nullable __kindof UIView *)viewForContentPlaceholder:(__kindof MUKDataSourceContentPlaceholder *)placeholder;
@end

@interface MUKPageViewController (UIPageViewControllerDelegateImplementedMethods) <UIPageViewControllerDelegate>
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers;
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed;
@end

NS_ASSUME_NONNULL_END
