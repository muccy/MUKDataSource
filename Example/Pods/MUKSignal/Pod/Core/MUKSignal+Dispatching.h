#import <MUKSignal/MUKSignal+Subscribing.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUKSignal<__covariant T> (Dispatching)
/**
 Dispatch a signal
 @param payload A T-typed payload
 */
- (void)dispatch:(nullable T)payload;
/**
 Primitive invoked by -dispatch: to call a subscriber or to store payload if 
 signal is suspended.
 @param subscriber Subscriber to inform
 @param payload Payload to pass to subscriber
 @param token Subscription token
 @warning You should not call this method directly
 */
- (void)dispatchToSubscriber:(MUKSignalSubscriber)subscriber withPayload:(nullable T)payload subscriptionToken:(id)token;
@end

NS_ASSUME_NONNULL_END
