#import <MUKSignal/MUKSignal-Base.h>

NS_ASSUME_NONNULL_BEGIN

/// A signal sent when a control receives an action for an event
@interface MUKControlActionSignal<__covariant T:UIControl *> : MUKSignal
/// Observed control
@property (nonatomic, readonly, weak) T control;
/// Observed control events
@property (nonatomic, readonly) UIControlEvents events;

/// Designated initializer
- (instancetype)initWithControl:(T)control forEvents:(UIControlEvents)events NS_DESIGNATED_INITIALIZER;

// Redefinition to use UIEvent autocompletion
- (id)subscribe:(void (^)(UIEvent * _Nullable event))subscriber;
@end

NS_ASSUME_NONNULL_END
