//
//  AnimalsTableViewController.m
//  MUKDataSource
//
//  Created by Marco on 09/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "AnimalsTableViewController.h"
#import "AnimalsDataSource.h"

@interface Command : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) dispatch_block_t action;
@end

@implementation Command
@end

static NSString *const kInsectsDataSourceIdentifier = @"kInsectsDataSourceIdentifier";

@interface AnimalsTableViewController () <UIActionSheetDelegate>
@property (nonatomic, copy) NSArray *commands;
@end

@implementation AnimalsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.dataSource = [self newDataSource];
    self.automaticallySetNeedsLoadContentAtViewWillAppear = NO;
    self.usesRefreshControl = NO;
}

#pragma mark - Overrides

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];

    for (AnimalsTableViewController *sectionDataSource in self.dataSource.childDataSources)
    {
        sectionDataSource.editing = editing;
    }
}

- (MUKDataSource *)newDataSource {
    AnimalsDataSource *dataSource = [[AnimalsDataSource alloc] init];
    
    AnimalsDataSource *insectsDataSource = [[AnimalsDataSource alloc] init];
    insectsDataSource.title = @"Insects";
    insectsDataSource.items = @[ @"Spider", @"Fly" ];
    insectsDataSource.identifier = kInsectsDataSourceIdentifier;
    [dataSource appendChildDataSource:insectsDataSource];
    
    AnimalsDataSource *otherAnimalsDataSource = [[AnimalsDataSource alloc] init];
    otherAnimalsDataSource.title = @"Other Animals";
    otherAnimalsDataSource.items = @[ @"Cat", @"Snake", @"Rabbit", @"Dog", @"Pig", @"Camel", @"Horse" ];
    [dataSource appendChildDataSource:otherAnimalsDataSource];
    
    return dataSource;
}

#pragma mark - Actions

- (IBAction)commandsButtonPressed:(id)sender {
    [self setEditing:NO animated:YES];
    
    if (!self.commands) {
        self.commands = [self newCommands];
    }
    
    UIActionSheet *actionSheet = [self newCommandsActionSheet];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

#pragma mark - Private - Commands

- (NSArray *)newCommands {
    NSMutableArray *commands = [[NSMutableArray alloc] init];
    __weak AnimalsTableViewController *weakSelf = self;
    
    Command *command = [[Command alloc] init];
    command.title = @"Uppercase";
    command.action = ^{
        AnimalsTableViewController *strongSelf = weakSelf;
        
        for (AnimalsDataSource *dataSource in strongSelf.dataSource.childDataSources)
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
        AnimalsTableViewController *strongSelf = weakSelf;
        
        for (AnimalsDataSource *dataSource in strongSelf.dataSource.childDataSources)
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
        AnimalsTableViewController *strongSelf = weakSelf;
        
        for (AnimalsDataSource *dataSource in strongSelf.dataSource.childDataSources)
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
        AnimalsTableViewController *strongSelf = weakSelf;
        
        AnimalsDataSource *insectsDataSource = nil;
        for (AnimalsDataSource *dataSource in strongSelf.dataSource.childDataSources)
        {
            if ([dataSource.identifier isEqualToString:kInsectsDataSourceIdentifier])
            {
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
        AnimalsTableViewController *strongSelf = weakSelf;
        
        AnimalsDataSource *insectsDataSource = nil;
        for (AnimalsDataSource *dataSource in strongSelf.dataSource.childDataSources)
        {
            if ([dataSource.identifier isEqualToString:kInsectsDataSourceIdentifier])
            {
                insectsDataSource = dataSource;
                break;
            }
        } // for
        
        [insectsDataSource setItems:@[@"🐛", @"🐝", @"🐜", @"🐞"] animated:YES];
    };
    [commands addObject:command];
    
    command = [[Command alloc] init];
    command.title = @"Flip first two sections";
    command.action = ^{
        AnimalsTableViewController *strongSelf = weakSelf;
        
        if ([strongSelf.dataSource.childDataSources count] < 2) {
            return;
        }
        
        [strongSelf.dataSource moveChildDataSourceAtIndex:1 toDataSource:strongSelf.dataSource atIndex:0];
    };
    [commands addObject:command];
    
    command = [[Command alloc] init];
    command.title = @"Add Fishes";
    command.action = ^{
        AnimalsTableViewController *strongSelf = weakSelf;
        
        AnimalsDataSource *fishesDataSource = [[AnimalsDataSource alloc] init];
        fishesDataSource.title = @"Fishes";
        fishesDataSource.items = @[@"🐠", @"🐟", @"🐳"];
        
        [strongSelf.dataSource insertChildDataSource:fishesDataSource atIndex:1];
    };
    [commands addObject:command];
    
    command = [[Command alloc] init];
    command.title = @"Remove Insects";
    command.action = ^{
        AnimalsTableViewController *strongSelf = weakSelf;
        
        NSInteger insectsIndex = [strongSelf.dataSource.childDataSources indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
        {
            AnimalsDataSource *dataSource = obj;
            if ([dataSource.identifier isEqualToString:kInsectsDataSourceIdentifier])
            {
                *stop = YES;
                return YES;
            }
            
            return NO;
        }];
        
        if (insectsIndex != NSNotFound) {
            [strongSelf.dataSource removeChildDataSourceAtIndex:insectsIndex];
        }
    };
    [commands addObject:command];
    
    command = [[Command alloc] init];
    command.title = @"Restore original table";
    command.action = ^{
        AnimalsTableViewController *strongSelf = weakSelf;
        
        AnimalsDataSource *originalDataSource = (AnimalsDataSource *)[strongSelf newDataSource];
        [strongSelf.dataSource setChildDataSources:originalDataSource.childDataSources animated:YES];
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
    NSIndexPath *itemIndexPath = [self.dataSource itemIndexPathFromTableViewIndexPath:indexPath checkingBounds:YES];
    NSString *name = [self.dataSource itemAtIndexPath:itemIndexPath];
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

@end
