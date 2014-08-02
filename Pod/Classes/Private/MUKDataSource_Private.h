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
- (MUKDataSource *)childDataSourceAtIndex:(NSInteger)idx;

- (void)moveItemAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
- (void)removeItemAtIndex:(NSInteger)idx eventOrigin:(MUKDataSourceEventOrigin)eventOrigin;
@end
