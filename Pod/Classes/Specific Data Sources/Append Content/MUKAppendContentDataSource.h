#import <MUKDataSource/MUKSingleViewDataSource.h>

@interface MUKAppendContentDataSource : MUKSingleViewDataSource
@property (nonatomic) BOOL showsActivityIndicator;
@end

@interface MUKAppendContentDataSource (Utils)
+ (BOOL)shouldTypicallyHideWhenWillLoadContent:(MUKDataSourceContentLoading *)contentLoading;
+ (BOOL)shouldTypicallyHideWhenDidLoadContent:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType;
@end
