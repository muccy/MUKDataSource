//
//  TablePlaygroundCommand.m
//  MUKDataSource
//
//  Created by Marco on 16/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TablePlaygroundCommand.h"

@implementation TablePlaygroundCommand
@synthesize identifier = _identifier;

- (instancetype)initWithIdentifier:(NSString *)identifier title:(NSString *)title editingStyle:(UITableViewCellEditingStyle)editingStyle action:(void (^)(MUKDataSource *, UITableView *))action
{
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
        _title = [title copy];
        _editingStyle = editingStyle;
        _action = [action copy];
    }
    
    return self;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[self class]]) {
        TablePlaygroundCommand *const command = object;
        return [self.identifier isEqual:command.identifier] && [self.title isEqualToString:command.title];
    }
    
    return NO;
}

- (NSUInteger)hash {
    return 74934783 ^ [self.identifier hash] ^ [self.title hash];
}

@end
