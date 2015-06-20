//
//  TablePlaygroundDataSource.h
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TitlesDataSource.h"

@class TablePlayground;
@interface TablePlaygroundDataSource : TitlesDataSource
@property (nonatomic, readonly) TablePlayground *playground;
- (instancetype)initWithPlayground:(TablePlayground *)playground;
- (NSArray *)originalSections;
@end
