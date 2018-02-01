#import <MUKSignal/MUKSignal-Base.h>

NS_ASSUME_NONNULL_BEGIN

@interface MUKNotificationSignal : MUKSignal<NSNotification *>
/// Observed notification name
@property (nonatomic, readonly, nullable, copy) NSString *name;
/// Observed notification object
@property (nonatomic, readonly, nullable) id object;

/// Designated initializer
- (instancetype)initWithName:(nullable NSString *)name object:(nullable id)object NS_DESIGNATED_INITIALIZER;

// Redefinition to use NSNotification autocompletion
- (id)subscribe:(void (^)(NSNotification *notification))subscriber;
@end

NS_ASSUME_NONNULL_END
