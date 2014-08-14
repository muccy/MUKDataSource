#import <Foundation/Foundation.h>

// Starts first loading
// Initial -> Loading
extern NSString *const MUKDataSourceContentLoadEventBeginLoading;

// Starts refresh
// Loaded -> Refreshing
// Empty -> Refreshing
// Error -> Refreshing
extern NSString *const MUKDataSourceContentLoadEventBeginRefreshing;

// Starts appending more contents to existing contents
// Loaded -> Appending
extern NSString *const MUKDataSourceContentLoadEventBeginAppending;

// Displays existing data
// Loading -> Loaded
// Refreshing -> Loaded
// Appending -> Loaded
extern NSString *const MUKDataSourceContentLoadEventDisplayLoaded;

// Displays no data
// Loading -> Empty
// Refreshing -> Empty
extern NSString *const MUKDataSourceContentLoadEventDisplayEmpty;

// Displays error
// Loading -> Error
// Refreshing -> Error
extern NSString *const MUKDataSourceContentLoadEventDisplayError;

// Declare loaded without loading
// Initial -> Loaded
// Empty -> Loaded
// Error -> Loaded
extern NSString *const MUKDataSourceContentLoadEventDeclareLoaded;

// Declare empty without refreshing
// Initial -> Empty
// Loaded -> Empty
// Error -> Empty
extern NSString *const MUKDataSourceContentLoadEventDeclareEmpty;
