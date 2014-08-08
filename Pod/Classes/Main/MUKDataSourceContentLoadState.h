#import <Foundation/Foundation.h>

// Initial state
extern NSString *const MUKDataSourceContentLoadStateInitial;

// First load. You could use it to load from cache
extern NSString *const MUKDataSourceContentLoadStateLoading;

// Reload subsequent the first load
extern NSString *const MUKDataSourceContentLoadStateRefreshing;

// Appending content to existing content
extern NSString *const MUKDataSourceContentLoadStateAppending;

// Content loaded and displayable
extern NSString *const MUKDataSourceContentLoadStateLoaded;

// No content available
extern NSString *const MUKDataSourceContentLoadStateEmpty;

// Error occured during loading
extern NSString *const MUKDataSourceContentLoadStateError;
