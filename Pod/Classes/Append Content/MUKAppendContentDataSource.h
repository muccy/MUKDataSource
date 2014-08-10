#import <MUKDataSource/MUKDataSource_Main.h>
#import <MUKDataSource/MUKDataSourceAppendContentView.h>

@interface MUKAppendContentDataSource : MUKDataSource
@property (nonatomic) UIView *appendContentView;
@property (nonatomic, getter = isHidden) BOOL hidden;
- (void)setHidden:(BOOL)hidden animated:(BOOL)animated;
@end

@interface MUKAppendContentDataSource (Utils)
+ (BOOL)shouldTypicallyHideWhenWillLoadContent:(MUKDataSourceContentLoading *)contentLoading;
+ (BOOL)shouldTypicallyHideWhenDidLoadContent:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType;
@end
