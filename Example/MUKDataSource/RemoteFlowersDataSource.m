//
//  RemoteDataSource.m
//  MUKDataSource
//
//  Created by Marco on 08/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "RemoteFlowersDataSource.h"
#import "FlowerListDataSource.h"
#import "AppendContentDataSource.h"
#import "Florist.h"

#define DEBUG_SIMULATE_EMPTY_ON_REFRESH     0

@interface RemoteFlowersDataSource ()
@property (nonatomic, weak) FlowerListDataSource *flowerListDataSource;
@property (nonatomic, weak) AppendContentDataSource *appendDataSource;
@property (nonatomic, weak) MUKPlaceholderDataSource *placeholderDataSource;
@end

@implementation RemoteFlowersDataSource

- (id)init {
    self = [super init];
    if (self) {
        [self showPlaceholderForInitialState:YES error:nil];
    }
    
    return self;
}

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
                
                if (strongContentLoading.isValid) {
                    MUKDataSourceContentLoadingResultType resultType = resultTypeForResults(flowers);
                    
#if DEBUG_SIMULATE_EMPTY_ON_REFRESH
                    if ([state isEqualToString:MUKDataSourceContentLoadStateRefreshing])
                    {
                        resultType = MUKDataSourceContentLoadingResultTypeEmpty;
                    }
#endif
                    
                    [strongContentLoading finishWithResultType:resultType error:error update:^
                    {
                        if (resultType == MUKDataSourceContentLoadingResultTypeComplete ||
                            resultType == MUKDataSourceContentLoadingResultTypePartial)
                        {
                            [self showFlowers:flowers];
                        }
                        else {
                            [self showPlaceholderForInitialState:NO error:error];
                        }
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
                
                if (strongContentLoading.isValid) {
                    [strongContentLoading finishWithResultType:resultTypeForResults(flowers) error:error update:^
                    {
                        [self appendFlowers:flowers];
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
    [self.appendDataSource showAppendingContentIfNeededWithContentLoading:contentLoading animated:NO];
}

- (void)didLoadContent:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error
{
    [super didLoadContent:contentLoading withResultType:resultType error:error];
    [self.appendDataSource showCouldAppendContentIfNeededWithContentLoading:contentLoading resultType:resultType animated:NO];
}

#pragma mark - Private

- (void)prepareContentChildDataSources {
    if (![self.childDataSources containsObject:self.flowerListDataSource]) {
        FlowerListDataSource *flowerListDataSouce = [[FlowerListDataSource alloc] init];
        AppendContentDataSource *appendDataSource = [[AppendContentDataSource alloc] init];
        self.childDataSources = @[flowerListDataSouce, appendDataSource];
        
        self.flowerListDataSource = flowerListDataSouce;
        self.appendDataSource = appendDataSource;
    }
}

- (void)showFlowers:(NSArray *)flowers {
    [self prepareContentChildDataSources];
    [self.flowerListDataSource setItems:flowers animated:NO];
}

- (void)appendFlowers:(NSArray *)flowers {
    [self prepareContentChildDataSources];
    NSMutableArray *proxy = [self.flowerListDataSource mutableArrayValueForKey:@"items"];
    [proxy addObjectsFromArray:flowers];
}

- (void)showPlaceholderForInitialState:(BOOL)initialState error:(NSError *)error {
    if (![self.childDataSources containsObject:self.placeholderDataSource]) {
        MUKPlaceholderDataSource *placeholderDataSource = [[MUKPlaceholderDataSource alloc] init];
        self.childDataSources = @[placeholderDataSource];
        self.placeholderDataSource = placeholderDataSource;
    }
    
    MUKDataSourcePlaceholderView *placeholderView = (MUKDataSourcePlaceholderView *)self.placeholderDataSource.placeholderView;
    placeholderView.imageView.image = [UIImage imageNamed:@"alert"];
    placeholderView.titleLabel.text = error ? @"Error" : @"Empty";
    
    NSString *text;
    if (error) {
        text = [error localizedDescription];
    }
    else if (initialState) {
        text = @"Contents are loading right now";
    }
    else {
        text = @"No Contents Found";
    }

    placeholderView.textLabel.text = text;
}

@end
