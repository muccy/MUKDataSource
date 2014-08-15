#import <Foundation/Foundation.h>

/**
 How content loading has finished.
 */
typedef NS_ENUM(NSInteger, MUKDataSourceContentLoadingResultType) {
    /**
     Content loading has found all requested data.
     */
    MUKDataSourceContentLoadingResultTypeComplete,
    /**
     Content loading has found a part of requested data.
     */
    MUKDataSourceContentLoadingResultTypePartial,
    /**
     Content loading has found no data.
     */
    MUKDataSourceContentLoadingResultTypeEmpty,
    /**
     Content loading has encountered an error.
     */
    MUKDataSourceContentLoadingResultTypeError,
    /**
     Content loading has been cancelled.
     */
    MUKDataSourceContentLoadingResultTypeCancelled
};
