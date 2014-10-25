#import "MUKDataSourceContentLoading.h"

@interface MUKDataSourceContentLoading ()
@property (nonatomic, copy, readwrite) NSString *sourceState;
@property (nonatomic, weak, readwrite) MUKDataSource *dataSource;
@property (nonatomic, readwrite, getter = isValid) BOOL valid;
@end
