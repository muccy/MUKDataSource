#import <Foundation/Foundation.h>

// Initial state
/**
 Initial state.
 Valid transitions to:
 * MUKDataSourceContentLoadStateLoading
 * MUKDataSourceContentLoadStateLoaded (with declaration)
 * MUKDataSourceContentLoadStateEmpty (with declaration)
 */
extern NSString *const MUKDataSourceContentLoadStateInitial;
/**
 First load.
 Valid transitions to:
 * MUKDataSourceContentLoadStateLoaded
 * MUKDataSourceContentLoadStateEmpty
 * MUKDataSourceContentLoadStateError
 */
extern NSString *const MUKDataSourceContentLoadStateLoading;
/**
 Reload subsequent the first load.
 Valid transitions to:
 * MUKDataSourceContentLoadStateLoaded
 * MUKDataSourceContentLoadStateEmpty
 * MUKDataSourceContentLoadStateError
 */
extern NSString *const MUKDataSourceContentLoadStateRefreshing;
/**
 Appending content to existing content.
 Valid transitions to:
 * MUKDataSourceContentLoadStateLoaded
 */
extern NSString *const MUKDataSourceContentLoadStateAppending;
/**
 Content loaded and displayable.
 Valid transitions to:
 * MUKDataSourceContentLoadStateRefreshing
 * MUKDataSourceContentLoadStateAppending
 * MUKDataSourceContentLoadStateEmpty (with declaration)
 */
extern NSString *const MUKDataSourceContentLoadStateLoaded;
/**
 No content available.
 Valid transitions to:
 * MUKDataSourceContentLoadStateRefreshing
 * MUKDataSourceContentLoadStateAppending
 * MUKDataSourceContentLoadStateLoaded (with declaration)
 */
extern NSString *const MUKDataSourceContentLoadStateEmpty;
/**
 A blocking error occured during loading.
 Valid transitions to:
 * MUKDataSourceContentLoadStateRefreshing
 * MUKDataSourceContentLoadStateLoaded (with declaration)
 * MUKDataSourceContentLoadStateEmpty (with declaration)
 */
extern NSString *const MUKDataSourceContentLoadStateError;
