#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSourceContentLoadingResultType.h>

@class MUKDataSource;
/**
 Snapshot is a convinient wrapper for data source archiving.
 You should take a snapshot and archive it immediately, because dataSource is not
 copied at this time and its content could mutate.
 */
@interface MUKDataSourceSnapshot : NSObject <NSSecureCoding>
/**
 Creation date.
 */
@property (nonatomic, readonly) NSDate *date;
/**
 Wrapped data source.
 */
@property (nonatomic, readonly) MUKDataSource *dataSource;
/**
 Tells what result type restoration would represent.
 */
@property (nonatomic, readonly) MUKDataSourceContentLoadingResultType equivalentResultType;
/**
 Designated initializer.
 @param dataSource Snapshotted data source.
 @return Initialized instance.
 */
- (instancetype)initWithDataSource:(MUKDataSource *)dataSource;
@end
