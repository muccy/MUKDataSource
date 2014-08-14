#import "MUKDataSourceSnapshot.h"
#import "MUKDataSource_Main.h"

static NSString *const kArchiveVersionKey = @"MUKDataSourceSnapshot.Archive.Version";

@implementation MUKDataSourceSnapshot
@dynamic equivalentResultType;

- (instancetype)initWithDataSource:(MUKDataSource *)dataSource {
    self = [super init];
    if (self) {
        _date = [NSDate date];
        _dataSource = dataSource;
    }
    
    return self;
}

- (id)init {
    return [self initWithDataSource:nil];
}

#pragma mark - 

- (MUKDataSourceContentLoadingResultType)equivalentResultType {
    MUKDataSourceContentLoadingResultType resultType;
    
    if ([self.dataSource.loadingState isEqualToString:MUKDataSourceContentLoadStateEmpty] ||
        [self.dataSource.loadingState isEqualToString:MUKDataSourceContentLoadStateInitial])
    {
        resultType = MUKDataSourceContentLoadingResultTypeEmpty;
    }
    else if ([self.dataSource.loadingState isEqualToString:MUKDataSourceContentLoadStateError])
    {
        resultType = MUKDataSourceContentLoadingResultTypeError;
    }
    else {
        resultType = MUKDataSourceContentLoadingResultTypeComplete;
    }
    
    return resultType;
}

#pragma mark - <NSSecureCoding>

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    MUKDataSource *const dataSource = [aDecoder decodeObjectOfClass:[MUKDataSource class] forKey:@"dataSource"];
    self = [self initWithDataSource:dataSource];
    if (self) {
        _date = [aDecoder decodeObjectOfClass:[NSDate class] forKey:@"date"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_date forKey:@"date"];
    [aCoder encodeObject:_dataSource forKey:@"dataSource"];
    [aCoder encodeObject:@"1.0.0" forKey:kArchiveVersionKey];
}

@end
