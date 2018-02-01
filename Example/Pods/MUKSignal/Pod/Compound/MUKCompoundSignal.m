//
//  MUKCompoundSignal.m
//  
//
//  Created by Marco on 05/10/16.
//
//

#import "MUKCompoundSignal.h"
#import "MUKSignal+Subscribing.h"
#import "MUKSignal+Dispatching.h"

@implementation MUKCompoundSignalPayload

- (instancetype)initWithSubsignal:(nonnull __kindof MUKSignal *)subsignal subpayload:(nullable id)subpayload
{
    self = [super init];
    if (self) {
        _subsignal = subsignal;
        _subpayload = subpayload;
    }
    
    return self;
}

@end

#pragma mark -

@implementation MUKCompoundSignal

- (instancetype)initWithSubsignals:(NSArray<__kindof MUKSignal *> *)subsignals {
    self = [super init];
    if (self) {
        _subsignals = [subsignals copy]; 
        [self subscribeToSubsignals:subsignals];
    }
    
    return self;
}

#pragma mark - Overrides

- (instancetype)init {
    return [self initWithSubsignals:@[]];
}

- (void)dispatch:(id)payload {
    NSAssert([payload isKindOfClass:[MUKCompoundSignalPayload class]], @"Can only dispatch MUKCompoundSignalPayload");
    [super dispatch:payload];
}

#pragma mark - Private

- (void)subscribeToSubsignals:(nonnull NSArray<__kindof MUKSignal *> *)subsignals {
    __weak __typeof__(self) weakSelf = self;
    
    for (MUKSignal *subsignal in subsignals) {
        __weak __typeof__(subsignal) weakSubsignal = subsignal;
        
        [subsignal subscribe:^(id _Nullable subpayload) {
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            __strong __typeof__(weakSubsignal) strongSubsignal = weakSubsignal;
            
            MUKCompoundSignalPayload *const payload = [[MUKCompoundSignalPayload alloc] initWithSubsignal:strongSubsignal subpayload:subpayload];
            [strongSelf dispatch:payload];
        }];
    } // for
}

@end
