#import <MUKSignal/MUKSignal-Base.h>

NS_ASSUME_NONNULL_BEGIN

/// Payload of MUKKVOSignal
@interface MUKKVOSignalChange<__covariant T> : NSObject
/// Value before change
@property (nonatomic, readonly, nullable) T oldValue;
/// Value after change
@property (nonatomic, readonly, nullable) T value;
@end


/**
 A signal sent when observed object changes.
 @warning Pay attention to release the signal when you release the observed 
 object.
 */
@interface MUKKVOSignal<__covariant T> : MUKSignal<MUKKVOSignalChange *>
/// Observed object
@property (nonatomic, readonly, weak) __kindof NSObject *object;
/// Observed key path
@property (nonatomic, readonly, copy) NSString *keyPath;

/// Designated initializer
- (instancetype)initWithObject:(__kindof NSObject *)object keyPath:(NSString *)keyPath NS_DESIGNATED_INITIALIZER;

// Redefinition to use MUKKVOSignalChange autocompletion
- (id)subscribe:(void (^)(MUKKVOSignalChange<T> *change))subscriber;

// @returns YES if this signal is observing passed object. It is useful when
// self.object is already zeroed out but you want to know if there is an
// observation to shut down
- (BOOL)isObservingObject:(__kindof NSObject *)object;
@end

NS_ASSUME_NONNULL_END
