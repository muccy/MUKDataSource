//
//  CollectionUpdate.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "CollectionUpdate.h"
#import "TitledCollectionSection.h"
#import <MUKArrayDelta/MUKArrayDelta.h>

@implementation CollectionUpdate

- (NSUInteger)reloadedSectionIndexForDelta:(MUKArrayDelta *)delta change:(MUKArrayDeltaMatch *)change
{
    TitledCollectionSection *const sourceSection = delta.sourceArray[change.sourceIndex];
    TitledCollectionSection *const destinationSection = delta.destinationArray[change.destinationIndex];
    
    BOOL const sameTitle = (!destinationSection.title && !sourceSection.title) || [destinationSection.title isEqualToString:sourceSection.title];
    
    if (!sameTitle) {
        return change.destinationIndex;
    }
    
    return NSNotFound;
}

@end
