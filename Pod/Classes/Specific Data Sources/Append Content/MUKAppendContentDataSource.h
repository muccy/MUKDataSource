#import <MUKDataSource/MUKSingleViewDataSource.h>

/**
 A data source which helps to manage append content user interface.
 By default it allocates a MUKDataSourceAppendContentView instance.
 */
@interface MUKAppendContentDataSource : MUKSingleViewDataSource
/**
 Tells data source it needs to show an animated activity indicator.
 It defaults to NO.
 */
@property (nonatomic) BOOL showsActivityIndicator;
@end

@interface MUKAppendContentDataSource (Utils)
/**
 Suggests if append content view should be hidden as content loading is beginning.
 @return If append content view should be hidden as content loading is beginning.
 */
+ (BOOL)shouldTypicallyHideWhenWillLoadContent:(MUKDataSourceContentLoading *)contentLoading;
/**
 Suggests if append content view should be hidden as content loading has finished.
 @return If append content view should be hidden as content loading has finished.
 */
+ (BOOL)shouldTypicallyHideWhenDidLoadContent:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType;
@end
