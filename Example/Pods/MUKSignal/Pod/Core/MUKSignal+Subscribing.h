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
 Unsubscribe from a signal
 @param token The token acquired when subscribed
 */
- (void)unsubscribe:(id)token;
@end

NS_ASSUME_NONNULL_END
