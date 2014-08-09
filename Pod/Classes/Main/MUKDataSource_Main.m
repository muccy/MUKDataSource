#import "MUKDataSource_Main.h"
#import "MUKDataSource_Private.h"
#import "MUKDataSourceBatch.h"
#import "MUKDataSourceArrayDelta.h"
#import "MUKDataSourceContentLoadState.h"
#import "MUKDataSourceContentLoadEvent.h"
#import "MUKDataSourceContentLoading_Private.h"
#import <TransitionKit/TransitionKit.h>

NSString *const MUKDataSourceContentLoadStateInitial = @"MUKDataSourceContentLoadStateInitial";
NSString *const MUKDataSourceContentLoadStateLoading = @"MUKDataSourceContentLoadStateLoading";
NSString *const MUKDataSourceContentLoadStateRefreshing = @"MUKDataSourceContentLoadStateRefreshing";
NSString *const MUKDataSourceContentLoadStateAppending = @"MUKDataSourceContentLoadStateAppending";
NSString *const MUKDataSourceContentLoadStateLoaded = @"MUKDataSourceContentLoadStateLoaded";
NSString *const MUKDataSourceContentLoadStateEmpty = @"MUKDataSourceContentLoadStateEmpty";
NSString *const MUKDataSourceContentLoadStateError = @"MUKDataSourceContentLoadStateError";

NSString *const MUKDataSourceContentLoadEventBeginLoading = @"MUKDataSourceContentLoadEventBeginLoading";
NSString *const MUKDataSourceContentLoadEventBeginRefreshing = @"MUKDataSourceContentLoadEventBeginRefreshing";
NSString *const MUKDataSourceContentLoadEventBeginAppending = @"MUKDataSourceContentLoadEventBeginAppending";
NSString *const MUKDataSourceContentLoadEventDisplayLoaded = @"MUKDataSourceContentLoadEventDisplayLoaded";
NSString *const MUKDataSourceContentLoadEventDisplayEmpty = @"MUKDataSourceContentLoadEventDisplayEmpty";
NSString *const MUKDataSourceContentLoadEventDisplayError = @"MUKDataSourceContentLoadEventDisplayError";

static NSString *const kStateMachineEventUpdateHandlerUserInfoKey = @"MUKDataSourceStateMachineEventUpdateHandlerUserInfoKey";
static NSString *const kStateMachineEventContentLoadingUserInfoKey = @"MUKDataSourceStateMachineEventContentLoadingUserInfoKey";
static NSString *const kStateMachineEventContentLoadingResultTypeUserInfoKey = @"MUKDataSourceStateMachineEventContentLoadingResultTypeUserInfoKey";
static NSString *const kStateMachineEventErrorUserInfoKey = @"MUKDataSourceStateMachineEventErrorUserInfoKey";

@interface MUKDataSource ()
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, readwrite) NSArray *childDataSources;
@property (nonatomic, weak, readwrite) MUKDataSource *parentDataSource;
@property (nonatomic, readonly) NSString *loadingState;
@end

@implementation MUKDataSource
@dynamic hasChildDataSources;
@dynamic loadingState;

#pragma mark - Accessors

- (TKStateMachine *)stateMachine {
    if (!_stateMachine) {
        _stateMachine = [self newStateMachine];
        [_stateMachine activate];
    }
    
    return _stateMachine;
}

#pragma mark - Methods

- (void)requestBatchUpdate:(dispatch_block_t)updateBlock {
    // Delegate is assigned to perform batch updates: do nothing here
    
    [self didRequestBatchUpdate:updateBlock fromDataSource:self];
}

#pragma mark - self.items KVC compliance

- (NSUInteger)countOfItems {
    return [_items count];
}

- (NSArray *)itemsAtIndexes:(NSIndexSet *)indexes {
    return [_items objectsAtIndexes:indexes];
}

- (void)getItems:(__unsafe_unretained id *)buffer range:(NSRange)inRange {
    return [_items getObjects:buffer range:inRange];
}

- (void)insertItems:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
    [self insertItems:array atIndexes:indexes eventOrigin:MUKDataSourceEventOriginProgrammatic];
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes {
    [self removeItemsAtIndexes:indexes eventOrigin:MUKDataSourceEventOriginProgrammatic];
}

- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)items {
    if (!indexes || [indexes count] != [items count]) {
        return;
    }
    
    NSMutableArray *newItems = [_items mutableCopy];
    NSArray *const oldItems = [_items objectsAtIndexes:indexes];
    [newItems replaceObjectsAtIndexes:indexes withObjects:items];
    
    [self storeItems:newItems emittingKVONotifications:YES];
    
    // Notify
    [self didReplaceItems:oldItems atIndexes:indexes inDataSource:self];
}

#pragma mark - self.childDataSources KVC compliance

- (NSUInteger)countOfChildDataSources {
    return [_childDataSources count];
}

- (NSArray *)childDataSourcesAtIndexes:(NSIndexSet *)indexes {
    return [_childDataSources objectsAtIndexes:indexes];
}

- (void)getChildDataSources:(__unsafe_unretained id *)buffer range:(NSRange)inRange
{
    return [_childDataSources getObjects:buffer range:inRange];
}

- (void)insertChildDataSources:(NSArray *)array atIndexes:(NSIndexSet *)indexes {
    [self insertChildDataSources:array atIndexes:indexes eventOrigin:MUKDataSourceEventOriginProgrammatic];
}

- (void)removeChildDataSourcesAtIndexes:(NSIndexSet *)indexes {
    [self removeChildDataSourcesAtIndexes:indexes eventOrigin:MUKDataSourceEventOriginProgrammatic];
}

- (void)replaceChildDataSourcesAtIndexes:(NSIndexSet *)indexes withChildDataSources:(NSArray *)array
{
    [self replaceChildDataSourcesAtIndexes:indexes withChildDataSources:array eventOrigin:MUKDataSourceEventOriginProgrammatic];
}

#pragma mark - Contents

- (void)setItems:(NSArray *)items {
    [self setItems:items animated:NO];
}

- (void)setItems:(NSArray *)newItems animated:(BOOL)animated {
    if ([_items isEqualToArray:newItems]) {
        return;
    }

    if (!animated) {
        // 1-pass
        [self storeItems:newItems emittingKVONotifications:YES];
        
        // Notify data source refreshed
        NSInteger const idx = [self.parentDataSource.childDataSources indexOfObject:self];
        if (idx != NSNotFound) {
            [self didRefreshChildDataSourcesAtIndexes:[NSIndexSet indexSetWithIndex:idx] inDataSource:self.parentDataSource];
        }
        
        return;
    }
    
    // Animated is way more complicated because I want to notify differences
    // in order to animate them
    
    // Calculate delta
    MUKDataSourceArrayDelta *delta = [[MUKDataSourceArrayDelta alloc] initWithSourceArray:_items destinationArray:newItems];
    
    // Store new items
    [self storeItems:newItems emittingKVONotifications:YES];
    
    // Compose a batch of notifications
    MUKDataSourceBatch *batch = [[MUKDataSourceBatch alloc] init];
    
    // Deletions
    if ([delta.deletedIndexes count] > 0) {
        [batch addBlock:^{
            [self didRemoveItems:delta.deletedObjects atIndexes:delta.deletedIndexes fromDataSource:self eventOrigin:MUKDataSourceEventOriginProgrammatic];
        }];
    }
    
    // Insertions
    if ([delta.insertedIndexes count] > 0) {
        [batch addBlock:^{
            [self didInsertItemsAtIndexes:delta.insertedIndexes toDataSource:self eventOrigin:MUKDataSourceEventOriginProgrammatic];
        }];
    }
    
    // Moves
    [delta enumerateMovementsUsingBlock:^(NSInteger fromIndex, NSInteger toIndex, BOOL *stop)
    {
        // Add move to batch
        [batch addBlock:^{
            [self didMoveItemFromDataSource:self atIndex:fromIndex toDataSource:self atIndex:toIndex eventOrigin:MUKDataSourceEventOriginProgrammatic];
        }];
    }];

    // Request batch update
    [self requestBatchUpdate:^{
        [batch performAllBlocks];
    }];
}

- (id)itemAtIndex:(NSInteger)idx {
    if (idx < 0 || idx >= [self.items count]) {
        return nil;
    }
    
    return self.items[idx];
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return [self itemAtIndexPath:indexPath usingIndexAtPosition:0];
}

- (NSUInteger)childDataSourcesItemCount {
    NSUInteger count = 0;
    
    for (MUKDataSource *childDataSource in self.childDataSources) {
        count += [childDataSource.items count];
    }
    
    return count;
}

- (void)moveItemAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex
{
    [self moveItemAtIndex:sourceIndex toDataSource:destinationDataSource atIndex:destinationIndex eventOrigin:MUKDataSourceEventOriginProgrammatic];
}

- (void)removeItemAtIndex:(NSInteger)idx {
    if (idx >= 0 && idx < NSNotFound) {
        [self removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:idx]];
    }
}

- (void)insertItem:(id)item atIndex:(NSInteger)idx {
    if (!item || idx < 0 || idx >= NSNotFound) {
        return;
    }
    
    [self insertItems:@[item] atIndexes:[NSIndexSet indexSetWithIndex:idx]];
}

- (void)replaceItemAtIndex:(NSInteger)idx withItem:(id)newItem {
    if (!newItem || idx < 0 || idx >= NSNotFound) {
        return;
    }
    
    [self replaceItemsAtIndexes:[NSIndexSet indexSetWithIndex:idx] withItems:@[newItem]];
}

#pragma mark - Containment

- (void)setChildDataSources:(NSArray *)childDataSources {
    [self setChildDataSources:childDataSources animated:NO];
}

- (void)setChildDataSources:(NSArray *)newChildDataSources animated:(BOOL)animated
{
    if ([_childDataSources isEqualToArray:newChildDataSources]) {
        return;
    }
    
    // Duplicate data sources not allowed
    NSSet *newChildDataSourceSet = [[NSSet alloc] initWithArray:newChildDataSources];
    if ([newChildDataSourceSet count] != [newChildDataSources count]) {
        return;
    }
    
    // Ensure they reference to their parent
    [newChildDataSources makeObjectsPerformSelector:@selector(setParentDataSource:) withObject:self];
    
    if (!animated) {
        // 1-pass
        [self storeChildDataSources:newChildDataSources emittingKVONotifications:YES];
        
        // Notify all data changed
        [self didReloadDataInDataSource:self];
        
        return;
    }
    
    // Animated is way more complicated because I want to notify differences
    // in order to animate them
    
    // Calculate delta
    MUKDataSourceArrayDelta *delta = [[MUKDataSourceArrayDelta alloc] initWithSourceArray:_childDataSources destinationArray:newChildDataSources];
    
    // Store new child data sources
    [self storeChildDataSources:newChildDataSources emittingKVONotifications:YES];
    
    // Compose a batch of notifications
    MUKDataSourceBatch *batch = [[MUKDataSourceBatch alloc] init];
    
    // Deletions
    if ([delta.deletedIndexes count] > 0) {
        [batch addBlock:^{
            [self didRemoveChildDataSources:delta.deletedObjects atIndexes:delta.deletedIndexes fromDataSource:self eventOrigin:MUKDataSourceEventOriginProgrammatic];
        }];
    }
    
    // Insertions
    if ([delta.insertedIndexes count] > 0) {
        [batch addBlock:^{
            [self didInsertChildDataSourcesAtIndexes:delta.insertedIndexes toDataSource:self eventOrigin:MUKDataSourceEventOriginProgrammatic];
        }];
    }
    
    // Moves
    [delta enumerateMovementsUsingBlock:^(NSInteger fromIndex, NSInteger toIndex, BOOL *stop)
     {
         // Add move to batch
         [batch addBlock:^{
             [self didMoveChildDataSourceFromDataSource:self atIndex:fromIndex toDataSource:self atIndex:toIndex eventOrigin:MUKDataSourceEventOriginProgrammatic];
         }];
     }];
    
    // Request batch update
    [self requestBatchUpdate:^{
        [batch performAllBlocks];
    }];
}

- (MUKDataSource *)childDataSourceAtIndex:(NSInteger)idx {
    if (idx < 0 || idx >= [self.childDataSources count]) {
        return nil;
    }
    
    return self.childDataSources[idx];
}

- (MUKDataSource *)childDataSourceAtIndexPath:(NSIndexPath *)indexPath {
    return [self childDataSourceAtIndexPath:indexPath usingIndexAtPosition:0];
}

- (void)appendChildDataSource:(MUKDataSource *)dataSource {
    [self insertChildDataSource:dataSource atIndex:[self.childDataSources count]];
}

- (void)insertChildDataSource:(MUKDataSource *)dataSource atIndex:(NSInteger)idx
{
    if (!dataSource || idx < 0 || idx >= NSNotFound) {
        return;
    }
    
    [self insertChildDataSources:@[dataSource] atIndexes:[NSIndexSet indexSetWithIndex:idx]];
}

- (void)removeChildDataSource:(MUKDataSource *)dataSource {
    if (!dataSource) {
        return;
    }
    
    NSInteger idx = [self.childDataSources indexOfObject:dataSource];
    if (idx == NSNotFound) {
        return;
    }
    
    [self removeChildDataSourceAtIndex:idx];
}

- (void)removeChildDataSourceAtIndex:(NSInteger)idx {
    if (idx >= 0 && idx < NSNotFound) {
        [self removeChildDataSourcesAtIndexes:[NSIndexSet indexSetWithIndex:idx]];
    }
}

- (void)replaceChildDataSourceAtIndex:(NSInteger)idx withDataSource:(MUKDataSource *)newDataSource
{
    if (!newDataSource || idx < 0 || idx >= NSNotFound) {
        return;
    }
    
    [self replaceChildDataSourcesAtIndexes:[NSIndexSet indexSetWithIndex:idx] withChildDataSources:@[newDataSource]];
}

- (void)moveChildDataSourceAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex
{
    [self moveChildDataSourceAtIndex:sourceIndex toDataSource:destinationDataSource atIndex:destinationIndex eventOrigin:MUKDataSourceEventOriginProgrammatic];
}

#pragma mark - Content Loading

- (NSString *)loadingState {
    if (!_stateMachine) {
        return MUKDataSourceContentLoadStateInitial;
    }
    
    return self.stateMachine.currentState.name;
}

- (void)setNeedsLoadContent {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadContent) object:nil];
    [self performSelector:@selector(loadContent) withObject:nil afterDelay:0.0];
}

- (void)setNeedsAppendContent {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(appendContent) object:nil];
    [self performSelector:@selector(appendContent) withObject:nil afterDelay:0.0];
}

- (MUKDataSourceContentLoading *)newContentLoadingForState:(NSString *)state {
    return nil;
}

#pragma mark - Callbacks

- (void)didInsertChildDataSourcesAtIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    // Notify upwards
    [self.parentDataSource didInsertChildDataSourcesAtIndexes:indexes toDataSource:dataSource eventOrigin:eventOrigin];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didInsertChildDataSourcesAtIndexes:toDataSource:eventOrigin:)])
    {
        [self.delegate dataSource:self didInsertChildDataSourcesAtIndexes:indexes toDataSource:dataSource eventOrigin:eventOrigin];
    }
}

- (void)didRemoveChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    // Notify upwards
    [self.parentDataSource didRemoveChildDataSources:childDataSources atIndexes:indexes fromDataSource:dataSource eventOrigin:eventOrigin];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didRemoveChildDataSources:atIndexes:fromDataSource:eventOrigin:)])
    {
        [self.delegate dataSource:self didRemoveChildDataSources:childDataSources atIndexes:indexes fromDataSource:dataSource eventOrigin:eventOrigin];
    }
}

- (void)didReplaceChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)dataSource
{
    // Notify upwards
    [self.parentDataSource didReplaceChildDataSources:childDataSources atIndexes:indexes inDataSource:dataSource];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didReplaceChildDataSources:atIndexes:inDataSource:)])
    {
        [self.delegate dataSource:self didReplaceChildDataSources:childDataSources atIndexes:indexes inDataSource:dataSource];
    }
}
- (void)didMoveChildDataSourceFromDataSource:(MUKDataSource *)sourceDataSource atIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    // Notify upwards
    [self.parentDataSource didMoveChildDataSourceFromDataSource:sourceDataSource atIndex:sourceIndex toDataSource:destinationDataSource atIndex:destinationIndex eventOrigin:eventOrigin];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didMoveChildDataSourceFromDataSource:atIndex:toDataSource:atIndex:eventOrigin:)])
    {
        [self.delegate dataSource:self didMoveChildDataSourceFromDataSource:sourceDataSource atIndex:sourceIndex toDataSource:destinationDataSource atIndex:destinationIndex eventOrigin:eventOrigin];
    }
}

- (void)didRefreshChildDataSourcesAtIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)dataSource
{
    // Notify upwards
    [self.parentDataSource didRefreshChildDataSourcesAtIndexes:indexes inDataSource:dataSource];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didRefreshChildDataSourcesAtIndexes:inDataSource:)])
    {
        [self.delegate dataSource:self didRefreshChildDataSourcesAtIndexes:indexes inDataSource:dataSource];
    }
}

- (void)didInsertItemsAtIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    // Notify upwards
    [self.parentDataSource didInsertItemsAtIndexes:indexes toDataSource:dataSource eventOrigin:eventOrigin];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didInsertItemsAtIndexes:toDataSource:eventOrigin:)])
    {
        [self.delegate dataSource:self didInsertItemsAtIndexes:indexes toDataSource:dataSource eventOrigin:eventOrigin];
    }
}

- (void)didRemoveItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes fromDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    // Notify upwards
    [self.parentDataSource didRemoveItems:items atIndexes:indexes fromDataSource:dataSource eventOrigin:eventOrigin];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didRemoveItems:atIndexes:fromDataSource:eventOrigin:)])
    {
        [self.delegate dataSource:self didRemoveItems:items atIndexes:indexes fromDataSource:dataSource eventOrigin:eventOrigin];
    }
}

- (void)didReplaceItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)dataSource
{
    // Notify upwards
    [self.parentDataSource didReplaceItems:items atIndexes:indexes inDataSource:dataSource];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didReplaceItems:atIndexes:inDataSource:)])
    {
        [self.delegate dataSource:self didReplaceItems:items atIndexes:indexes inDataSource:dataSource];
    }
}

- (void)didMoveItemFromDataSource:(MUKDataSource *)sourceDataSource atIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    // Notify upwards
    [self.parentDataSource didMoveItemFromDataSource:sourceDataSource atIndex:sourceIndex toDataSource:destinationDataSource atIndex:destinationIndex eventOrigin:eventOrigin];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didMoveItemFromDataSource:atIndex:toDataSource:atIndex:eventOrigin:)])
    {
        [self.delegate dataSource:self didMoveItemFromDataSource:sourceDataSource atIndex:sourceIndex toDataSource:destinationDataSource atIndex:destinationIndex eventOrigin:eventOrigin];
    }
}

- (void)didReloadDataInDataSource:(MUKDataSource *)dataSource {
    // Notify upwards
    [self.parentDataSource didReloadDataInDataSource:dataSource];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didReloadDataInDataSource:)])
    {
        [self.delegate dataSource:self didReloadDataInDataSource:dataSource];
    }
}

- (void)didRequestBatchUpdate:(dispatch_block_t)updateBlock fromDataSource:(MUKDataSource *)dataSource
{
    // Notify upwards
    [self.parentDataSource didRequestBatchUpdate:updateBlock fromDataSource:dataSource];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didRequestBatchUpdate:fromDataSource:)])
    {
        [self.delegate dataSource:self didRequestBatchUpdate:updateBlock fromDataSource:dataSource];
    }
}

- (void)willTransitionToContentLoadingState:(NSString *)state inDataSource:(MUKDataSource *)dataSource
{
    // Notify upwards
    [self.parentDataSource willTransitionToContentLoadingState:state inDataSource:dataSource];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:willTransitionToContentLoadingState:inDataSource:)])
    {
        [self.delegate dataSource:self willTransitionToContentLoadingState:state inDataSource:dataSource];
    }
}

- (void)didTransitionFromContentLoadingState:(NSString *)state inDataSource:(MUKDataSource *)dataSource
{
    // Notify upwards
    [self.parentDataSource didTransitionFromContentLoadingState:state inDataSource:dataSource];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didTransitionFromContentLoadingState:inDataSource:)])
    {
        [self.delegate dataSource:self didTransitionFromContentLoadingState:state inDataSource:dataSource];
    }
}

- (void)willLoadContent:(MUKDataSourceContentLoading *)contentLoading {
    // Notify upwards
    [self.parentDataSource willLoadContent:contentLoading];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:willLoadContent:)])
    {
        [self.delegate dataSource:self willLoadContent:contentLoading];
    }
}

- (void)didLoadContent:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error
{
    // Notify upwards
    [self.parentDataSource didLoadContent:contentLoading withResultType:resultType error:error];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didLoadContent:withResultType:error:)])
    {
        [self.delegate dataSource:self didLoadContent:contentLoading withResultType:resultType error:error];
    }
}

#pragma mark - Private - Contents

- (void)storeItems:(NSArray *)items emittingKVONotifications:(BOOL)emitKVONotifications
{
    if (emitKVONotifications) {
        [self willChangeValueForKey:@"items"];
    }
    
    _items = [items copy];
    
    if (emitKVONotifications) {
        [self didChangeValueForKey:@"items"];
    }
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath usingIndexAtPosition:(NSUInteger)position
{
    if (!indexPath || position >= indexPath.length) {
        return nil;
    }
    
    NSUInteger const idx = [indexPath indexAtPosition:position];
    BOOL const lastAvailablePosition = position == indexPath.length - 1;
    
    id item;
    if (lastAvailablePosition) {
        item = [self itemAtIndex:idx];
    }
    else {
        item = [[self childDataSourceAtIndex:idx] itemAtIndexPath:indexPath usingIndexAtPosition:position+1];
    }
    
    return item;
}

- (void)moveItemAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    if (!destinationDataSource) {
        return;
    }
    
    // Abort identities
    if (destinationDataSource == self && sourceIndex == destinationIndex) {
        return;
    }

    // Get data
    NSMutableArray *items = [self.items mutableCopy];
    id const item = items[sourceIndex];

    // Remove from original position
    [items removeObjectAtIndex:sourceIndex];
    
    // Get target data
    NSMutableArray *destinationItems;
    if (destinationDataSource == self) {
        destinationItems = items;
    }
    else {
        destinationItems = [destinationDataSource.items mutableCopy] ?: [[NSMutableArray alloc] init];
    }
    
    // Insert in destination items
    [destinationItems insertObject:item atIndex:destinationIndex];
    
    // Store
    [self storeItems:items emittingKVONotifications:YES];
    
    if (destinationDataSource != self) {
        [destinationDataSource storeItems:destinationItems emittingKVONotifications:YES];
    }
    
    // Notify
    [self didMoveItemFromDataSource:self atIndex:sourceIndex toDataSource:destinationDataSource atIndex:destinationIndex eventOrigin:eventOrigin];
}

- (void)removeItemsAtIndexes:(NSIndexSet *)indexes eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    if ([indexes count] == 0) {
        // Nothing to remove
        return;
    }
    
    NSMutableArray *newItems = [_items mutableCopy];
    
    NSArray *removedItems = [_items objectsAtIndexes:indexes];
    [newItems removeObjectsAtIndexes:indexes];
    
    [self storeItems:newItems emittingKVONotifications:YES];
    
    // Notify
    [self didRemoveItems:removedItems atIndexes:indexes fromDataSource:self eventOrigin:eventOrigin];
}

- (void)insertItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    if (!items || [items count] != [indexes count]) {
        return;
    }
    
    NSMutableArray *newItems = [_items mutableCopy] ?: [[NSMutableArray alloc] init];
    [newItems insertObjects:items atIndexes:indexes];

    [self storeItems:newItems emittingKVONotifications:YES];
    
    // Notify
    [self didInsertItemsAtIndexes:indexes toDataSource:self eventOrigin:eventOrigin];
}

#pragma mark - Private - Containment

- (BOOL)hasChildDataSources {
    return [self.childDataSources count] > 0;
}

- (MUKDataSource *)childDataSourceAtIndexPath:(NSIndexPath *)indexPath usingIndexAtPosition:(NSUInteger)position
{
    if (!indexPath || position >= indexPath.length) {
        return nil;
    }
    
    NSUInteger const idx = [indexPath indexAtPosition:position];
    BOOL const lastAvailablePosition = position == indexPath.length - 1;
    
    MUKDataSource *childDataSource;
    if (lastAvailablePosition) {
        childDataSource = [self childDataSourceAtIndex:idx];
    }
    else {
        childDataSource = [[self childDataSourceAtIndex:idx] childDataSourceAtIndexPath:indexPath usingIndexAtPosition:position+1];
    }
    
    return childDataSource;
}

- (BOOL)containsOneOrMoreChildDataSources:(NSArray *)dataSources {
    if ([dataSources count] == 0) {
        return NO;
    }
    
    for (MUKDataSource *dataSource in dataSources) {
        if ([self.childDataSources containsObject:dataSource]) {
            return YES;
        }
    } // for
    
    return NO;
}

- (void)storeChildDataSources:(NSArray *)childDataSources emittingKVONotifications:(BOOL)emitKVONotifications
{
    if (emitKVONotifications) {
        [self willChangeValueForKey:@"childDataSources"];
    }
    
    _childDataSources = [childDataSources copy];
    
    if (emitKVONotifications) {
        [self didChangeValueForKey:@"childDataSources"];
    }
}

- (void)moveChildDataSourceAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    if (!destinationDataSource) {
        return;
    }
    
    // Abort identities
    if (destinationDataSource == self && sourceIndex == destinationIndex) {
        return;
    }
    
    // Get data
    NSMutableArray *childDataSources = [self.childDataSources mutableCopy];
    MUKDataSource *const movedChildDataSource = childDataSources[sourceIndex];
    
    // Get target data
    NSMutableArray *destinationChildDataSources;
    if (destinationDataSource == self) {
        destinationChildDataSources = childDataSources;
    }
    else {
        destinationChildDataSources = [destinationDataSource.childDataSources mutableCopy] ?: [[NSMutableArray alloc] init];
    }
    
    // Abort moves that create duplicates
    if (destinationDataSource != self && [destinationDataSource containsOneOrMoreChildDataSources:@[movedChildDataSource]])
    {
        return;
    }
    
    // Remove from original position
    [childDataSources removeObjectAtIndex:sourceIndex];
    
    // Insert in destination items
    [destinationChildDataSources insertObject:movedChildDataSource atIndex:destinationIndex];
    movedChildDataSource.parentDataSource = destinationDataSource;
    
    // Store
    [self storeChildDataSources:childDataSources emittingKVONotifications:YES];
    
    if (destinationDataSource != self) {
        [destinationDataSource storeChildDataSources:destinationChildDataSources emittingKVONotifications:YES];
    }
    
    // Notify
    [self didMoveChildDataSourceFromDataSource:self atIndex:sourceIndex toDataSource:destinationDataSource atIndex:destinationIndex eventOrigin:eventOrigin];
}

- (void)removeChildDataSourcesAtIndexes:(NSIndexSet *)indexes eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    if ([indexes count] == 0 || [_childDataSources count] == 0) {
        // Nothing to remove
        return;
    }
    
    NSMutableArray *newChildDataSources = [_childDataSources mutableCopy];
    
    NSArray *removedChildDataSources = [_childDataSources objectsAtIndexes:indexes];
    [newChildDataSources removeObjectsAtIndexes:indexes];
    [removedChildDataSources makeObjectsPerformSelector:@selector(setParentDataSource:) withObject:nil];
    
    [self storeChildDataSources:newChildDataSources emittingKVONotifications:YES];
    
    // Notify
    [self didRemoveChildDataSources:removedChildDataSources atIndexes:indexes fromDataSource:self eventOrigin:eventOrigin];
}

- (void)insertChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    if (!childDataSources || [childDataSources count] != [indexes count] ||
        [self containsOneOrMoreChildDataSources:childDataSources])
    {
        return;
    }
    
    NSMutableArray *newChildDataSources = [_childDataSources mutableCopy] ?: [[NSMutableArray alloc] init];
    [newChildDataSources insertObjects:childDataSources atIndexes:indexes];    
    [childDataSources makeObjectsPerformSelector:@selector(setParentDataSource:) withObject:self];
    
    [self storeChildDataSources:newChildDataSources emittingKVONotifications:YES];
    
    // Notify
    [self didInsertChildDataSourcesAtIndexes:indexes toDataSource:self eventOrigin:eventOrigin];
}

- (void)replaceChildDataSourcesAtIndexes:(NSIndexSet *)indexes withChildDataSources:(NSArray *)insertedChildDataSources eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    if (!indexes || [indexes count] != [insertedChildDataSources count]) {
        return;
    }
    
    NSMutableArray *updatedChildDataSources = [_childDataSources mutableCopy];
    NSArray *const removedChildDataSources = [_childDataSources objectsAtIndexes:indexes];
    
    [updatedChildDataSources replaceObjectsAtIndexes:indexes withObjects:insertedChildDataSources];
    
    for (MUKDataSource *removedDataSource in removedChildDataSources) {
        if (![updatedChildDataSources containsObject:removedDataSource]) {
            removedDataSource.parentDataSource = nil;
        }
    } // for

    [insertedChildDataSources makeObjectsPerformSelector:@selector(setParentDataSource:) withObject:self];
    
    [self storeChildDataSources:updatedChildDataSources emittingKVONotifications:YES];
    
    // Notify
    [self didReplaceChildDataSources:removedChildDataSources atIndexes:indexes inDataSource:self];
}

#pragma mark - Private — State

- (TKStateMachine *)newStateMachine {
    TKStateMachine *stateMachine = [[TKStateMachine alloc] init];
    
    NSArray *states = [self newStateMachineStates];
    [stateMachine addStates:states];
    stateMachine.initialState = [stateMachine stateNamed:MUKDataSourceContentLoadStateInitial];
    [self attachStateHandlersToStateMachine:stateMachine];
    
    NSArray *events = [self newEventsForStateMachine:stateMachine];
    [stateMachine addEvents:events];
    [self attachEventHandlersToStateMachine:stateMachine];
    
    return stateMachine;
}

- (void)attachStateHandlersToStateMachine:(TKStateMachine *)stateMachine {
    if (!stateMachine) {
        return;
    }
    
    __weak MUKDataSource *const weakSelf = self;
    
    // Common actions
    void (^prepareCurrentContentLoadingAndExecute)(TKState *, TKState *) = ^(TKState *sourceState, TKState *loadingState)
    {
        MUKDataSource *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf prepareContentLoadingFromState:sourceState.name loadingState:loadingState.name andExecute:YES];
        }
    };
    
    void (^destroyCurrentContentLoading)(void) = ^{
        MUKDataSource *strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.currentContentLoading = nil;
        }
    };

    void (^executeUpdate)(TKTransition *) = ^(TKTransition *transition) {
        dispatch_block_t updateHandler = transition.userInfo[kStateMachineEventUpdateHandlerUserInfoKey];
        
        if (updateHandler) {
            updateHandler();
        }
    };
    
    void (^notifyKVOForLoadingState)(BOOL) = ^(BOOL completed) {
        MUKDataSource *strongSelf = weakSelf;
        if (strongSelf) {
            if (completed) {
                [strongSelf didChangeValueForKey:@"loadingState"];
            }
            else {
                [strongSelf willChangeValueForKey:@"loadingState"];
            }
        }
    };
    
    void (^notifyWillTransitionToState)(TKState *) = ^(TKState *state) {
        MUKDataSource *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf willTransitionToContentLoadingState:state.name inDataSource:strongSelf];
        }
    };
    
    void (^notifyDidTransitionFromState)(TKState *) = ^(TKState *state) {
        MUKDataSource *strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf didTransitionFromContentLoadingState:state.name inDataSource:strongSelf];
        }
    };
    
    void (^notifyDidLoadContent)(TKTransition *) = ^(TKTransition *transition)
    {
        MUKDataSource *strongSelf = weakSelf;
        if (strongSelf) {
            MUKDataSourceContentLoading *contentLoading = transition.userInfo[kStateMachineEventContentLoadingUserInfoKey];
            MUKDataSourceContentLoadingResultType resultType = [transition.userInfo[kStateMachineEventContentLoadingResultTypeUserInfoKey] integerValue];
            NSError *error = transition.userInfo[kStateMachineEventErrorUserInfoKey];
            [strongSelf didLoadContent:contentLoading withResultType:resultType error:error];
        }
    };
    
    // Actual attaching
    
    // Loading
    TKState *state = [stateMachine stateNamed:MUKDataSourceContentLoadStateLoading];
    [state setWillEnterStateBlock:^(TKState *state, TKTransition *transition) {
        notifyKVOForLoadingState(NO);
        notifyWillTransitionToState(transition.destinationState);
    }];
    [state setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        prepareCurrentContentLoadingAndExecute(transition.sourceState, transition.destinationState);
        notifyDidTransitionFromState(transition.sourceState);
        notifyKVOForLoadingState(YES);
    }];
    
    // Refreshing
    state = [stateMachine stateNamed:MUKDataSourceContentLoadStateRefreshing];
    [state setWillEnterStateBlock:^(TKState *state, TKTransition *transition) {
        notifyKVOForLoadingState(NO);
        notifyWillTransitionToState(transition.destinationState);
    }];
    [state setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        prepareCurrentContentLoadingAndExecute(transition.sourceState, transition.destinationState);
        notifyDidTransitionFromState(transition.sourceState);
        notifyKVOForLoadingState(YES);
    }];
    
    // Appending
    state = [stateMachine stateNamed:MUKDataSourceContentLoadStateAppending];
    [state setWillEnterStateBlock:^(TKState *state, TKTransition *transition) {
        notifyKVOForLoadingState(NO);
        notifyWillTransitionToState(transition.destinationState);
    }];
    [state setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        prepareCurrentContentLoadingAndExecute(transition.sourceState, transition.destinationState);
        notifyDidTransitionFromState(transition.sourceState);
        notifyKVOForLoadingState(YES);
    }];
    
    // Loaded
    state = [stateMachine stateNamed:MUKDataSourceContentLoadStateLoaded];
    [state setWillEnterStateBlock:^(TKState *state, TKTransition *transition) {
        notifyKVOForLoadingState(NO);
        notifyWillTransitionToState(transition.destinationState);
        executeUpdate(transition);
    }];
    [state setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        prepareCurrentContentLoadingAndExecute(transition.sourceState, transition.destinationState);
        destroyCurrentContentLoading();
        notifyDidLoadContent(transition);
        notifyDidTransitionFromState(transition.sourceState);
        notifyKVOForLoadingState(YES);
    }];
    
    // Empty
    state = [stateMachine stateNamed:MUKDataSourceContentLoadStateEmpty];
    [state setWillEnterStateBlock:^(TKState *state, TKTransition *transition) {
        notifyKVOForLoadingState(NO);
        notifyWillTransitionToState(transition.destinationState);
        executeUpdate(transition);
    }];
    [state setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        destroyCurrentContentLoading();
        notifyDidLoadContent(transition);
        notifyDidTransitionFromState(transition.sourceState);
        notifyKVOForLoadingState(YES);
    }];
    
    // Error
    state = [stateMachine stateNamed:MUKDataSourceContentLoadStateError];
    [state setWillEnterStateBlock:^(TKState *state, TKTransition *transition) {
        notifyKVOForLoadingState(NO);
        notifyWillTransitionToState(transition.destinationState);
        executeUpdate(transition);
    }];
    [state setDidEnterStateBlock:^(TKState *state, TKTransition *transition) {
        destroyCurrentContentLoading();
        notifyDidLoadContent(transition);
        notifyDidTransitionFromState(transition.sourceState);
        notifyKVOForLoadingState(YES);
    }];
}

- (NSArray *)newStateMachineStates {
    NSMutableArray *states = [[NSMutableArray alloc] init];
    
    TKState *state = [TKState stateWithName:MUKDataSourceContentLoadStateInitial];
    [states addObject:state];

    state = [TKState stateWithName:MUKDataSourceContentLoadStateLoading];
    [states addObject:state];
    
    state = [TKState stateWithName:MUKDataSourceContentLoadStateRefreshing];
    [states addObject:state];
    
    state = [TKState stateWithName:MUKDataSourceContentLoadStateAppending];
    [states addObject:state];
    
    state = [TKState stateWithName:MUKDataSourceContentLoadStateLoaded];
    [states addObject:state];

    state = [TKState stateWithName:MUKDataSourceContentLoadStateEmpty];
    [states addObject:state];
    
    state = [TKState stateWithName:MUKDataSourceContentLoadStateError];
    [states addObject:state];
    
    return [states copy];
}

- (NSArray *)newEventsForStateMachine:(TKStateMachine *)stateMachine {
    if (!stateMachine) {
        return nil;
    }
    
    NSMutableArray *events = [[NSMutableArray alloc] init];
    
    TKState *const initialState = [stateMachine stateNamed:MUKDataSourceContentLoadStateInitial];
    TKState *const loadingState = [stateMachine stateNamed:MUKDataSourceContentLoadStateLoading];
    TKState *const refreshingState = [stateMachine stateNamed:MUKDataSourceContentLoadStateRefreshing];
    TKState *const appendingState = [stateMachine stateNamed:MUKDataSourceContentLoadStateAppending];
    TKState *const loadedState = [stateMachine stateNamed:MUKDataSourceContentLoadStateLoaded];
    TKState *const emptyState = [stateMachine stateNamed:MUKDataSourceContentLoadStateEmpty];
    TKState *const errorState = [stateMachine stateNamed:MUKDataSourceContentLoadStateError];
    
    TKEvent *event = [TKEvent eventWithName:MUKDataSourceContentLoadEventBeginLoading transitioningFromStates:@[initialState] toState:loadingState];
    [events addObject:event];
    
    event = [TKEvent eventWithName:MUKDataSourceContentLoadEventBeginRefreshing transitioningFromStates:@[loadedState, emptyState, errorState] toState:refreshingState];
    [events addObject:event];
    
    event = [TKEvent eventWithName:MUKDataSourceContentLoadEventBeginAppending transitioningFromStates:@[loadedState] toState:appendingState];
    [events addObject:event];
    
    event = [TKEvent eventWithName:MUKDataSourceContentLoadEventDisplayLoaded transitioningFromStates:@[loadingState, refreshingState, appendingState] toState:loadedState];
    [events addObject:event];
    
    event = [TKEvent eventWithName:MUKDataSourceContentLoadEventDisplayEmpty transitioningFromStates:@[loadingState, refreshingState] toState:emptyState];
    [events addObject:event];
    
    event = [TKEvent eventWithName:MUKDataSourceContentLoadEventDisplayError transitioningFromStates:@[loadingState, refreshingState] toState:errorState];
    [events addObject:event];
    
    return [events copy];
}

- (void)attachEventHandlersToStateMachine:(TKStateMachine *)stateMachine {
    if (!stateMachine) {
        return;
    }
    
    // __weak MUKDataSource *const weakSelf = self;
}

#pragma mark - Private - Content Loading

- (BOOL)loadContent {
    // Attempt first load
    TKEvent *event = [self.stateMachine eventNamed:MUKDataSourceContentLoadEventBeginLoading];
    BOOL success = [self.stateMachine fireEvent:event userInfo:nil error:nil];
    if (success) {
        return YES;
    }
    
    // Attempt refresh
    event = [self.stateMachine eventNamed:MUKDataSourceContentLoadEventBeginRefreshing];
    success = [self.stateMachine fireEvent:event userInfo:nil error:nil];
    if (success) {
        return YES;
    }
    
    // Check if it could reuse current state
    if ([self.loadingState isEqualToString:MUKDataSourceContentLoadStateLoading] ||
        [self.loadingState isEqualToString:MUKDataSourceContentLoadStateRefreshing])
    {
        [self prepareContentLoadingFromState:self.currentContentLoading.sourceState loadingState:self.loadingState andExecute:YES];
        return YES;
    }
    
    return NO;
}

- (BOOL)appendContent {
    TKEvent *event = [self.stateMachine eventNamed:MUKDataSourceContentLoadEventBeginAppending];
    BOOL success = [self.stateMachine fireEvent:event userInfo:nil error:nil];
    if (success) {
        return YES;
    }
    
    // Check if it could reuse current state
    if ([self.loadingState isEqualToString:MUKDataSourceContentLoadEventBeginAppending])
    {
        [self prepareContentLoadingFromState:self.currentContentLoading.sourceState loadingState:self.loadingState andExecute:YES];
        return YES;
    }
    
    return NO;
}

- (void)prepareContentLoadingFromState:(NSString *)sourceState loadingState:(NSString *)loadingState andExecute:(BOOL)execute
{
    // Abort current one
    [self.currentContentLoading cancel];
    
    // Create new loading
    MUKDataSourceContentLoading *contentLoading = [self newContentLoadingForState:loadingState];
    contentLoading.sourceState = sourceState;
    contentLoading.dataSource = self;
    self.currentContentLoading = contentLoading;
    
    // Execute
    if (execute && contentLoading.job) {
        [self willLoadContent:contentLoading];
        contentLoading.job();
    }
}

- (void)didFinishContentLoading:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error update:(dispatch_block_t)updateHandler
{
    // Is it meaningful?
    if (contentLoading.isCancelled) {
        return;
    }
    
    // Pass to next state
    TKEvent *event = [self nextStateMachineEventForFinishedContentLoading:contentLoading withResultType:resultType];
    if (event) {
        NSDictionary *userInfo = [self userInfoForStateMachineEvent:event finishedContentLoading:contentLoading withResultType:resultType error:error update:updateHandler];
        [self.stateMachine fireEvent:event userInfo:userInfo error:nil];
    }
}

- (TKEvent *)nextStateMachineEventForFinishedContentLoading:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType
{
    NSString *eventName;
    
    switch (resultType) {
        case MUKDataSourceContentLoadingResultTypeComplete:
        case MUKDataSourceContentLoadingResultTypePartial:
            eventName = MUKDataSourceContentLoadEventDisplayLoaded;
            break;
            
        case MUKDataSourceContentLoadingResultTypeEmpty: {
            if ([self.loadingState isEqualToString:MUKDataSourceContentLoadStateAppending])
            {
                // Should come back to previous state, which must be content loaded
                eventName = MUKDataSourceContentLoadEventDisplayLoaded;
            }
            else if ([self.loadingState isEqualToString:MUKDataSourceContentLoadStateLoading] ||
                     [self.loadingState isEqualToString:MUKDataSourceContentLoadStateRefreshing])
            {
                eventName = MUKDataSourceContentLoadEventDisplayEmpty;
            }
            else {
                eventName = nil;
            }
            
            break;
        }
            
        case MUKDataSourceContentLoadingResultTypeError: {
            if ([self.loadingState isEqualToString:MUKDataSourceContentLoadStateAppending])
            {
                // Should come back to previous state, which must be content loaded
                eventName = MUKDataSourceContentLoadEventDisplayLoaded;
            }
            else if ([self.loadingState isEqualToString:MUKDataSourceContentLoadStateLoading] ||
                     [self.loadingState isEqualToString:MUKDataSourceContentLoadStateRefreshing])
            {
                eventName = MUKDataSourceContentLoadEventDisplayError;
            }
            else {
                eventName = nil;
            }
            
            break;
        }
            
        default:
            break;
    } // switch
    
    if (eventName) {
        return [self.stateMachine eventNamed:eventName];
    }
    
    return nil;
}

- (NSDictionary *)userInfoForStateMachineEvent:(TKEvent *)event finishedContentLoading:(MUKDataSourceContentLoading *)contentLoading withResultType:(MUKDataSourceContentLoadingResultType)resultType error:(NSError *)error update:(dispatch_block_t)updateHandler
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    userInfo[kStateMachineEventContentLoadingResultTypeUserInfoKey] = @(resultType);

    if (updateHandler) {
        userInfo[kStateMachineEventUpdateHandlerUserInfoKey] = [updateHandler copy];
    }
    
    if (contentLoading) {
        userInfo[kStateMachineEventContentLoadingUserInfoKey] = contentLoading;
    }
    
    if (error) {
        userInfo[kStateMachineEventErrorUserInfoKey] = error;
    }
    
    return [userInfo copy];
}

@end
