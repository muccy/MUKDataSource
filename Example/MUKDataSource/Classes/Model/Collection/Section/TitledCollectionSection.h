//
//  CollectionSection.h
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "MUKDataSourceCollectionSection.h"

@interface TitledCollectionSection : MUKDataSourceCollectionSection
@property (nonatomic, readonly, copy) NSString *title;
- (instancetype)initWithIdentifier:(id<NSCopying>)identifier items:(NSArray *)items title:(NSString *)title;
- (BOOL)isEqualToTitledCollectionSection:(TitledCollectionSection *)section;
@end
