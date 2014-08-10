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

#define DEBUG_SIMULATE_EMPTY_ON_REFRESH     0

@interface RemoteFlowersDataSource ()
@property (nonatomic, weak) FlowerListDataSource *flowerListDataSource;
@property (nonatomic, weak) MUKAppendContentDataSource *appendDataSource;
@property (nonatomic, weak) MUKPlaceholderDataSource *placeholderDataSource;
@end

@implementation RemoteFlowersDataSource

- (id)init {
    self = [super init];
    if (self) {
        [self createAllChildDataSources];
    }
    
    return self;
}

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

    if ([state isEqualToString:MUKDataSourceContentLoadStateLoading] ||
        [state isEqualToString:MUKDataSourceContentLoadStateRefreshing])
    {
        contentLoading.job = ^{
            RemoteFlowersDataSource *strongSelf = weakSelf;
            MUKDataSourceContentLoading *strongContentLoading = weakContentLoading;

            [Florist flowersFromIndex:0 count:kCount completion:^(NSArray *flowers, NSError *error)
            {
                
                if (strongContentLoading.isValid) {
                    MUKDataSourceContentLoadingResultType resultType = resultTypeForResults(flowers);
                    
#if DEBUG_SIMULATE_EMPTY_ON_REFRESH
                    if ([state isEqualToString:MUKDataSourceContentLoadStateRefreshing])
                    {
                        flowers = @[];
                        resultType = MUKDataSourceContentLoadingResultTypeEmpty;
                    }
#endif
                    
                    [strongContentLoading finishWithResultType:resultType error:error update:^
                    {
                        strongSelf.flowerListDataSource.items = flowers;
                    }];
                }
            }];
        };
    }
    else if ([state isEqualToString:MUKDataSourceContentLoadStateAppending]) {
        contentLoading.job = ^{
            RemoteFlowersDataSource *strongSelf = weakSelf;
            MUKDataSourceContentLoading *strongContentLoading = weakContentLoading;

            [Florist flowersFromIndex:[strongSelf childDataSourcesItemCount] count:kCount completion:^(NSArray *flowers, NSError *error)
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
        };
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
}

#pragma mark - Private

- (void)createAllChildDataSources {
    FlowerListDataSource *flowerListDataSource = [[FlowerListDataSource alloc] init];
    MUKAppendContentDataSource *appendDataSource = [[MUKAppendContentDataSource alloc] init];
    MUKPlaceholderDataSource *placeholderDataSource = [[MUKPlaceholderDataSource alloc] init];
    self.childDataSources = @[placeholderDataSource, flowerListDataSource, appendDataSource];
    
    self.flowerListDataSource = flowerListDataSource;
    self.appendDataSource = appendDataSource;
    self.placeholderDataSource = placeholderDataSource;
    
    MUKDataSourceAppendContentView *appendContentView = (MUKDataSourceAppendContentView *)appendDataSource.appendContentView;
    appendContentView.textLabel.textColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
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
        MUKDataSourceAppendContentView *appendContentView = (MUKDataSourceAppendContentView *)self.appendDataSource.appendContentView;
        appendContentView.textLabel.text = @"Appending...";
        [appendContentView.activityIndicatorView startAnimating];
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
    MUKDataSourcePlaceholderView *placeholderView = (MUKDataSourcePlaceholderView *)self.placeholderDataSource.placeholderView;
    placeholderView.titleLabel.text = title;
    placeholderView.textLabel.text = text;
    placeholderView.imageView.image = image;
    self.placeholderDataSource.hidden = NO;
}

- (void)adjustAppendContentDataSourceFinishingContentLoading:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error
{
    if ([MUKAppendContentDataSource shouldTypicallyHideWhenDidLoadContent:contentLoading withResultType:resultType])
    {
        self.appendDataSource.hidden = YES;
    }
    else {
        MUKDataSourceAppendContentView *appendContentView = (MUKDataSourceAppendContentView *)self.appendDataSource.appendContentView;
        appendContentView.textLabel.text = @"Append More";
        [appendContentView.activityIndicatorView stopAnimating];
        self.appendDataSource.hidden = NO;
    }
}

@end
