#import <MUKDataSource/MUKDataSource_Main.h>

/**
 A data source which manages a single item with a single view.
 */
@interface MUKSingleViewDataSource : MUKDataSource
/**
 Tells data source to hide/unhide the item (and the view).
 It defaults to NO.
 It is equivalent to call setHidden:animated: without animation.
 */
@property (nonatomic, getter = isHidden) BOOL hidden;
/**
 Tells data source to hide/unhide the item (and the view).
 @param hidden If YES the item is hidden.
 @param animated If YES insertion/deletion of view will be animated.
 */
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;
/**
 View class.
 It used to allocate a view at proper time.
 You should override this method because it returns nil by default.
 @return The class of managed view.
 */
- (Class)viewClass;
/**
 Configure the view.
 @param view View to configure.
 */
- (void)configureView:(UIView *)view;
/**
 Tells data source to update the view.
 You should call this method when you want to change view contents.
 */
- (void)setNeedsUpdateView;
@end
