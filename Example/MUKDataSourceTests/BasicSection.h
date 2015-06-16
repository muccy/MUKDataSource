//
//  BasicSection.h
//  MUKDataSource
//
//  Created by Marco on 16/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MUKDataSource/MUKDataSource.h>

@interface BasicSection : NSObject <MUKDataSourceContentSection>
- (instancetype)initWithIdentifier:(NSString *)identifier items:(NSArray *)items;
@end
