#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceContentLoadingResultType.h>

@class MUKDataSource;
@interface MUKDataSourceSnapshot : NSObject <NSSecureCoding>
@property (nonatomic, readonly) NSDate *date;
@property (nonatomic, readonly) MUKDataSource *dataSource;
@property (nonatomic, readonly) MUKDataSourceContentLoadingResultType equivalentResultType;

- (instancetype)initWithDataSource:(MUKDataSource *)dataSource;
@end
