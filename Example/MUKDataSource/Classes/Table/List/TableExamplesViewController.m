//
//  TableExamplesViewController.m
//  MUKDataSource
//
//  Created by Marco on 14/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "TableExamplesViewController.h"
#import "TableExamplesDataSource.h"
#import "TableExample.h"
#import "TableExampleViewController.h"
#import "Playground.h"
#import "TablePlaygroundViewController.h"

static NSString *const kShowExampleSegueIdentifier = @"Show Example";
static NSString *const kShowPlaygroundSegueIdentifier = @"Show Playground";

@interface TableExamplesViewController ()
@end

@implementation TableExamplesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [[TableExamplesDataSource alloc] init];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:kShowExampleSegueIdentifier]) {
        UITableViewCell *const cell = sender;
        NSIndexPath *const indexPath = [self.tableView indexPathForCell:cell];
        TableExampleViewController *const viewController = segue.destinationViewController;
        viewController.example = [self.dataSource tableRowItemAtIndexPath:indexPath];
    }
    else if ([segue.identifier isEqualToString:kShowPlaygroundSegueIdentifier]) {
        UITableViewCell *const cell = sender;
        NSIndexPath *const indexPath = [self.tableView indexPathForCell:cell];
        TablePlaygroundViewController *const viewController = segue.destinationViewController;
        viewController.playground = [self.dataSource tableRowItemAtIndexPath:indexPath];
    }
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MUKDataSourceIdentifiable> item = [self.dataSource tableRowItemAtIndexPath:indexPath];
    
    if ([item isKindOfClass:[TableExample class]]) {
        [self performSegueWithIdentifier:kShowExampleSegueIdentifier sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
    else if ([item isKindOfClass:[Playground class]]) {
        [self performSegueWithIdentifier:kShowPlaygroundSegueIdentifier sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
}

@end
