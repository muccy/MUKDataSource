//
//  TableExample.h
//  MUKDataSource
//
//  Created by Marco on 14/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSource.h>

@interface TableExample : NSObject <MUKDataSourceIdentifiable>
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSArray *sourceTableSections, *destinationTableSections;

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title sourceTableSections:(NSArray *)sourceTableSections destinationTableSections:(NSArray *)destinationTableSections;
@end
