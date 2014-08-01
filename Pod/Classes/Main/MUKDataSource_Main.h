@interface MUKDataSource : NSObject

@end

@interface MUKDataSource (Contents)
@property (nonatomic, copy) NSArray *items;
@end

@interface MUKDataSource (Containment)
@property (nonatomic, readonly) NSArray *childDataSources;
@property (nonatomic, weak, readonly) MUKDataSource *parentDataSource;
- (void)addChildDataSource:(MUKDataSource *)dataSource;
- (void)removeDataSource:(MUKDataSource *)dataSource;
@end
