//
//  TableViewController.m
//  MUKDataSource
//
//  Created by Marco on 09/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "TableViewController.h"

#define DEBUG_LOG   0

#if DEBUG_LOG
static inline NSString *PrettyIndexPath(NSIndexPath *indexPath) {
    return indexPath ? [NSString stringWithFormat:@"(%ld, %ld)", (long)indexPath.section, (long)indexPath.row] : @"(-, -)";
}

static NSString *PrettyIndexPaths(NSArray *indexPaths) {
    NSMutableArray *components = [[NSMutableArray alloc] initWithCapacity:[indexPaths count]];
    
    for (NSIndexPath *indexPath in indexPaths) {
        [components addObject:PrettyIndexPath(indexPath)];
    } // for
    
    if ([components count] == 0) {
        [components addObject:PrettyIndexPath(nil)];
    }
    
    return [NSString stringWithFormat:@"[%@]", [components componentsJoinedByString:@", "]];
}

static NSString *PrettyIndexSet(NSIndexSet *indexSet) {
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    NSUInteger const lastIndex = [indexSet lastIndex];
    
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [mutableString appendFormat:@"%lu", (unsigned long)idx];
        
        if (idx != lastIndex) {
            [mutableString appendString:@", "];
        }
    }];
    
    return [mutableString copy];
}
#endif

@interface TableViewController ()
@property (nonatomic, readwrite) MUKDataSource *dataSource;
@property (nonatomic) BOOL alreadySetNeedLoadContent;
@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [self newDataSource];
    [self.dataSource registerReusableViewsForTableView:self.tableView];
    self.tableView.dataSource = self.dataSource;
    self.dataSource.delegate = self;
    
    if ([self usesRefreshControl]) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.alreadySetNeedLoadContent && self.refreshControl) {
        self.alreadySetNeedLoadContent = YES;
        [self.dataSource setNeedsLoadContent];
    }
}

#pragma mark - Methods

- (MUKDataSource *)newDataSource {
    return nil;
}

- (BOOL)usesRefreshControl {
    return NO;
}

#pragma mark - Actions

- (void)refreshControlValueChanged:(id)sender {
    [self.dataSource setNeedsLoadContent];
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger dataSourceIndex = [self.dataSource childDataSourceIndexFromTableViewSection:indexPath.section checkingBounds:YES];
    if ([[self.dataSource childDataSourceAtIndex:dataSourceIndex] isKindOfClass:[MUKAppendContentDataSource class]])
    {
        [self.dataSource setNeedsAppendContent];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    
    NSInteger dataSourceIndex = [self.dataSource childDataSourceIndexFromTableViewSection:indexPath.section checkingBounds:YES];
    if ([[self.dataSource childDataSourceAtIndex:dataSourceIndex] isKindOfClass:[MUKPlaceholderDataSource class]])
    {
        height = CGRectGetHeight(tableView.bounds) - tableView.contentInset.top;
        
        if (!self.refreshControl.isRefreshing) {
            height -= tableView.contentInset.bottom;
        }
    }
    else {
        height = tableView.rowHeight;
    }
    
    return height;
}

#pragma mark - <MUKDataSourceDelegate>

- (void)dataSource:(MUKDataSource *)dataSource didInsertChildDataSourcesAtIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)targetDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    NSIndexSet *sections = [targetDataSource tableViewSectionsFromChildDataSourceIndexes:indexes checkingBounds:NO];
    
    if ([sections count] == [indexes count]) {
#if DEBUG_LOG
        NSLog(@"• Table View • Insert sections: %@", PrettyIndexSet(sections));
#endif
        [dataSource registerReusableViewsForTableView:self.tableView];
        [self.tableView insertSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didRemoveChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)originatingDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    NSIndexSet *sections = [originatingDataSource tableViewSectionsFromChildDataSourceIndexes:indexes checkingBounds:NO];
    
    if ([sections count] == [indexes count]) {
#if DEBUG_LOG
        NSLog(@"• Table View • Remove sections: %@", PrettyIndexSet(sections));
#endif
        [self.tableView deleteSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didReplaceChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)originatingDataSource
{
    NSIndexSet *sections = [originatingDataSource tableViewSectionsFromChildDataSourceIndexes:indexes checkingBounds:NO];
    
    if ([sections count] == [indexes count]) {
#if DEBUG_LOG
        NSLog(@"• Table View • Replace sections: %@", PrettyIndexSet(sections));
#endif
        [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didMoveChildDataSourceFromDataSource:(MUKDataSource *)sourceDataSource atIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    NSInteger const fromSection = [sourceDataSource tableViewSectionFromChildDataSourceIndex:sourceIndex checkingBounds:NO];
    NSInteger const toSection = [destinationDataSource tableViewSectionFromChildDataSourceIndex:destinationIndex checkingBounds:NO];
    
#if DEBUG_LOG
    NSLog(@"• Table View • Move section: %ld to %ld", fromSection, toSection);
#endif
    [self.tableView moveSection:fromSection toSection:toSection];
}

- (void)dataSource:(MUKDataSource *)dataSource didRefreshChildDataSourcesAtIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)originatingDataSource
{
    NSIndexSet *sections = [originatingDataSource tableViewSectionsFromChildDataSourceIndexes:indexes checkingBounds:NO];
    
    if ([sections count] == [indexes count]) {
#if DEBUG_LOG
        NSLog(@"• Table View • Refresh sections: %@", PrettyIndexSet(sections));
#endif
        [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didReloadDataInDataSource:(MUKDataSource *)originatingDataSource
{
#if DEBUG_LOG
    NSLog(@"• Table View • Reload data");
#endif
    
    [dataSource registerReusableViewsForTableView:self.tableView];
    [self.tableView reloadData];
}

- (void)dataSource:(MUKDataSource *)dataSource didInsertItemsAtIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)targetDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    NSArray *indexPaths = [targetDataSource tableViewIndexPathsFromItemIndexes:indexes checkingBounds:NO];
    if ([indexPaths count] == [indexes count]) {
#if DEBUG_LOG
        NSLog(@"• Table View • Insert rows: %@", PrettyIndexPaths(indexPaths));
#endif
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didRemoveItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)originatingDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    NSArray *indexPaths = [originatingDataSource tableViewIndexPathsFromItemIndexes:indexes checkingBounds:NO];
    if ([indexPaths count] == [items count]) {
#if DEBUG_LOG
        NSLog(@"• Table View • Delete rows: %@", PrettyIndexPaths(indexPaths));
#endif
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didReplaceItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)originatingDataSource
{
    NSArray *indexPaths = [originatingDataSource tableViewIndexPathsFromItemIndexes:indexes checkingBounds:NO];
    if ([indexPaths count] == [items count]) {
#if DEBUG_LOG
        NSLog(@"• Table View • Reload rows: %@", PrettyIndexPaths(indexPaths));
#endif
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didMoveItemFromDataSource:(MUKDataSource *)sourceDataSource atIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    if (eventOrigin != MUKDataSourceEventOriginUserInteraction) {
        NSIndexPath *const fromIndexPath = [sourceDataSource tableViewIndexPathFromItemIndex:sourceIndex checkingBounds:NO];
        NSIndexPath *const toIndexPath = [destinationDataSource tableViewIndexPathFromItemIndex:destinationIndex checkingBounds:NO];
#if DEBUG_LOG
        NSLog(@"• Table View • Move row: %@ to %@", PrettyIndexPath(fromIndexPath), PrettyIndexPath(toIndexPath));
#endif
        [self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didRequestBatchUpdate:(dispatch_block_t)updateBlock fromDataSource:(MUKDataSource *)originatingDataSource
{
#if DEBUG_LOG
    NSLog(@"• Table View • Begin Batch Update");
#endif
    [self.tableView beginUpdates];
    updateBlock();
    [self.tableView endUpdates];
#if DEBUG_LOG
    NSLog(@"• Table View • End Batch Update");
#endif
}

- (void)dataSource:(MUKDataSource *)dataSource willTransitionToContentLoadingState:(NSString *)state inDataSource:(MUKDataSource *)originatingDataSource
{
#if DEBUG_LOG
    NSLog(@"• State Transition • Will: from %@ to %@", originatingDataSource.loadingState, state);
#endif
}

- (void)dataSource:(MUKDataSource *)dataSource didTransitionFromContentLoadingState:(NSString *)state inDataSource:(MUKDataSource *)originatingDataSource
{
#if DEBUG_LOG
    NSLog(@"• State Transition • Did: from %@ to %@", state, originatingDataSource.loadingState);
#endif
}

- (void)dataSource:(MUKDataSource *)dataSource willLoadContent:(MUKDataSourceContentLoading *)contentLoading
{
#if DEBUG_LOG
    NSLog(@"• Content • Will Load");
#endif
    BOOL const isRefreshing = [dataSource.loadingState isEqualToString:MUKDataSourceContentLoadStateLoading] || [dataSource.loadingState isEqualToString:MUKDataSourceContentLoadStateRefreshing];
    
    if (isRefreshing && !self.refreshControl.isRefreshing) {
        [self.refreshControl beginRefreshing];
        CGPoint offset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y - CGRectGetHeight(self.refreshControl.frame));
        [self.tableView setContentOffset:offset animated:YES];
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didLoadContent:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error
{
#if DEBUG_LOG
    NSLog(@"• Content • Did Load");
#endif
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl endRefreshing];
    }
    
    BOOL isDisplayingPlaceholder = NO;
    for (MUKDataSource *childDataSource in self.dataSource.childDataSources) {
        if ([childDataSource isKindOfClass:[MUKPlaceholderDataSource class]]) {
            MUKPlaceholderDataSource *placeholderDataSource = (MUKPlaceholderDataSource *)childDataSource;
            isDisplayingPlaceholder = !placeholderDataSource.isHidden;
            break;
        }
    }
    
    self.tableView.separatorStyle = isDisplayingPlaceholder ? UITableViewCellSeparatorStyleNone : UITableViewCellSeparatorStyleSingleLine;
}

@end
