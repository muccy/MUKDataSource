#import <UIKit/UIKit.h>

/**
 A view which contains a text label with a trailing spinner. 
 It is ideal to be used as user interface to append content.
 */
@interface MUKDataSourceAppendContentView : UIView
/**
 Text label.
 */
@property (nonatomic, weak, readonly) UILabel *textLabel;
/**
 Spinner.
 It is rendered on textLabel right side.
 */
@property (nonatomic, weak, readonly) UIActivityIndicatorView *activityIndicatorView;
/**
 The margin from left to textLabel left side.
 Default: 15.0f
 */
@property (nonatomic) CGFloat leftMargin;
@end
