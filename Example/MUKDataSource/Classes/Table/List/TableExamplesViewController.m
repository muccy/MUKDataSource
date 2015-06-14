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

static NSString *const kShowExampleSegueIdentifier = @"Show Example";

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
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:kShowExampleSegueIdentifier sender:[tableView cellForRowAtIndexPath:indexPath]];
}

@end
