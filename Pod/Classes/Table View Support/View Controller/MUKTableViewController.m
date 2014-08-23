#import "MUKTableViewController.h"

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

@interface MUKTableViewController ()
@property (nonatomic) BOOL alreadySetFirstNeedLoadContent;
@property (nonatomic) BOOL automaticallyAdjustsSeparatorStyleForPlaceholder;
@end

@implementation MUKTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.usesRefreshControl) {
        [self insertRefreshControl];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.alreadySetFirstNeedLoadContent) {
        self.alreadySetFirstNeedLoadContent = YES; // Consume the chance
        
        if (self.automaticallySetNeedsLoadContentAtViewWillAppear) {
            [self.dataSource setNeedsLoadContent];
        }
    }
}

#pragma mark - Accessors

- (void)setDataSource:(MUKDataSource *)dataSource {
    if (dataSource != _dataSource) {
        if (_dataSource.delegate == self) {
            _dataSource.delegate = nil;
        }
        
        _dataSource = dataSource;
        dataSource.delegate = self;
        self.tableView.dataSource = dataSource;
        [dataSource registerReusableViewsForTableView:self.tableView];
    }
}

- (void)setUsesRefreshControl:(BOOL)usesRefreshControl {
    if (usesRefreshControl != _usesRefreshControl) {
        _usesRefreshControl = usesRefreshControl;
        
        if (usesRefreshControl) {
            [self insertRefreshControl];
        }
        else {
            self.refreshControl = nil;
        }
    }
}

#pragma mark - Row Animation

- (UITableViewRowAnimation)rowAnimationToInsertSections:(NSIndexSet *)sections forChildDataSourcesAtIndexes:(NSIndexSet *)indexes
{
    return UITableViewRowAnimationAutomatic;
}

- (UITableViewRowAnimation)rowAnimationToDeleteSections:(NSIndexSet *)sections forChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes
{
    return UITableViewRowAnimationAutomatic;
}

- (UITableViewRowAnimation)rowAnimationToReloadSections:(NSIndexSet *)sections toReplaceChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes
{
    return UITableViewRowAnimationAutomatic;
}

- (UITableViewRowAnimation)rowAnimationToReloadSection:(NSInteger)section toRefreshChildDataSourcesAtIndex:(NSInteger)idx
{
    return UITableViewRowAnimationAutomatic;
}


- (UITableViewRowAnimation)rowAnimationToInsertRowsAtIndexPaths:(NSArray *)indexPaths forItemsAtIndexes:(NSIndexSet *)indexes inChildDataSource:(MUKDataSource *)dataSource
{
    return UITableViewRowAnimationAutomatic;
}

- (UITableViewRowAnimation)rowAnimationToDeleteRowsAtIndexPaths:(NSArray *)indexPaths forItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes inChildDataSource:(MUKDataSource *)dataSource
{
    return UITableViewRowAnimationAutomatic;
}

- (UITableViewRowAnimation)rowAnimationToReloadRowsAtIndexPaths:(NSArray *)indexPaths toReplaceItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)dataSource
{
    return UITableViewRowAnimationAutomatic;
}

#pragma mark - Placeholder

- (CGFloat)heightForPlaceholderDataSource:(MUKPlaceholderDataSource *)dataSource rowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = CGRectGetHeight(self.tableView.bounds) - self.tableView.contentInset.top;
    
    if (self.refreshControl && !self.refreshControl.isRefreshing) {
        height -= self.tableView.contentInset.bottom;
    }
    
    return height;
}

#pragma mark - Private

static void CommonInit(MUKTableViewController *me) {
    me->_automaticallySetNeedsLoadContentAtViewWillAppear = YES;
    me->_usesRefreshControl = YES;
    me->_automaticallyAdjustsSeparatorStyleForPlaceholder = YES;
}

- (void)insertRefreshControl {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

static inline BOOL IsBackedTableView(UITableView *tableView, MUKTableViewController *me)
{
    return tableView.dataSource == me.dataSource;
}

#pragma mark - Private — Actions

- (void)refreshControlValueChanged:(id)sender {
    [self.dataSource setNeedsLoadContent];
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IsBackedTableView(tableView, self)) {
        NSInteger const dataSourceIndex = [self.dataSource childDataSourceIndexFromTableViewSection:indexPath.section checkingBounds:YES];
        
        if ([[self.dataSource childDataSourceAtIndex:dataSourceIndex] isKindOfClass:[MUKAppendContentDataSource class]])
        {
            [self.dataSource setNeedsAppendContent];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    
    if (IsBackedTableView(tableView, self)) {
        NSInteger const dataSourceIndex = [self.dataSource childDataSourceIndexFromTableViewSection:indexPath.section checkingBounds:YES];
        MUKDataSource *const dataSource = [self.dataSource childDataSourceAtIndex:dataSourceIndex];
        
        if ([dataSource isKindOfClass:[MUKPlaceholderDataSource class]]) {
            height = [self heightForPlaceholderDataSource:(MUKPlaceholderDataSource *)dataSource rowAtIndexPath:indexPath];
        }
        else {
            height = tableView.rowHeight;
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
    NSIndexSet *const sections = [targetDataSource tableViewSectionsFromChildDataSourceIndexes:indexes checkingBounds:NO];
    
    if ([sections count] == [indexes count]) {
#if DEBUG_LOG
        NSLog(@"• Table View • Insert sections: %@", PrettyIndexSet(sections));
#endif
        [dataSource registerReusableViewsForTableView:self.tableView];
        
        UITableViewRowAnimation rowAnimation = [self rowAnimationToInsertSections:sections forChildDataSourcesAtIndexes:indexes];
        [self.tableView insertSections:sections withRowAnimation:rowAnimation];
    }
    
    if (self.automaticallyAdjustsSeparatorStyleForPlaceholder) {
        self.tableView.separatorStyle = dataSource.isDisplayingPlaceholderDataSource ? UITableViewCellSeparatorStyleNone : UITableViewCellSeparatorStyleSingleLine;
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didRemoveChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)originatingDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    NSIndexSet *const sections = [originatingDataSource tableViewSectionsFromChildDataSourceIndexes:indexes checkingBounds:NO];
    
    if ([sections count] == [indexes count]) {
#if DEBUG_LOG
        NSLog(@"• Table View • Remove sections: %@", PrettyIndexSet(sections));
#endif
        UITableViewRowAnimation rowAnimation = [self rowAnimationToDeleteSections:sections forChildDataSources:childDataSources atIndexes:indexes];
        [self.tableView deleteSections:sections withRowAnimation:rowAnimation];
    }
    
    if (self.automaticallyAdjustsSeparatorStyleForPlaceholder) {
        self.tableView.separatorStyle = dataSource.isDisplayingPlaceholderDataSource ? UITableViewCellSeparatorStyleNone : UITableViewCellSeparatorStyleSingleLine;
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didReplaceChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)originatingDataSource
{
    NSIndexSet *const sections = [originatingDataSource tableViewSectionsFromChildDataSourceIndexes:indexes checkingBounds:NO];
    
    if ([sections count] == [indexes count]) {
#if DEBUG_LOG
        NSLog(@"• Table View • Replace sections: %@", PrettyIndexSet(sections));
#endif
        UITableViewRowAnimation rowAnimation = [self rowAnimationToReloadSections:sections toReplaceChildDataSources:childDataSources atIndexes:indexes];
        [self.tableView reloadSections:sections withRowAnimation:rowAnimation];
    }
    
    if (self.automaticallyAdjustsSeparatorStyleForPlaceholder) {
        self.tableView.separatorStyle = dataSource.isDisplayingPlaceholderDataSource ? UITableViewCellSeparatorStyleNone : UITableViewCellSeparatorStyleSingleLine;
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

- (void)dataSource:(MUKDataSource *)dataSource didRefreshChildDataSourceAtIndex:(NSInteger)idx inDataSource:(MUKDataSource *)originatingDataSource
{
    NSInteger const section = [originatingDataSource tableViewSectionFromChildDataSourceIndex:idx checkingBounds:NO];
    
    if (section != NSNotFound) {
#if DEBUG_LOG
        NSLog(@"• Table View • Refresh section: %ld", section);
#endif
        UITableViewRowAnimation rowAnimation = [self rowAnimationToReloadSection:section toRefreshChildDataSourcesAtIndex:idx];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:idx] withRowAnimation:rowAnimation];
    }
    
    if (self.automaticallyAdjustsSeparatorStyleForPlaceholder) {
        self.tableView.separatorStyle = dataSource.isDisplayingPlaceholderDataSource ? UITableViewCellSeparatorStyleNone : UITableViewCellSeparatorStyleSingleLine;
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didReloadDataInDataSource:(MUKDataSource *)originatingDataSource
{
#if DEBUG_LOG
    NSLog(@"• Table View • Reload data");
#endif
    
    [dataSource registerReusableViewsForTableView:self.tableView];
    [self.tableView reloadData];
    
    if (self.automaticallyAdjustsSeparatorStyleForPlaceholder) {
        self.tableView.separatorStyle = dataSource.isDisplayingPlaceholderDataSource ? UITableViewCellSeparatorStyleNone : UITableViewCellSeparatorStyleSingleLine;
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didInsertItemsAtIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)targetDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    NSArray *const indexPaths = [targetDataSource tableViewIndexPathsFromItemIndexes:indexes checkingBounds:NO];
    if ([indexPaths count] == [indexes count]) {
#if DEBUG_LOG
        NSLog(@"• Table View • Insert rows: %@", PrettyIndexPaths(indexPaths));
#endif
        UITableViewRowAnimation rowAnimation = [self rowAnimationToInsertRowsAtIndexPaths:indexPaths forItemsAtIndexes:indexes inChildDataSource:targetDataSource];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:rowAnimation];
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didRemoveItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)originatingDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    NSArray *const indexPaths = [originatingDataSource tableViewIndexPathsFromItemIndexes:indexes checkingBounds:NO];
    if ([indexPaths count] == [items count]) {
#if DEBUG_LOG
        NSLog(@"• Table View • Delete rows: %@", PrettyIndexPaths(indexPaths));
#endif
        UITableViewRowAnimation rowAnimation = [self rowAnimationToDeleteRowsAtIndexPaths:indexPaths forItems:items atIndexes:indexes inChildDataSource:originatingDataSource];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:rowAnimation];
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didReplaceItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)originatingDataSource
{
    NSArray *const indexPaths = [originatingDataSource tableViewIndexPathsFromItemIndexes:indexes checkingBounds:NO];
    if ([indexPaths count] == [items count]) {
#if DEBUG_LOG
        NSLog(@"• Table View • Reload rows: %@", PrettyIndexPaths(indexPaths));
#endif
        UITableViewRowAnimation rowAnimation = [self rowAnimationToReloadRowsAtIndexPaths:indexPaths toReplaceItems:items atIndexes:indexes inDataSource:originatingDataSource];
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:rowAnimation];
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
    
    if (isRefreshing && self.refreshControl && !self.refreshControl.isRefreshing)
    {
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
}

@end
