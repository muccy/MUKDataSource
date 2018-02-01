#import "MUKSignal-Base.h"
#import "MUKSignal+Subscribing.h"
#import "MUKSignal+Dispatching.h"
#import "MUKSignal+Suspending.h"

static NSString *const kNullPayload = @"MUKSignal-NullPayload";

@interface MUKSignal ()
@property (nonatomic, readonly, nonnull) NSMutableDictionary<NSUUID *, MUKSignalSubscriber> *subscriptions;
@property (nonatomic, readonly, nonnull) NSMutableSet<NSUUID *> *suspendedTokens;
@property (nonatomic, readonly, nonnull) NSMutableDictionary<NSUUID *, id> *suspendedDispatchPayloads;
@end

@implementation MUKSignal
@synthesize subscriptions = _subscriptions;
@synthesize suspendedTokens = _suspendedTokens;
@synthesize suspendedDispatchPayloads = _suspendedDispatchPayloads;

#pragma mark - Accessors

- (NSMutableDictionary<NSUUID *,MUKSignalSubscriber> *)subscriptions {
    if (!_subscriptions) {
        _subscriptions = [NSMutableDictionary dictionary];
    }
    
    return _subscriptions;
}

- (NSMutableSet<NSUUID *> *)suspendedTokens {
    if (!_suspendedTokens) {
        _suspendedTokens = [NSMutableSet set];
    }
    
    return _suspendedTokens;
}

- (NSMutableDictionary<NSUUID *, id> *)suspendedDispatchPayloads {
    if (!_suspendedDispatchPayloads) {
        _suspendedDispatchPayloads = [NSMutableDictionary dictionary];
    }
    
    return _suspendedDispatchPayloads;
}

#pragma mark - Subscribing

- (id)subscribe:(void (^)(id _Nonnull))subscriber {
    NSUUID *const token = [NSUUID UUID];
    self.subscriptions[token] = [subscriber copy];
    return token;
}

- (id)subscribeWithTarget:(__weak id)target action:(SEL)action {
    return [self subscribe:^(id  _Nullable payload) {
        __strong __typeof__(target) strongTarget = target;
        
        // Prevent leaks warning by using invocation
        // http://stackoverflow.com/a/28276187/224629
        NSMethodSignature *const signature = [strongTarget methodSignatureForSelector:action];
        
        if (signature) {
            NSInvocation *const invocation = [NSInvocation invocationWithMethodSignature:signature];
            invocation.target = strongTarget;
            invocation.selector = action;
            
            if (signature.numberOfArguments > 2) {
                [invocation setArgument:&payload atIndex:2];
            }
            
            [invocation invoke];
        }
    }];
}

- (void)unsubscribe:(id)token {
    [_subscriptions removeObjectForKey:token];
    [_suspendedDispatchPayloads removeObjectForKey:token];
    [_suspendedTokens removeObject:token];
}

#pragma mark - Dispatching

- (void)dispatch:(id)payload {
    [[_subscriptions copy] enumerateKeysAndObjectsUsingBlock:^(NSUUID * _Nonnull key, MUKSignalSubscriber _Nonnull obj, BOOL * _Nonnull stop)
    {
        [self dispatchToSubscriber:obj withPayload:payload subscriptionToken:key];
    }];
}

- (void)dispatchToSubscriber:(MUKSignalSubscriber)subscriber withPayload:(nullable id)payload subscriptionToken:(nonnull id)token
{
    if ([self isSuspended:token]) {
        id const rawSuspendedPayload = _suspendedDispatchPayloads[token];

        id payloadToSuspend;
        if (rawSuspendedPayload) {
            payloadToSuspend = [self mergedDispatchPayload:payload withSuspendedPayload:DispatchablePayloadForRawPayload(rawSuspendedPayload)];
        }
        else {
            payloadToSuspend = payload;
        }
        
        [self storeSuspendedDispatchPayload:payloadToSuspend forSubscriptionToken:token];
    }
    else {
        subscriber(payload);
    }
}

#pragma mark - Suspending

- (void)suspend:(id)token {
    [self.suspendedTokens addObject:token];
}

- (void)resume:(id)token {
    [_suspendedTokens removeObject:token];
    [self consumeSuspendedDispatchPayloadForSubscriptionToken:token];
}

- (BOOL)isSuspended:(id)token {
    return [_suspendedTokens containsObject:token];
}

- (id)suspendedDispatchPayload:(id)token {
    id const rawPayload = _suspendedDispatchPayloads[token];
    return DispatchablePayloadForRawPayload(rawPayload);
}

- (id)mergedDispatchPayload:(id)payload withSuspendedPayload:(id)suspendedPayload
{
    return payload;
}

#pragma mark - Private — Suspending

static inline id _Nullable DispatchablePayloadForRawPayload(id _Nullable rawPayload)
{
    return rawPayload == kNullPayload ? nil : rawPayload;
}

- (void)storeSuspendedDispatchPayload:(nullable id)payload forSubscriptionToken:(id)token
{
    self.suspendedDispatchPayloads[token] = payload ?: kNullPayload;
}

- (void)consumeSuspendedDispatchPayloadForSubscriptionToken:(id)token {
    id const rawPayload = _suspendedDispatchPayloads[token];
    
    if (rawPayload) {
        [_suspendedDispatchPayloads removeObjectForKey:token];
        
        MUKSignalSubscriber const subscriber = _subscriptions[token];
        
        if (subscriber) {
            [self dispatchToSubscriber:subscriber withPayload:DispatchablePayloadForRawPayload(rawPayload) subscriptionToken:token];
        }
    }
}

@end
