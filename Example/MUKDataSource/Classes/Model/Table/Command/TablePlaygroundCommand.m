//
//  TablePlaygroundCommand.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TablePlaygroundCommand.h"

@implementation TablePlaygroundCommand

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title editingStyle:(UITableViewCellEditingStyle)editingStyle action:(TablePlaygroundCommandAction)action
{
    self = [super initWithIdentifier:identifier title:title];
    if (self) {
        _editingStyle = editingStyle;
        _action = [action copy];
    }
    
    return self;
}

- (BOOL)isEqualToTablePlaygroundCommand:(TablePlaygroundCommand *)command {
    return [self isEqualToItem:command] && self.editingStyle == command.editingStyle;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        return [self isEqualToTablePlaygroundCommand:object];
    }
    
    return NO;
}

- (NSUInteger)hash {
    return [super hash] ^ self.editingStyle;
}

@end
