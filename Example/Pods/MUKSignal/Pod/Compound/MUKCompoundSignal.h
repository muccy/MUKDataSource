#import <MUKSignal/MUKSignal-Base.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUKCompoundSignalPayload<__covariant T> : NSObject
/// The subsignal which originated this dispatch
@property (nonatomic, readonly) __kindof MUKSignal<T> *subsignal;
/// The payload dispatched by subsignal
@property (nonatomic, nullable, readonly) T subpayload;
@end


/// A signal which subscribes to child signals and it dispatches everytime it
/// receives an input
@interface MUKCompoundSignal : MUKSignal<MUKCompoundSignalPayload *>
/// Signals subscribed by this compound signal
@property (nonatomic, readonly, copy) NSArray<__kindof MUKSignal *> *subsignals;

/// Designated initializer
- (instancetype)initWithSubsignals:(NSArray<__kindof MUKSignal *> *)subsignals NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
