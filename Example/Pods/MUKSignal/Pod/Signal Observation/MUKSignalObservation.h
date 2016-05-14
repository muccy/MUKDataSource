#import <MUKSignal/MUKSignal+Subscribing.h>

NS_ASSUME_NONNULL_BEGIN

/// A single observation via a signal
@interface MUKSignalObservation<__covariant T:MUKSignal *> : NSObject
/// The signal used to make observation
@property (nonatomic, readonly) T signal;
/// The token of observation
@property (nonatomic, readonly) id token;

/// Designated initializer
- (instancetype)initWithSignal:(T)signal token:(id)token NS_DESIGNATED_INITIALIZER;
/**
 A shortend to create a new observation.
 You can use this method to store observations like this:
 ```
 MUKSignal *signal = ...;
 self.observation = [MUKSignalObservation observationWithSignal:signal token:[signal subscribe:^(id payload) { ... }]];
 */
+ (instancetype)observationWithSignal:(T)signal token:(id)token;

/// Shortend to resume subscription
- (void)resume;
/// Shortend to suspend subscription
- (void)suspend;
@end

NS_ASSUME_NONNULL_END
