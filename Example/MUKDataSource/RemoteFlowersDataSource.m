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

    if ([state isEqualToString:MUKDataSourceContentLoadStateLoading] ||
        [state isEqualToString:MUKDataSourceContentLoadStateRefreshing])
    {
        contentLoading.job = ^{
            [Florist flowersFromIndex:0 count:kCount completion:^(NSArray *flowers, NSError *error)
            {
                MUKDataSourceContentLoading *strongContentLoading = weakContentLoading;
                
                if (strongContentLoading && !strongContentLoading.isCancelled) {
                    [strongContentLoading finishWithResultType:MUKDataSourceContentLoadingResultTypeDone error:nil update:^
                    {
                        [[self childDataSourceAtIndex:0] setItems:flowers animated:YES];
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
                    [strongContentLoading finishWithResultType:MUKDataSourceContentLoadingResultTypeDone error:nil update:^
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

@end
