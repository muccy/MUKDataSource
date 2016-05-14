# MUKSignal

[![CI Status](http://img.shields.io/travis/muccy/MUKSignal.svg?style=flat)](https://travis-ci.org/muccy/MUKSignal)
[![Version](https://img.shields.io/cocoapods/v/MUKSignal.svg?style=flat)](http://cocoadocs.org/docsets/MUKSignal)
[![License](https://img.shields.io/cocoapods/l/MUKSignal.svg?style=flat)](http://cocoadocs.org/docsets/MUKSignal)
[![Platform](https://img.shields.io/cocoapods/p/MUKSignal.svg?style=flat)](http://cocoadocs.org/docsets/MUKSignal)

`MUKSignal` provides a mechanism to dispatch a signal to various subscribers.

## Main features

`MUKSignal` is a simple class which exposes three main features.

### Dispatch

You can dispatch a signal with a payload.

```objective-c
MUKSignal<NSString *> *signal = [[MUKSignal alloc] init];
...
[signal dispatch:@"Hello"];
```

### Subscribtion

You could add subscribers to a signal.

```objective-c
id const token = [signal subscribe:^(NSString *payload) {
    // Called after dispatch
}];
```

### Suspension

A subscription could be temporarily suspended.

```objective-c
[signal suspend:token];
// Dispatches are not delivered
[signal resume:token];
// If a dispatch has occurred during suspension is delivered now (if more than one they are coalesced into one)
```

## Specific signals

Library includes specific signals which are dispatched in particular conditions.

### KVO

KVO signals observe an object and are dispatched when a change occurs.

```objective-c
MUKKVOSignal<NSString *> *signal = [[MUKKVOSignalChange alloc] initWithObject:self keyPath:@"name"];
[signal subscribe:^(MUKKVOSignalChange<NSString *> change) {
    NSLog(@"Name changed from '%@' to '%@'", change.oldValue, change.value);
}];
```

### Notification

Notification signals are dispatched when a notification fires.

```objective-c
MUKNotificationSignal *signal = [[MUKNotificationSignal alloc] initWithName:name:UIApplicationWillEnterForegroundNotification object:nil];
[signal subscribe:^(NSNotification *notification) {
    // App will enter foreground
}];
```

### `UIControl` target-action

Control action signals are dispatched when action for a control is triggered.

```objective-c
MUKControlActionSignal<UIButton *> *signal = [[MUKControlActionSignal alloc] initWithControl:self.button forEvents:UIControlEventTouchUpInside];
[signal subscribe:^(UIEvent *event) {
    // Called when button has been pressed
}];
```

## Observation

Observation is the concept to couple a signal to a particular subscription. It is particular useful when you have many signals to observe not to bloat your view controller.

```objective-c
MUKSignal *signal = ...;
MUKSignalObservation *observation = [MUKSignalObservation observationWithSignal:signal token:[signal subscribe:^(id payload) 
{
    // Waiting for a dispatch
}]];
```

## Requirements

* iOS 7 SDK.
* Minimum deployment target: iOS 7.

## Installation

`MUKSignal` is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "MUKSignal"
	
## Author

Marco Muccinelli, muccymac@gmail.com

## License

`MUKSignal` is available under the MIT license. See the LICENSE file for more info.
