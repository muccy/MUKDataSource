//
//  TableExampleDataSource.m
//  MUKDataSource
//
//  Created by Marco on 14/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TableExampleDataSource.h"
#import "TableExampleItem.h"

@implementation TableExampleDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const kCellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    
    id<MUKDataSourceIdentifiable> const item = [self tableRowItemAtIndexPath:indexPath];
    NSString *itemStringValue;
    
    if ([item isKindOfClass:[NSString class]]) {
        itemStringValue = (NSString *)item;
    }
    else if ([item isKindOfClass:[TableExampleItem class]]) {
        TableExampleItem *const exampleItem = item;
        itemStringValue = exampleItem.title;
    }
    else if ([item respondsToSelector:@selector(stringValue)]) {
        itemStringValue = [(id)item stringValue];
    }
    else if ([item respondsToSelector:@selector(identifier)] &&
             [item.identifier isKindOfClass:[NSString class]])
    {
        itemStringValue = (NSString *)item.identifier;
    }
    else {
        itemStringValue = [item description];
    }
    
    cell.textLabel.text = itemStringValue;
    
    return cell;
}

@end
