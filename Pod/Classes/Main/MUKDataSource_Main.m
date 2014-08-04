#import "MUKDataSource_Main.h"
#import "MUKDataSource_Private.h"
#import "MUKDataSourceBatch.h"
#import "MUKDataSourceArrayDelta.h"

@interface MUKDataSource ()
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, readwrite) NSArray *childDataSources;
@property (nonatomic, weak, readwrite) MUKDataSource *parentDataSource;
@end

@implementation MUKDataSource
@dynamic hasChildDataSources;

#pragma mark - Methods

- (void)requestBatchUpdate:(dispatch_block_t)updateBlock {
    // Delegate is assigned to perform batch updates: do nothing here
    
    [self didRequestBatchUpdate:updateBlock fromDataSource:self eventOrigin:MUKDataSourceEventOriginProgrammatic];
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

- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)array {
    [self replaceItemsAtIndexes:indexes withItems:array eventOrigin:MUKDataSourceEventOriginProgrammatic];
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
        [self didRefreshChildDataSourcesAtIndexes:[NSIndexSet indexSetWithIndex:idx] inDataSource:self.parentDataSource eventOrigin:MUKDataSourceEventOriginProgrammatic];
        
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

- (void)moveItemAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex
{
    [self moveItemAtIndex:sourceIndex toDataSource:destinationDataSource atIndex:destinationIndex eventOrigin:MUKDataSourceEventOriginProgrammatic];
}

- (void)removeItemAtIndex:(NSInteger)idx {
    [self removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:idx]];
}

- (void)insertItem:(id)item atIndex:(NSInteger)idx {
    [self insertItems:@[item] atIndexes:[NSIndexSet indexSetWithIndex:idx]];
}

- (void)replaceItemAtIndex:(NSInteger)idx withItem:(id)newItem {
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
        [self didReloadDataInDataSource:self eventOrigin:MUKDataSourceEventOriginProgrammatic];
        
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
             [self didMoveChildDataSourcesFromDataSource:self atIndex:fromIndex toDataSource:self atIndex:toIndex eventOrigin:MUKDataSourceEventOriginProgrammatic];
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
    [self removeChildDataSourcesAtIndexes:[NSIndexSet indexSetWithIndex:idx]];
}

- (void)replaceChildDataSourceAtIndex:(NSInteger)idx withDataSource:(MUKDataSource *)newDataSource
{
    [self replaceChildDataSourcesAtIndexes:[NSIndexSet indexSetWithIndex:idx] withChildDataSources:@[newDataSource]];
}

- (void)moveChildDataSourceAtIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex
{
    [self moveChildDataSourceAtIndex:sourceIndex toDataSource:destinationDataSource atIndex:destinationIndex eventOrigin:MUKDataSourceEventOriginProgrammatic];
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

- (void)didReplaceChildDataSources:(NSArray *)childDataSources atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    // Notify upwards
    [self.parentDataSource didReplaceChildDataSources:childDataSources atIndexes:indexes inDataSource:dataSource eventOrigin:eventOrigin];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didReplaceChildDataSources:atIndexes:inDataSource:eventOrigin:)])
    {
        [self.delegate dataSource:self didReplaceChildDataSources:childDataSources atIndexes:indexes inDataSource:dataSource eventOrigin:eventOrigin];
    }
}
- (void)didMoveChildDataSourcesFromDataSource:(MUKDataSource *)sourceDataSource atIndex:(NSInteger)sourceIndex toDataSource:(MUKDataSource *)destinationDataSource atIndex:(NSInteger)destinationIndex eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    // Notify upwards
    [self.parentDataSource didMoveChildDataSourcesFromDataSource:sourceDataSource atIndex:sourceIndex toDataSource:destinationDataSource atIndex:destinationIndex eventOrigin:eventOrigin];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didMoveChildDataSourcesFromDataSource:atIndex:toDataSource:atIndex:eventOrigin:)])
    {
        [self.delegate dataSource:self didMoveChildDataSourcesFromDataSource:sourceDataSource atIndex:sourceIndex toDataSource:destinationDataSource atIndex:destinationIndex eventOrigin:eventOrigin];
    }
}

- (void)didRefreshChildDataSourcesAtIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    // Notify upwards
    [self.parentDataSource didRefreshChildDataSourcesAtIndexes:indexes inDataSource:dataSource eventOrigin:eventOrigin];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didRefreshChildDataSourcesAtIndexes:inDataSource:eventOrigin:)])
    {
        [self.delegate dataSource:self didRefreshChildDataSourcesAtIndexes:indexes inDataSource:dataSource eventOrigin:eventOrigin];
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

- (void)didReplaceItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes inDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    // Notify upwards
    [self.parentDataSource didReplaceItems:items atIndexes:indexes inDataSource:dataSource eventOrigin:eventOrigin];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didReplaceItems:atIndexes:inDataSource:eventOrigin:)])
    {
        [self.delegate dataSource:self didReplaceItems:items atIndexes:indexes inDataSource:dataSource eventOrigin:eventOrigin];
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

- (void)didReloadDataInDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    // Notify upwards
    [self.parentDataSource didReloadDataInDataSource:dataSource eventOrigin:eventOrigin];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didReloadDataInDataSource:eventOrigin:)])
    {
        [self.delegate dataSource:self didReloadDataInDataSource:dataSource eventOrigin:eventOrigin];
    }
}

- (void)didRequestBatchUpdate:(dispatch_block_t)updateBlock fromDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    // Notify upwards
    [self.parentDataSource didRequestBatchUpdate:updateBlock fromDataSource:dataSource eventOrigin:eventOrigin];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didRequestBatchUpdate:fromDataSource:eventOrigin:)])
    {
        [self.delegate dataSource:self didRequestBatchUpdate:updateBlock fromDataSource:dataSource eventOrigin:eventOrigin];
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

- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)items eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    if (!indexes || [indexes count] != [items count]) {
        return;
    }
    
    NSMutableArray *newItems = [_items mutableCopy];
    NSArray *const oldItems = [_items objectsAtIndexes:indexes];
    [newItems replaceObjectsAtIndexes:indexes withObjects:items];
    
    [self storeItems:newItems emittingKVONotifications:YES];
    
    // Notify
    [self didReplaceItems:oldItems atIndexes:indexes inDataSource:self eventOrigin:eventOrigin];
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
        destinationChildDataSources = [destinationDataSource.items mutableCopy] ?: [[NSMutableArray alloc] init];
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
    [self didMoveChildDataSourcesFromDataSource:self atIndex:sourceIndex toDataSource:destinationDataSource atIndex:destinationIndex eventOrigin:eventOrigin];
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
    [self didReplaceChildDataSources:removedChildDataSources atIndexes:indexes inDataSource:self eventOrigin:eventOrigin];
}

@end
