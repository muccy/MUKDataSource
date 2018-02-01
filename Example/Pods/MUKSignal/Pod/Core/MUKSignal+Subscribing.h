#import <MUKSignal/MUKSignal-Base.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUKSignal<__covariant T> (Subscribing)
/// The subscriber is a block with accepts a T-typed payload
typedef void (^MUKSignalSubscriber)(T _Nullable payload);
/**
 Subscribe to a signal
 @param subscriber The handler which will be invoked
 @returns A token which could be used to unsubscribe from signal
 */
- (id)subscribe:(MUKSignalSubscriber)subscriber;
/**
 Subscribe to a signal
 @param target The object which will be invoked. This object will not be retained.
 @param action The selector which will be used on target. This selector could take
            no parameters (`signalFired`) or one parameter (`signalFiredWithPayload:`).
 @returns A token which could be used to unsubscribe from signal
 */
- (id)subscribeWithTarget:(id __weak)target action:(SEL)action;
/**
 Unsubscribe from a signal
 @param token The token acquired when subscribed
 */
- (void)unsubscribe:(id)token;
@end

NS_ASSUME_NONNULL_END
