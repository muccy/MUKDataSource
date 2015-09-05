#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKDataSource.h>
#import <MUKDataSource/MUKDataSourceContentPlaceholder.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Simple page view controller which holds a data source and sets as delegate itself
 */
@interface MUKPageViewController : UIPageViewController
/**
 When you set pageDataSource you set self.dataSource to it, too
 */
@property (nonatomic, nullable) MUKDataSource *pageDataSource;
/**
 Currently displayed pages
 */
@property (nonatomic, readonly) NSArray *currentPages;
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
- (void)setCurrentPages:(NSArray *)pages animated:(BOOL)animated completion:(void (^__nullable)(BOOL finished))completionHandler;
@end

@interface MUKPageViewController (ContentPlaceholder)
/**
 @param placeholder Placeholder set as data source content
 @returns View to display when a placeholder is set. You can return nil not to
 show a view. By default it returns a MUKDataSourceContentPlaceholderView instance.
 */
- (UIView *__nullable)viewForContentPlaceholder:(MUKDataSourceContentPlaceholder *)placeholder;
@end

@interface MUKPageViewController (UIPageViewControllerDelegateImplementedMethods) <UIPageViewControllerDelegate>
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers;
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed;
@end

NS_ASSUME_NONNULL_END
