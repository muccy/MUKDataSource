//
//  ItemsDataSource.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TitlesDataSource.h"

@implementation TitlesDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const kCellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    
    id<MUKDataSourceIdentifiable> const item = [self itemAtIndexPath:indexPath];
    
    if ([item isKindOfClass:[NSString class]]) {
        cell.textLabel.text = (NSString *)item;
    }
    else if ([item respondsToSelector:@selector(title)]) {
        cell.textLabel.text = [(id)item title];
    }
    
    return cell;
}

@end
