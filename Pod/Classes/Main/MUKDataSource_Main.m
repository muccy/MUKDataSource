#import "MUKDataSource_Main.h"
#import "MUKDataSource_Private.h"
#import "MUKDataSourceBatch.h"

@interface MUKDataSource ()
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, readwrite) NSArray *childDataSources;
@property (nonatomic, weak, readwrite) MUKDataSource *parentDataSource;
@end

@implementation MUKDataSource
@dynamic hasChildDataSources;

#pragma mark - items KVC compliance

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

#pragma mark - Contents

- (void)setItems:(NSArray *)items {
    [self setItems:items animated:NO];
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated {
    if ([_items isEqualToArray:items]) {
        return;
    }
    
    // Define common storage code
    dispatch_block_t storeItems = ^{
        [self willChangeValueForKey:@"items"];
        _items = [items copy];
        [self didChangeValueForKey:@"items"];
    };
    
    if (!animated) {
        // 1-pass
        storeItems();
        
        // TODO: notify section refreshed
        
        return;
    }
    
    // Animated is way more complicated because I want to notify differences
    // in order to animate them
    
    NSOrderedSet *oldItemSet = [[NSOrderedSet alloc] initWithArray:_items];
    NSOrderedSet *newItemSet = [[NSOrderedSet alloc] initWithArray:items];
    
    // Find deleted items
    NSMutableOrderedSet *deletedItems = [oldItemSet mutableCopy];
    [deletedItems minusOrderedSet:newItemSet];
    
    // Find inserted items
    NSMutableOrderedSet *insertedItems = [newItemSet mutableCopy];
    [insertedItems minusOrderedSet:oldItemSet];
    
    // Find moved items
    NSMutableOrderedSet *potentiallyMovedItems = [newItemSet mutableCopy];
    [potentiallyMovedItems intersectOrderedSet:oldItemSet];
    
    // Get deleted indexes
    NSIndexSet *deletedIndexes = [oldItemSet indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
    {
        return [deletedItems containsObject:obj];
    }];
    
    // Get inserted indexes
    NSIndexSet *insertedIndexes = [newItemSet indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
    {
        return [insertedItems containsObject:obj];
    }];
    
    // Store items
    storeItems();
    
    // Compose a batch of notifications
    MUKDataSourceBatch *batch = [[MUKDataSourceBatch alloc] init];
    
    // Deletions
    if ([deletedIndexes count] > 0) {
        [batch addBlock:^{
            [self didRemoveItems:[[deletedItems array] copy] atIndexes:deletedIndexes fromDataSource:self eventOrigin:MUKDataSourceEventOriginProgrammatic];
        }];
    }
    
    // Insertions
    if ([insertedItems count] > 0) {
        [batch addBlock:^{
            [self didInsertItems:[[insertedItems array] copy] atIndexes:insertedIndexes toDataSource:self eventOrigin:MUKDataSourceEventOriginProgrammatic];
        }];
    }
    
    // Moves
    NSMutableIndexSet *movedIndexSet = [[NSMutableIndexSet alloc] init];
    
    for (id movedItem in potentiallyMovedItems) {
        NSInteger movedFromIndex = [oldItemSet indexOfObject:movedItem];
        NSInteger movedToIndex = [newItemSet indexOfObject:movedItem];
        BOOL const isInverseMove = [movedIndexSet containsIndex:movedToIndex];
        
        if (!isInverseMove && movedFromIndex != movedToIndex) {
            [movedIndexSet addIndex:movedFromIndex];
            
            [batch addBlock:^{
                [self didMoveItemFromDataSource:self atIndex:movedFromIndex toDataSource:self atIndex:movedToIndex eventOrigin:MUKDataSourceEventOriginProgrammatic];
            }];
        }
    } // for
    
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

- (NSInteger)indexOfItem:(id)item {
    return [self.items indexOfObject:item];
}

- (NSIndexPath *)indexPathOfItem:(id)item {
    if (!item) {
        return nil;
    }
    
    NSIndexPath *foundIndexPath = nil;
    
    if (self.hasChildDataSources) {
        // Request child to provide index path
        // Stop at first one you can find
        NSInteger childIndex = 0;
        for (MUKDataSource *childDataSource in self.childDataSources) {
            NSIndexPath *indexPath = [childDataSource indexPathOfItem:item];
            
            if (indexPath) {
                foundIndexPath = indexPath;
                break;
            }
            else {
                childIndex++;
            }
        } // for
        
        // Enrich found index path with child index
        if (foundIndexPath) {
            // Prepend index
            NSUInteger *indexes = calloc(foundIndexPath.length + 1, sizeof(NSUInteger));
            
            if (indexes != NULL) {
                [foundIndexPath getIndexes:indexes];
                
                memmove(indexes + 1, indexes, sizeof(NSUInteger) * foundIndexPath.length);
                indexes[0] = childIndex;
                
                foundIndexPath = [NSIndexPath indexPathWithIndexes:indexes length:foundIndexPath.length + 1];
                
                free(indexes);
            }
            else {
                foundIndexPath = nil; // Invalidate
            }
        }
    }
    else {
        // No children: we are in a leaf
        // Search for an index and compose an index path with only one element
        NSInteger idx = [self indexOfItem:item];
        if (idx != NSNotFound) {
            foundIndexPath = [NSIndexPath indexPathWithIndex:idx];
        }
    }
    
    return foundIndexPath;
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
    [self replaceItemsAtIndexes:[NSIndexSet indexSetWithIndex:idx] withItems:newItem];
}

- (void)requestBatchUpdate:(dispatch_block_t)updateBlock {
    // Delegate is assigned to perform batch updates: do nothing here
    
    [self didRequestBatchUpdate:updateBlock fromDataSource:self eventOrigin:MUKDataSourceEventOriginProgrammatic];
}

#pragma mark - Containment

- (void)addChildDataSource:(MUKDataSource *)dataSource {
    if (!dataSource) {
        return;
    }
    
    // Create if still nil
    NSArray *childDataSources = self.childDataSources ?: [NSArray array];
    
    // No duplicates
    if ([childDataSources indexOfObject:dataSource] != NSNotFound) {
        return;
    }
    
    dataSource.parentDataSource = self;
    self.childDataSources = [childDataSources arrayByAddingObject:dataSource];
}

- (void)removeDataSource:(MUKDataSource *)dataSource {
    if (!dataSource || !self.childDataSources) {
        return;
    }
    
    NSMutableArray *childDataSources = [self.childDataSources mutableCopy];
    [childDataSources removeObject:dataSource];
    self.childDataSources = [childDataSources copy];
    
    if (dataSource.parentDataSource == self) {
        dataSource.parentDataSource = nil;
    }
}

#pragma mark - Callbacks

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

- (void)didInsertItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes toDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    // Notify upwards
    [self.parentDataSource didInsertItems:items atIndexes:indexes toDataSource:dataSource eventOrigin:eventOrigin];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didInsertItems:atIndexes:toDataSource:eventOrigin:)])
    {
        [self.delegate dataSource:self didInsertItems:items atIndexes:indexes toDataSource:dataSource eventOrigin:eventOrigin];
    }
}

- (void)didReplaceItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes withItems:(NSArray *)newItems inDataSource:(MUKDataSource *)dataSource eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    // Notify upwards
    [self.parentDataSource didReplaceItems:items atIndexes:indexes withItems:newItems inDataSource:dataSource eventOrigin:eventOrigin];
    
    // Inform delegate
    if ([self.delegate respondsToSelector:@selector(dataSource:didReplaceItems:atIndexes:withItems:inDataSource:eventOrigin:)])
    {
        [self.delegate dataSource:self didReplaceItems:items atIndexes:indexes withItems:newItems inDataSource:dataSource eventOrigin:eventOrigin];
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
    if (self == destinationDataSource) {
        // Simple swap
        NSMutableArray *items = [self.items mutableCopy];
        [items exchangeObjectAtIndex:sourceIndex withObjectAtIndex:destinationIndex];
        self.items = items;
    }
    else {
        NSMutableArray *items = [self.items mutableCopy];
        id item = items[sourceIndex];
        [items removeObjectAtIndex:sourceIndex];
        
        NSMutableArray *destinationItems = [destinationDataSource.items mutableCopy];
        [destinationItems insertObject:item atIndex:destinationIndex];
        
        self.items = items;
        destinationDataSource.items = [destinationItems copy];
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
    
    self.items = newItems; // Implicit copy and KVO notification
    
    // Notify
    [self didRemoveItems:removedItems atIndexes:indexes fromDataSource:self eventOrigin:eventOrigin];
}

- (void)insertItems:(NSArray *)items atIndexes:(NSIndexSet *)indexes eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    if (!items || [items count] != [indexes count]) {
        return;
    }
    
    NSMutableArray *newItems = [_items mutableCopy];
    [newItems insertObjects:items atIndexes:indexes];

    self.items = newItems; // Implicit copy and KVO notification
    
    // Notify
    [self didInsertItems:items atIndexes:indexes toDataSource:self eventOrigin:eventOrigin];
}

- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)items eventOrigin:(MUKDataSourceEventOrigin)eventOrigin
{
    if (!indexes || [indexes count] != [items count]) {
        return;
    }
    
    NSMutableArray *newItems = [_items mutableCopy];
    NSArray *const oldItems = [_items objectsAtIndexes:indexes];
    [newItems replaceObjectsAtIndexes:indexes withObjects:items];
    
    self.items = newItems; // Implicit copy and KVO notification
    
    // Notify
    [self didReplaceItems:oldItems atIndexes:indexes withItems:items inDataSource:self eventOrigin:eventOrigin];
}

#pragma mark - Private - Containment

- (BOOL)hasChildDataSources {
    return [self.childDataSources count] > 0;
}

- (MUKDataSource *)childDataSourceAtIndex:(NSInteger)idx {
    if (idx < 0 || idx >= [self.childDataSources count]) {
        return nil;
    }
    
    return self.childDataSources[idx];
}

@end
