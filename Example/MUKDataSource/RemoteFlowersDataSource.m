//
//  RemoteDataSource.m
//  MUKDataSource
//
//  Created by Marco on 08/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "RemoteFlowersDataSource.h"
#import "FlowerListDataSource.h"
#import "Florist.h"
#import "AppendContentDataSource.h"

#define DEBUG_SIMULATE_EMPTY_ON_REFRESH     0

@interface RemoteFlowersDataSource ()
@property (nonatomic) FlowerListDataSource *flowerListDataSource;
@property (nonatomic) AppendContentDataSource *appendDataSource;
@property (nonatomic) MUKPlaceholderDataSource *placeholderDataSource;
@end

@implementation RemoteFlowersDataSource
@dynamic flowerListDataSource;
@dynamic appendDataSource;
@dynamic placeholderDataSource;

- (id)init {
    self = [super init];
    if (self) {
        [self createAllChildDataSources];
    }
    
    return self;
}

#pragma mark - Accessors

- (FlowerListDataSource *)flowerListDataSource {
    NSInteger idx = [self.childDataSources indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj isKindOfClass:[FlowerListDataSource class]]) {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }];
    
    return (FlowerListDataSource *)[self childDataSourceAtIndex:idx];
}

- (AppendContentDataSource *)appendDataSource {
    NSInteger idx = [self.childDataSources indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj isKindOfClass:[AppendContentDataSource class]]) {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }];
    
    return (AppendContentDataSource *)[self childDataSourceAtIndex:idx];
}

- (MUKPlaceholderDataSource *)placeholderDataSource {
    NSInteger idx = [self.childDataSources indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj isKindOfClass:[MUKPlaceholderDataSource class]]) {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }];
    
    return (MUKPlaceholderDataSource *)[self childDataSourceAtIndex:idx];
}

#pragma mark - Overrides

- (MUKDataSourceContentLoading *)newContentLoadingForState:(NSString *)state {
    static NSInteger const kCount = 20;
    MUKDataSourceContentLoading *contentLoading = [[MUKDataSourceContentLoading alloc] init];
    __weak MUKDataSourceContentLoading *weakContentLoading = contentLoading;
    __weak RemoteFlowersDataSource *weakSelf = self;
    
    MUKDataSourceContentLoadingResultType (^resultTypeForResults)(NSArray *) = ^(NSArray *results)
    {
        MUKDataSourceContentLoadingResultType resultType;
        if ([results count] == 0) {
            resultType = MUKDataSourceContentLoadingResultTypeEmpty;
        }
        else if ([results count] < kCount) {
            resultType = MUKDataSourceContentLoadingResultTypePartial;
        }
        else {
            resultType = MUKDataSourceContentLoadingResultTypeComplete;
        }
        
        return resultType;
    };

    if ([state isEqualToString:MUKDataSourceContentLoadStateLoading]) {
        contentLoading.job = ^{
            RemoteFlowersDataSource *strongSelf = weakSelf;
            MUKDataSourceContentLoading *strongContentLoading = weakContentLoading;
            
            // Load from cache
            [strongSelf loadCachedDataSourceSnapshotWithCompletionHandler:^(MUKDataSourceSnapshot *snapshot)
            {
                if ([strongContentLoading.dataSource shouldBeRestoredWithSnapshot:snapshot])
                {
                    [strongContentLoading finishWithResultType:snapshot.equivalentResultType error:nil update:^
                    {
                        [strongContentLoading.dataSource restoreFromSnapshot:snapshot];
                    }];
                }
                else {
                    // Load from remote if snapshot is not valid
                    [Florist flowersFromIndex:0 count:kCount completion:^(NSArray *flowers, NSError *error)
                    {
                        MUKDataSourceContentLoadingResultType resultType = resultTypeForResults(flowers);
                        [strongContentLoading finishWithResultType:resultType error:error update:^
                        {
                            strongSelf.flowerListDataSource.items = flowers;
                        }];
                     }];
                }
            }];
        }; // job
    }
    else if ([state isEqualToString:MUKDataSourceContentLoadStateRefreshing]) {
        contentLoading.job = ^{
            RemoteFlowersDataSource *strongSelf = weakSelf;
            MUKDataSourceContentLoading *strongContentLoading = weakContentLoading;

            [Florist flowersFromIndex:0 count:kCount completion:^(NSArray *flowers, NSError *error)
            {
                MUKDataSourceContentLoadingResultType resultType = resultTypeForResults(flowers);
                
#if DEBUG_SIMULATE_EMPTY_ON_REFRESH
                flowers = @[];
                resultType = MUKDataSourceContentLoadingResultTypeEmpty;
#endif
                
                [strongContentLoading finishWithResultType:resultType error:error update:^
                {
                    strongSelf.flowerListDataSource.items = flowers;
                }];
            }];
        }; // job
    }
    else if ([state isEqualToString:MUKDataSourceContentLoadStateAppending]) {
        contentLoading.job = ^{
            RemoteFlowersDataSource *strongSelf = weakSelf;
            MUKDataSourceContentLoading *strongContentLoading = weakContentLoading;

            [Florist flowersFromIndex:[strongSelf.flowerListDataSource.items count] count:kCount completion:^(NSArray *flowers, NSError *error)
            {
                if (strongContentLoading.isValid) {
                    MUKDataSourceContentLoadingResultType resultType = resultTypeForResults(flowers);
                    [strongContentLoading finishWithResultType:resultType error:error update:^
                    {
                        NSMutableArray *proxy = [strongSelf.flowerListDataSource mutableArrayValueForKey:@"items"];
                        [proxy addObjectsFromArray:flowers];
                    }];
                }
            }];
        }; // job
    }
    else {
        contentLoading = nil;
    }
    
    return contentLoading;
}

- (void)willLoadContent:(MUKDataSourceContentLoading *)contentLoading {
    [super willLoadContent:contentLoading];
    [self adjustPlaceholderDataSourceStartingContentLoading:contentLoading];
    [self adjustAppendContentDataSourceStartingContentLoading:contentLoading];
}

- (void)didLoadContent:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error
{
    [self adjustPlaceholderDataSourceFinishingContentLoading:contentLoading withResultType:resultType error:error];
    [self adjustAppendContentDataSourceFinishingContentLoading:contentLoading withResultType:resultType error:error];
    
    // Called at bottom because, here, we are finishing completed loading (affecting
    // child data source with a supplementary update). This way, delegate is invoked
    // when we are really done
    [super didLoadContent:contentLoading withResultType:resultType error:error];
    
    // Cache snapshot
    MUKDataSourceSnapshot *snapshot = [self newSnapshot];
    [self cacheDataSourceSnapshot:snapshot completion:nil];
}

#pragma mark - Private

- (void)createAllChildDataSources {
    FlowerListDataSource *flowerListDataSource = [[FlowerListDataSource alloc] init];
    AppendContentDataSource *appendDataSource = [[AppendContentDataSource alloc] init];
    MUKPlaceholderDataSource *placeholderDataSource = [[MUKPlaceholderDataSource alloc] init];
    self.childDataSources = @[placeholderDataSource, flowerListDataSource, appendDataSource];
}

- (void)adjustPlaceholderDataSourceStartingContentLoading:(MUKDataSourceContentLoading *)contentLoading
{
    if ([self.loadingState isEqualToString:MUKDataSourceContentLoadStateLoading]) {
        // First load
        [self showPlaceholderDataSourceWithTitle:@"Empty" text:@"Contents are loading right now" image:nil];
    }
}

- (void)adjustAppendContentDataSourceStartingContentLoading:(MUKDataSourceContentLoading *)contentLoading
{
    if ([MUKAppendContentDataSource shouldTypicallyHideWhenWillLoadContent:contentLoading])
    {
        self.appendDataSource.hidden = YES;
    }
    else {
        self.appendDataSource.title = @"Loading...";
        self.appendDataSource.showsActivityIndicator = YES;
        self.appendDataSource.hidden = NO;
    }
}

- (void)adjustPlaceholderDataSourceFinishingContentLoading:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error
{
    if ([self.loadingState isEqualToString:MUKDataSourceContentLoadStateEmpty] ||
        [self.loadingState isEqualToString:MUKDataSourceContentLoadStateError])
    {
        [self showPlaceholderDataSourceWithTitle:([self.loadingState isEqualToString:MUKDataSourceContentLoadStateError] ? @"Error" : @"Empty") text:([error localizedDescription] ?: @"No Contents Found") image:[UIImage imageNamed:@"alert"]];
    }
    else {
        self.placeholderDataSource.hidden = YES;
    }
}

- (void)showPlaceholderDataSourceWithTitle:(NSString *)title text:(NSString *)text image:(UIImage *)image
{
    self.placeholderDataSource.title = title;
    self.placeholderDataSource.text = text;
    self.placeholderDataSource.image = image;
    self.placeholderDataSource.hidden = NO;
}

- (void)adjustAppendContentDataSourceFinishingContentLoading:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error
{
    if ([MUKAppendContentDataSource shouldTypicallyHideWhenDidLoadContent:contentLoading withResultType:resultType])
    {
        self.appendDataSource.hidden = YES;
    }
    else {
        self.appendDataSource.title = @"Show More Flowers";
        self.appendDataSource.showsActivityIndicator = NO;
        self.appendDataSource.hidden = NO;
    }
}

- (NSURL *)cachedDataSourceSnapshotFileURL {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[NSURL fileURLWithPath:[paths firstObject]] URLByAppendingPathComponent:@"RemoteFlowersDataSource.snapshot"];
}

- (void)loadCachedDataSourceSnapshotWithCompletionHandler:(void (^)(MUKDataSourceSnapshot *))completionHandler
{
    if (!completionHandler) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSString *path = [[self cachedDataSourceSnapshotFileURL] path];
        MUKDataSourceSnapshot *snapshot = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(snapshot);
        });
    });
}

- (void)cacheDataSourceSnapshot:(MUKDataSourceSnapshot *)snapshot completion:(void (^)(BOOL))completionHandler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSString *path = [[self cachedDataSourceSnapshotFileURL] path];
        BOOL success = [NSKeyedArchiver archiveRootObject:snapshot toFile:path];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler) {
                completionHandler(success);
            }
        });
    });
}

@end
