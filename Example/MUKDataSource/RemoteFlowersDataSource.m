//
//  RemoteDataSource.m
//  MUKDataSource
//
//  Created by Marco on 08/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "RemoteFlowersDataSource.h"
#import "Florist.h"

@implementation RemoteFlowersDataSource

- (MUKDataSourceContentLoading *)newContentLoadingForState:(NSString *)state {
    static NSInteger const kCount = 20;
    MUKDataSourceContentLoading *contentLoading = [[MUKDataSourceContentLoading alloc] init];
    __weak MUKDataSourceContentLoading *weakContentLoading = contentLoading;
    
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

    if ([state isEqualToString:MUKDataSourceContentLoadStateLoading] ||
        [state isEqualToString:MUKDataSourceContentLoadStateRefreshing])
    {
        contentLoading.job = ^{
            [Florist flowersFromIndex:0 count:kCount completion:^(NSArray *flowers, NSError *error)
            {
                MUKDataSourceContentLoading *strongContentLoading = weakContentLoading;
                
                if (strongContentLoading && !strongContentLoading.isCancelled) {
                    [strongContentLoading finishWithResultType:resultTypeForResults(flowers) error:nil update:^
                    {
                        [[self childDataSourceAtIndex:0] setItems:flowers animated:NO];
                    }];
                }
            }];
        };
    }
    else if ([state isEqualToString:MUKDataSourceContentLoadStateAppending]) {
        contentLoading.job = ^{
            [Florist flowersFromIndex:[self childDataSourcesItemCount] count:kCount completion:^(NSArray *flowers, NSError *error)
            {
                MUKDataSourceContentLoading *strongContentLoading = weakContentLoading;
                
                if (strongContentLoading && !strongContentLoading.isCancelled) {
                    [strongContentLoading finishWithResultType:resultTypeForResults(flowers) error:nil update:^
                    {
                        NSMutableArray *proxy = [[self childDataSourceAtIndex:0] mutableArrayValueForKey:@"items"];
                        [proxy addObjectsFromArray:flowers];
                    }];
                }
            }];
        };
    }
    else {
        contentLoading = nil;
    }
    
    return contentLoading;
}

- (void)willLoadContent:(MUKDataSourceContentLoading *)contentLoading {
    [super willLoadContent:contentLoading];
    
    MUKAppendContentDataSource *appendDataSource = [self.childDataSources lastObject];
    [appendDataSource showAppendingContentIfNeededWithContentLoading:contentLoading animated:NO];
}

- (void)didLoadContent:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error
{
    [super didLoadContent:contentLoading withResultType:resultType error:error];
    
    MUKAppendContentDataSource *appendDataSource = [self.childDataSources lastObject];
    [appendDataSource showCouldAppendContentIfNeededWithContentLoading:contentLoading resultType:resultType animated:NO];
}

@end
