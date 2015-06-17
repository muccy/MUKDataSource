//
//  SectionedContentExamplesViewController.m
//  MUKDataSource
//
//  Created by Marco on 17/06/15.
//  Copyright (c) 2015 MUKit. All rights reserved.
//

#import "SectionedContentExamplesViewController.h"
#import "SectionedContentExamplesDataSource.h"
#import "SectionedContentExample.h"
#import "ExampleViewController.h"

static NSString *const kShowExampleSegueIdentifier = @"Show Example";

@interface SectionedContentExamplesViewController ()
@end

@implementation SectionedContentExamplesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [self newDataSource];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        UITableViewCell *const cell = sender;
        NSIndexPath *const indexPath = [self.tableView indexPathForCell:cell];
        
        id<MUKDataSourceIdentifiable> const item = [self.dataSource itemAtIndexPath:indexPath];
        if ([item isKindOfClass:[Example class]]) {
            id<ExampleViewController> const viewController = segue.destinationViewController;
            viewController.example = item;
        }
    }
}

- (SectionedContentExamplesDataSource *)newDataSource {
    return [[SectionedContentExamplesDataSource alloc] init];
}

- (NSString *)segueIdentifierForSelectedExample:(id)example {
    return nil;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Example *const example = [self.dataSource itemAtIndexPath:indexPath];
    NSString *const segueIdentifier = [self segueIdentifierForSelectedExample:example];
    
    if (segueIdentifier) {
        [self performSegueWithIdentifier:segueIdentifier sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
}

@end
