//
//  MUKDataSource_Private.h
//  MUKDataSource
//
//  Created by Marco on 02/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "MUKDataSource_Main.h"

@interface MUKDataSource ()
@property (nonatomic, readonly) BOOL hasChildDataSources;

- (void)moveItemAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)removeItemsAtIndexes:(NSIndexSet *)indexes eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)insertItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)array eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;

@end
