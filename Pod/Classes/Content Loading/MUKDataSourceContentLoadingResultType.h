#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MUKDataSourceContentLoadingResultType) {
    MUKDataSourceContentLoadingResultTypeComplete,
    MUKDataSourceContentLoadingResultTypePartial,
    MUKDataSourceContentLoadingResultTypeEmpty,
    MUKDataSourceContentLoadingResultTypeError
};
