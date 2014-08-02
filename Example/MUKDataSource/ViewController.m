//
//  MUKViewController.m
//  MUKDataSource
//
//  Created by Muccy on 08/01/2014.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "ViewController.h"
#import "DataSource.h"

@interface ViewController () <MUKDataSourceDelegate>
@property (nonatomic) DataSource *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.dataSource = [self newDataSource];
    [self.dataSource registerReusableViewsForTableView:self.tableView];
    self.tableView.dataSource = self.dataSource;
}

#pragma mark - Overrides

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    for (DataSource *sectionDataSource in self.dataSource.childDataSources) {
        sectionDataSource.editing = editing;
    }
}

#pragma mark - Private

- (DataSource *)newDataSource {
    DataSource *dataSource = [[DataSource alloc] init];
    dataSource.delegate = self;
    
    DataSource *insectsDataSource = [[DataSource alloc] init];
    insectsDataSource.title = @"Insects";
    insectsDataSource.items = @[ @"Spider", @"Fly" ];
    [dataSource addChildDataSource:insectsDataSource];
    
    DataSource *otherAnimalsDataSource = [[DataSource alloc] init];
    otherAnimalsDataSource.title = @"Other Animals";
    otherAnimalsDataSource.items = @[ @"Cat", @"Dog", @"Pig", @"Horse" ];
    [dataSource addChildDataSource:otherAnimalsDataSource];
    
    return dataSource;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MUKDataSource *dataSource = (MUKDataSource *)tableView.dataSource;
    NSIndexPath *itemIndexPath = [dataSource itemIndexPathFromTableViewIndexPath:indexPath checkingBounds:YES];
    NSString *name = [dataSource itemAtIndexPath:itemIndexPath];
    NSLog(@"%@", name);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == 0 ? UITableViewCellEditingStyleInsert : UITableViewCellEditingStyleDelete;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    NSIndexPath *indexPath;
    
    if (proposedDestinationIndexPath.row < 1) {
        indexPath = [NSIndexPath indexPathForRow:1 inSection:proposedDestinationIndexPath.section];
    }
    else {
        indexPath = proposedDestinationIndexPath;
    }
    
    return indexPath;
}

#pragma mark - <MUKDataSourceDelegate>

- (void)dataSource:(MUKDataSource *)dataSource didMoveItemFromDataSource:(MUKDataSource *)sourceDataSource atIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    if (eventOrigin != MUKDataSourceEventOriginUserInteraction) {
        [self.tableView moveRowAtIndexPath:[dataSource tableViewIndexPathFromItemIndex:sourceIndex checkingBounds:YES] toIndexPath:[dataSource tableViewIndexPathFromItemIndex:destinationIndex checkingBounds:YES]];
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didRemoveItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)originatingDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    NSArray *indexPaths = [originatingDataSource tableViewIndexPathsFromItemIndexes:indexes checkingBounds:NO];
    if ([indexPaths count] == [items count]) {
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didInsertItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)targetDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    NSArray *indexPaths = [targetDataSource tableViewIndexPathsFromItemIndexes:indexes checkingBounds:NO];
    if ([indexPaths count] == [items count]) {
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
