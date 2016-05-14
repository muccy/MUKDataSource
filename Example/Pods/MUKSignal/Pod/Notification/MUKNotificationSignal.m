#import "MUKNotificationSignal.h"
#import "MUKSignal+Subscribing.h"
#import "MUKSignal+Dispatching.h"

@interface MUKNotificationSignal ()
@property (nonatomic, readonly, nonnull) id observer;
@end

@implementation MUKNotificationSignal

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
}

- (instancetype)initWithName:(NSString *)name object:(id)object {
    self = [super init];
    if (self) {
        _name = [name copy];
        _object = object;
        
        __weak __typeof__(self) weakSelf = self;
        _observer = [[NSNotificationCenter defaultCenter] addObserverForName:name object:object queue:nil usingBlock:^(NSNotification * _Nonnull note)
        {
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            [strongSelf dispatch:note];
        }];
    }
    
    return self;
}

#pragma mark - Overrides

- (instancetype)init {
    return [self initWithName:nil object:nil];
}

- (id)subscribe:(void (^)(NSNotification * _Nonnull))subscriber {
    return [super subscribe:subscriber];
}

- (void)dispatch:(id)payload {
    NSAssert([payload isKindOfClass:[NSNotification class]], @"Can only dispatch NSNotification");
    [super dispatch:payload];
}

@end
