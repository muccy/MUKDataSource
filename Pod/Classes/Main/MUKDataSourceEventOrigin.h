#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MUKDataSourceEventOrigin) {
    MUKDataSourceEventOriginUnknown = 0,
    MUKDataSourceEventOriginProgrammatic,
    MUKDataSourceEventOriginUserInteraction
};
