#import <MUKDataSource/MUKSingleViewDataSource.h>

/**
 A data source which helps to manage placeholder user interface (typically
 on empty or error loading states).
 It uses title to configure placeholder view.
 By default it allocates a MUKDataSourcePlaceholderView instance.
 */
@interface MUKPlaceholderDataSource : MUKSingleViewDataSource
/**
 Placeholder text.
 */
@property (nonatomic, copy) NSString *text;
/**
 Placeholder image.
 */
@property (nonatomic) UIImage *image;
@end
