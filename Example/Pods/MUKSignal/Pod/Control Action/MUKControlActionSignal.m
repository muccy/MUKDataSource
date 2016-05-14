#import "MUKControlActionSignal.h"
#import "MUKSignal+Dispatching.h"
#import "MUKSignal+Subscribing.h"

@implementation MUKControlActionSignal

- (void)dealloc {
    [self.control removeTarget:self action:@selector(handleAction:forEvent:) forControlEvents:self.events];
}

- (instancetype)initWithControl:(UIControl *)control forEvents:(UIControlEvents)events
{
    self = [super init];
    if (self) {
        _control = control;
        _events = events;
        [control addTarget:self action:@selector(handleAction:forEvent:) forControlEvents:events];
    }
    
    return self;
}

- (void)handleAction:(UIControl *)sender forEvent:(UIEvent *)event {
    [self dispatch:event];
}

#pragma mark - Overrides

- (instancetype)init {
    NSAssert(NO, @"Use designated initializer");
    return [self initWithControl:[UIControl new] forEvents:UIControlEventAllEvents];
}

- (void)dispatch:(id)payload {
    NSAssert(!payload || [payload isKindOfClass:[UIEvent class]], @"Can only dispatch UIEvent");
    [super dispatch:payload];
}

- (id)subscribe:(void (^)(UIEvent * _Nullable))subscriber {
    return [super subscribe:subscriber];
}

@end
