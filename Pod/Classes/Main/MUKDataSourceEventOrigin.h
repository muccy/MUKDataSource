#import <Foundation/Foundation.h>

/**
 The origin of an event inside the data source.
 */
typedef NS_ENUM(NSInteger, MUKDataSourceEventOrigin) {
    /**
     The origin cannot be estabilished.
     */
    MUKDataSourceEventOriginUnknown = 0,
    /**
     The origin is programmatic.
     */
    MUKDataSourceEventOriginProgrammatic,
    /**
     The origin is user interaction (like gesture on table view cells and so on).
     */
    MUKDataSourceEventOriginUserInteraction
};
