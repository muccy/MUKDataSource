//
//  MUKDataSource_Private.h
//  MUKDataSource
//
//  Created by Marco on 02/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "MUKDataSource_Main.h"

@class TKStateMachine;
@interface MUKDataSource ()
@property (nonatomic, readonly) BOOL hasChildDataSources;

- (void)moveItemAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)removeItemsAtIndexes:(NSIndexSet *)indexes eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)insertItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;

@property (nonatomic) TKStateMachine *stateMachine;
@property (nonatomic, readwrite) MUKDataSourceContentLoading *currentContentLoading;

- (BOOL)loadContent;
- (BOOL)appendContent;
- (void)didFinishContentLoading:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error update:(dispatch_block_t)updateHandler;

@end
