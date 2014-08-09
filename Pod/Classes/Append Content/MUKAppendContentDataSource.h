#import <MUKDataSource/MUKDataSource_Main.h>

@interface MUKAppendContentDataSource : MUKDataSource
@property (nonatomic, readonly) BOOL isShowingAppendingContent;
@property (nonatomic, readonly) BOOL isShowingCouldAppendContent;

- (BOOL)showAppendingContentIfNeededWithContentLoading:(MUKDataSourceContentLoading *)contentLoading animated:(BOOL)animated;
- (BOOL)showCouldAppendContentIfNeededWithContentLoading:(MUKDataSourceContentLoading *)contentLoading resultType:(MUKDataSourceContentLoadingResultType)resultType animated:(BOOL)animated;
@end

@interface MUKAppendContentDataSource (TableView)
- (void)configureAppendingContentTableViewCell:(UITableViewCell *)cell;
- (void)configureCouldAppendContentTableViewCell:(UITableViewCell *)cell;
@end
