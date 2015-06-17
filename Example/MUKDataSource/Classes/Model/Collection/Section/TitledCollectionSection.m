//
//  CollectionSection.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TitledCollectionSection.h"

@implementation TitledCollectionSection

- (instancetype)initWithIdentifier:(id<NSCopying>)identifier items:(NSArray *)items title:(NSString *)title
{
    self = [super initWithIdentifier:identifier items:items];
    if (self) {
        _title = title;
    }
    
    return self;
}

- (BOOL)isEqualToTitledCollectionSection:(TitledCollectionSection *)section {
    if (![self isEqualToDataSourceCollectionSection:section]) {
        return NO;
    }
    
    return (!self.title && !section.title) || [self.title isEqualToString:section.title];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self isEqualToTitledCollectionSection:object];
    }
    
    return NO;
}

- (NSUInteger)hash {
    return [super hash] ^ [self.title hash];
}

@end
