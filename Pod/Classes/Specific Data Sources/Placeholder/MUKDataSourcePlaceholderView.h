#import <UIKit/UIKit.h>

/**
 A view which contains centered title and text labels and an image view on top.
 It is ideal to be used as user interface to show a fullscreen placeholder.
 */
@interface MUKDataSourcePlaceholderView : UIView
/**
 Title label.
 */
@property (nonatomic, weak, readonly) UILabel *titleLabel;
/**
 Text label.
 It is layed out under titleLabel.
 */
@property (nonatomic, weak, readonly) UILabel *textLabel;
/**
 Image view.
 It is layed out above titleLabel.
 */
@property (nonatomic, weak, readonly) UIImageView *imageView;
@end
