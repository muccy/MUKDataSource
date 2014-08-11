#import <MUKDataSource/MUKDataSource_Main.h>

@interface MUKSingleViewDataSource : MUKDataSource
@property (nonatomic, getter = isHidden) BOOL hidden;
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;

- (Class)viewClass;
- (void)configureView:(UIView *)view;

- (void)setNeedsUpdateView;
@end
