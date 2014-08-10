//
//  DataSource.h
//  MUKDataSource
//
//  Created by Marco on 01/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import <MUKDataSource/MUKDataSource.h>

@interface AnimalsDataSource : MUKDataSource
@property (nonatomic) BOOL editing;
@property (nonatomic, copy) NSString *identifier;
@end