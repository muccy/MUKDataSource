//
//  MUKDataSourceCollectionSection.m
//  
//
//  Created by Marco on 16/06/15.
//
//

#import "MUKDataSourceCollectionSection.h"

@implementation MUKDataSourceCollectionSection
@synthesize identifier = _identifier;
@synthesize items = _items;

- (instancetype)initWithIdentifier:(id<NSCopying>)identifier items:(NSArray *)items
{
    self = [super init];
    if (self) {
        _identifier = [(id)identifier copy];
        _items = [items copy];
    }
    
    return self;
}

@end
