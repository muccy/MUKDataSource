//
//  MUKViewController.m
//  MUKDataSource
//
//  Created by Muccy on 08/01/2014.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "ViewController.h"
#import "DataSource.h"

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
#endif

static NSString *const kInsectsDataSourceIdentifier = @"kInsectsDataSourceIdentifier";

@interface Command : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) dispatch_block_t action;
@end

@implementation Command
@end


@interface ViewController () <MUKDataSourceDelegate, UIActionSheetDelegate>
@property (nonatomic) DataSource *dataSource;
@property (nonatomic, copy) NSArray *commands;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.dataSource = [self newDataSource];
    [self.dataSource registerReusableViewsForTableView:self.tableView];
    self.tableView.dataSource = self.dataSource;
    
    self.commands = [self newCommands];
}

#pragma mark - Overrides

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    for (DataSource *sectionDataSource in self.dataSource.childDataSources) {
        sectionDataSource.editing = editing;
    }
}

#pragma mark - Actions

- (IBAction)commandsButtonPressed:(id)sender {
    [self setEditing:NO animated:YES];
    
    UIActionSheet *actionSheet = [self newCommandsActionSheet];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

#pragma mark - Private

- (DataSource *)newDataSource {
    DataSource *dataSource = [[DataSource alloc] init];
    dataSource.delegate = self;
    
    DataSource *insectsDataSource = [[DataSource alloc] init];
    insectsDataSource.title = @"Insects";
    insectsDataSource.items = @[ @"Spider", @"Fly" ];
    insectsDataSource.userInfo = kInsectsDataSourceIdentifier;
    [dataSource addChildDataSource:insectsDataSource];
    
    DataSource *otherAnimalsDataSource = [[DataSource alloc] init];
    otherAnimalsDataSource.title = @"Other Animals";
    otherAnimalsDataSource.items = @[ @"Cat", @"Snake", @"Rabbit", @"Dog", @"Pig", @"Camel", @"Horse" ];
    [dataSource addChildDataSource:otherAnimalsDataSource];
    
    return dataSource;
}

#pragma mark - Private - Commands

- (NSArray *)newCommands {
    NSMutableArray *commands = [[NSMutableArray alloc] init];
    __weak ViewController *weakSelf = self;
    
    Command *command = [[Command alloc] init];
    command.title = @"Uppercase";
    command.action = ^{
        ViewController *strongSelf = weakSelf;

        for (DataSource *dataSource in strongSelf.dataSource.childDataSources)
        {
            NSMutableArray *uppercaseArray = [[NSMutableArray alloc] initWithCapacity:[dataSource.items count]];
            for (id item in dataSource.items) {
                [uppercaseArray addObject:[item uppercaseString]];
            }
            
            NSMutableArray *proxy = [dataSource mutableArrayValueForKey:@"items"];
            [proxy replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [proxy count])] withObjects:uppercaseArray];
        } // for
    };
    [commands addObject:command];
    
    command = [[Command alloc] init];
    command.title = @"Sort A-Z";
    command.action = ^{
        ViewController *strongSelf = weakSelf;
        
        for (DataSource *dataSource in strongSelf.dataSource.childDataSources)
        {
            NSArray *sortedItems = [dataSource.items sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
            NSMutableArray *proxy = [dataSource mutableArrayValueForKey:@"items"];
            [proxy replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [proxy count])] withObjects:sortedItems];
        } // for
    };
    [commands addObject:command];
    
    command = [[Command alloc] init];
    command.title = @"Remove S-names";
    command.action = ^{
        ViewController *strongSelf = weakSelf;
        
        for (DataSource *dataSource in strongSelf.dataSource.childDataSources)
        {
            NSIndexSet *matchingIndexes = [dataSource.items indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
            {
                return [[obj lowercaseString] hasPrefix:@"s"];
            }];
            
            NSMutableArray *proxy = [dataSource mutableArrayValueForKey:@"items"];
            [proxy removeObjectsAtIndexes:matchingIndexes];
        } // for
    };
    [commands addObject:command];
    
    command = [[Command alloc] init];
    command.title = @"Insert Emoji Insects";
    command.action = ^{
        ViewController *strongSelf = weakSelf;
        
        DataSource *insectsDataSource = nil;
        for (DataSource *dataSource in strongSelf.dataSource.childDataSources) {
            if (dataSource.userInfo == kInsectsDataSourceIdentifier) {
                insectsDataSource = dataSource;
                break;
            }
        } // for
        
        NSMutableArray *proxy = [insectsDataSource mutableArrayValueForKey:@"items"];
        [proxy addObjectsFromArray:@[@"🐛", @"🐝", @"🐜", @"🐞"]];
    };
    [commands addObject:command];
    
    command = [[Command alloc] init];
    command.title = @"Display Only Emoji Insects";
    command.action = ^{
        ViewController *strongSelf = weakSelf;
        
        DataSource *insectsDataSource = nil;
        for (DataSource *dataSource in strongSelf.dataSource.childDataSources) {
            if (dataSource.userInfo == kInsectsDataSourceIdentifier) {
                insectsDataSource = dataSource;
                break;
            }
        } // for
        
        [insectsDataSource setItems:@[@"🐛", @"🐜", @"🐞", @"🐝"] animated:YES];
    };
    [commands addObject:command];
    
    return commands;
}

- (UIActionSheet *)newCommandsActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Commands" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    for (Command *command in self.commands) {
        [actionSheet addButtonWithTitle:command.title];
    } // for
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    
    return actionSheet;
}

#pragma mark - <UIActionSheetDelegate>

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        Command *command = self.commands[buttonIndex];
        if (command.action) {
            command.action();
        }
    }
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
        NSIndexPath *const fromIndexPath = [sourceDataSource tableViewIndexPathFromItemIndex:sourceIndex checkingBounds:NO];
        NSIndexPath *const toIndexPath = [destinationDataSource tableViewIndexPathFromItemIndex:destinationIndex checkingBounds:NO];
#if DEBUG_LOG
        NSLog(@"• Table View • Move %@ to %@", PrettyIndexPath(fromIndexPath), PrettyIndexPath(toIndexPath));
#endif
        [self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didRemoveItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)originatingDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    NSArray *indexPaths = [originatingDataSource tableViewIndexPathsFromItemIndexes:indexes checkingBounds:NO];
    if ([indexPaths count] == [items count]) {
#if DEBUG_LOG
        NSLog(@"• Table View • Delete %@", PrettyIndexPaths(indexPaths));
#endif
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didInsertItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)targetDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    NSArray *indexPaths = [targetDataSource tableViewIndexPathsFromItemIndexes:indexes checkingBounds:NO];
    if ([indexPaths count] == [items count]) {
#if DEBUG_LOG
        NSLog(@"• Table View • Insert %@", PrettyIndexPaths(indexPaths));
#endif
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didReplaceItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes withItems:(NSArray *)newItems inDataSource:(MUKDataSource *)originatingDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    NSArray *indexPaths = [originatingDataSource tableViewIndexPathsFromItemIndexes:indexes checkingBounds:NO];
    if ([indexPaths count] == [items count]) {
#if DEBUG_LOG
        NSLog(@"• Table View • Reload %@", PrettyIndexPaths(indexPaths));
#endif
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)dataSource:(MUKDataSource *)dataSource didRequestBatchUpdate:(dispatch_block_t)updateBlock fromDataSource:(MUKDataSource *)originatingDataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
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

@end
