#import "MUKSignalObservation.h"
#import <MUKSignal+Subscribing.h>
#import <MUKSignal+Suspending.h>

@implementation MUKSignalObservation

- (void)dealloc {
    [self.signal unsubscribe:self.token];
}

- (instancetype)initWithSignal:(MUKSignal *)signal token:(nonnull id)token {
    self = [super init];
    if (self) {
        _signal = signal;
        _token = token;
    }
    
    return self;
}

+ (instancetype)observationWithSignal:(MUKSignal *)signal token:(id)token {
    return [[self alloc] initWithSignal:signal token:token];
}

- (void)resume {
    [self.signal resume:self.token];
}

- (void)suspend {
    [self.signal suspend:self.token];
}

#pragma mark - Overrides

- (instancetype)init {
    NSAssert(NO, @"Use designated initializer");
    return [self initWithSignal:[MUKSignal new] token:@""];
}

@end
