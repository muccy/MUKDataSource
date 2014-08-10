#import <MUKDataSource/MUKDataSource_Main.h>
#import <MUKDataSource/MUKDataSourcePlaceholderView.h>

@interface MUKPlaceholderDataSource : MUKDataSource
@property (nonatomic) UIView *placeholderView;
@property (nonatomic, getter = isHidden) BOOL hidden;
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;
@end
