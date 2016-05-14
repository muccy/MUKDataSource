#import <MUKSignal/MUKSignal-Base.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A signal which can be observed with a suspendable subscription.
 When a subscriber is suspended, dispatching a signal does not invoke a
 subscriber. When subscriber is resumed it receives the last dispatched payload.
 */
@interface MUKSignal<__covariant T> (Suspending)
/**
 Suspend a subscriber
 @param token Subscription token
 */
- (void)suspend:(id)token;
/**
 Resume a subscriber
 @param token A suspended subscriber token
 */
- (void)resume:(id)token;
/**
 Get suspension status
 @param token Subscription token
 @returns YES when subscription is suspended
 */
- (BOOL)isSuspended:(id)token;
/**
 Get suspended dispatch payload.
 @param token A suspended subscriber token
 @returns Suspended dispatch payload which will be dispatched when signal is
 resumed.
 */
- (nullable T)suspendedDispatchPayload:(id)token;
/**
 Merge dispatch payload with previous suspended payload.
 This method is not called if there isn't a suspended payload.
 @param payload Dispatched payload
 @param suspendedPayload Stored suspended payload. It could be nil if suspended
 dispatch has a nil payload.
 @returns Merged payload. Default implementation returns payload (trumps suspended one).
 */
- (nullable T)mergedDispatchPayload:(nullable T)payload withSuspendedPayload:(nullable T)suspendedPayload;
@end

NS_ASSUME_NONNULL_END

