#import "MUKDataSourceContentLoading.h"

NSString *const MUKDataSourceContentLoadingStateInitial             = @"MUKDataSourceContentLoadingStateInitial";
NSString *const MUKDataSourceContentLoadingStateRestoringFromCache  = @"MUKDataSourceContentLoadingStateRestoringFromCache";
NSString *const MUKDataSourceContentLoadingStateRefreshing          = @"MUKDataSourceContentLoadingStateRefreshing";
NSString *const MUKDataSourceContentLoadingStateAppending           = @"MUKDataSourceContentLoadingStateAppending";
NSString *const MUKDataSourceContentLoadingStateLoaded              = @"MUKDataSourceContentLoadingStateLoaded";
NSString *const MUKDataSourceContentLoadingStateSavingToCache       = @"MUKDataSourceContentLoadingStateSavingToCache";
NSString *const MUKDataSourceContentLoadingStateNoContent           = @"MUKDataSourceContentLoadingStateNoContent";
NSString *const MUKDataSourceContentLoadingStateError               = @"MUKDataSourceContentLoadingStateError";

NSString *const MUKDataSourceContentLoadingEventRestoreFromCache        = @"MUKDataSourceContentLoadingEventRestoreFromCache";
NSString *const MUKDataSourceContentLoadingEventRefresh                 = @"MUKDataSourceContentLoadingEventRefresh";
NSString *const MUKDataSourceContentLoadingEventAppend                  = @"MUKDataSourceContentLoadingEventAppend";
NSString *const MUKDataSourceContentLoadingEventDisplayLoadedContents   = @"MUKDataSourceContentLoadingEventDisplayLoadedContents";
NSString *const MUKDataSourceContentLoadingEventDisplayNoContent        = @"MUKDataSourceContentLoadingEventDisplayNoContent";
NSString *const MUKDataSourceContentLoadingEventDisplayError            = @"MUKDataSourceContentLoadingEventDisplayError";
NSString *const MUKDataSourceContentLoadingEventSaveToCache             = @"MUKDataSourceContentLoadingEventSaveToCache";
