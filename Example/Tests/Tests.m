#import "MUKDataSource.h"
#import "MUKDataSource_Private.h"
#import "MUKDataSourceContentLoadEvent.h"
#import "MUKDataSourceContentLoading_Private.h"
#import <TransitionKit/TransitionKit.h>

static inline MUKDataSource *CreateDataSource(void) {
    return [[MUKDataSource alloc] init];
}

static NSIndexPath *IndexPathWithIndexes(NSArray *indexesArray) {
    NSIndexPath *indexPath = nil;
    
    if ([indexesArray count]) {
        NSUInteger *indexes = calloc([indexesArray count], sizeof(NSUInteger));
        
        if (indexes != NULL) {
            [indexesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
            {
                indexes[idx] = [obj unsignedIntegerValue];
            }];
            
            indexPath = [NSIndexPath indexPathWithIndexes:indexes length:[indexesArray count]];
            free(indexes);
        }
    }
    
    return indexPath;
}

#pragma mark - Main
SpecBegin(Main)

#pragma mark Contents
describe(@"Contents", ^{
    MUKDataSource *dataSource = CreateDataSource();

    it(@"should begin empty", ^{
        expect([dataSource.items count]).to.equal(0);
    });
    
    it(@"should be set with items", ^{
        NSArray *const items = @[@"A", @"B", @"C", @"C"];
        dataSource.items = items;
        expect(dataSource.items).to.equal(items);
        dataSource.items = nil;
        expect(dataSource.items).to.beNil;
        
        [dataSource setItems:items animated:NO];
        expect(dataSource.items).to.equal(items);
        [dataSource setItems:nil animated:NO];
        expect(dataSource.items).to.beNil;
        
        [dataSource setItems:items animated:YES];
        expect(dataSource.items).to.equal(items);
        [dataSource setItems:nil animated:YES];
        expect(dataSource.items).to.beNil;
    });
    
    it(@"should throw an exception when you try to access KVC proxy with items is nil", ^{
        dataSource.items = nil;
        NSMutableArray *itemsProxy = [dataSource mutableArrayValueForKey:@"items"];
        expect(^{ [itemsProxy addObjectsFromArray:@[@"A", @"B"]]; }).to.raiseAny();
    });
    
    it(@"should KVC compliant for items", ^{
        if (!dataSource.items) {
            dataSource.items = @[];
        }
        
        NSMutableArray *itemsProxy = [dataSource mutableArrayValueForKey:@"items"];
        expect(itemsProxy).to.beKindOf([NSMutableArray class]);
        
        NSArray *const items = @[@"A", @"B", @"C", @"C"];
        [itemsProxy addObjectsFromArray:items];
        expect(dataSource.items).to.equal(items);
        
        [itemsProxy removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)]];
        expect(dataSource.items).to.equal(@[@"A", @"B"]);
        
        [itemsProxy exchangeObjectAtIndex:0 withObjectAtIndex:1];
        expect(dataSource.items).to.equal(@[@"B", @"A"]);
        
        [itemsProxy replaceObjectAtIndex:0 withObject:@"O"];
        expect(dataSource.items).to.equal(@[@"O", @"A"]);
    });
    
    it(@"should access items", ^{
        dataSource.items = @[@"A", @"B"];
        expect([dataSource itemAtIndex:0]).to.equal(@"A");
        expect([dataSource itemAtIndex:1]).to.equal(@"B");
        expect([dataSource itemAtIndex:-1]).to.beNil;
        expect([dataSource itemAtIndex:2]).to.beNil;
    });
    
    it(@"should manage items with public primitives", ^{
        dataSource.items = nil;
        
        expect(^{ [dataSource insertItem:@"A" atIndex:1]; }).to.raiseAny();
        [dataSource insertItem:@"B" atIndex:0];
        expect(dataSource.items).to.equal(@[@"B"]);
        [dataSource insertItem:@"C" atIndex:1];
        expect(dataSource.items).to.equal(@[@"B", @"C"]);
        [dataSource insertItem:@"A" atIndex:0];
        expect(dataSource.items).to.equal(@[@"A", @"B", @"C"]);
        [dataSource insertItem:nil atIndex:0];
        expect(dataSource.items).to.equal(@[@"A", @"B", @"C"]);
        
        expect(^{ [dataSource removeItemAtIndex:10]; }).to.raiseAny();
        [dataSource removeItemAtIndex:1];
        expect(dataSource.items).to.equal(@[@"A", @"C"]);
        
        expect(^{ [dataSource replaceItemAtIndex:10 withItem:@"X"]; }).to.raiseAny();
        [dataSource replaceItemAtIndex:1 withItem:@"B"];
        expect(dataSource.items).to.equal(@[@"A", @"B"]);
        [dataSource replaceItemAtIndex:1 withItem:nil];
        expect(dataSource.items).to.equal(@[@"A", @"B"]);
        
        [dataSource insertItem:@"C" atIndex:2];
        expect(^{ [dataSource moveItemAtIndex:10 toDataSource:dataSource atIndex:0]; }).to.raiseAny();
        expect(^{ [dataSource moveItemAtIndex:2 toDataSource:dataSource atIndex:-1]; }).to.raiseAny();
        [dataSource moveItemAtIndex:2 toDataSource:dataSource atIndex:0];
        expect(dataSource.items).to.equal(@[@"C", @"A", @"B"]);
        [dataSource moveItemAtIndex:2 toDataSource:nil atIndex:0];
        expect(dataSource.items).to.equal(@[@"C", @"A", @"B"]);
    });
});

#pragma mark Containment
describe(@"Containment", ^{
    it(@"should begin with no parent", ^{
        expect(CreateDataSource().parentDataSource).to.beNil;
    });
    
    it(@"should begin with no children", ^{
        expect([CreateDataSource().childDataSources count]).to.equal(0);
    });
    
    it(@"should be set with child data sources", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        NSArray *const childDataSources = @[CreateDataSource(), CreateDataSource()];

        dispatch_block_t testAndReset = ^{
            expect(rootDataSource.childDataSources).to.equal(childDataSources);
            
            for (MUKDataSource *dataSource in rootDataSource.childDataSources) {
                expect(dataSource.parentDataSource).to.equal(rootDataSource);
            }
            
            rootDataSource.childDataSources = nil;
            expect(rootDataSource.childDataSources).to.beNil;
            
            for (MUKDataSource *dataSource in rootDataSource.childDataSources) {
                expect(dataSource.parentDataSource).to.beNil;
            }
        };
        
        rootDataSource.childDataSources = childDataSources;
        testAndReset();
        
        [rootDataSource setChildDataSources:childDataSources animated:NO];
        testAndReset();
        
        [rootDataSource setChildDataSources:childDataSources animated:YES];
        testAndReset();
    });
    
    it(@"should throw an exception when you try to access KVC proxy with childDataSources is nil", ^
    {
        MUKDataSource *rootDataSource = CreateDataSource();
        NSMutableArray *itemsProxy = [rootDataSource mutableArrayValueForKey:@"childDataSources"];
        expect(^{ [itemsProxy addObjectsFromArray:@[CreateDataSource()]]; }).to.raiseAny();
    });
    
    it(@"should KVC compliant for childDataSources", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        rootDataSource.childDataSources = @[];
        
        NSMutableArray *childDataSourceProxy = [rootDataSource mutableArrayValueForKey:@"childDataSources"];
        expect(childDataSourceProxy).to.beKindOf([NSMutableArray class]);
        
        void (^testParent)(NSArray *) = ^(NSArray *dataSources) {
            for (MUKDataSource *dataSource in dataSources) {
                expect(dataSource.parentDataSource).to.equal(rootDataSource);
            }
        };
        
        NSArray *const childDataSources = @[CreateDataSource(), CreateDataSource(), CreateDataSource(), CreateDataSource()];
        [childDataSourceProxy addObjectsFromArray:childDataSources];
        expect(rootDataSource.childDataSources).to.equal(childDataSources);
        testParent(rootDataSource.childDataSources);
        
        [childDataSourceProxy removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)]];
        expect(rootDataSource.childDataSources).to.equal([childDataSources subarrayWithRange:NSMakeRange(0, 2)]);
        testParent(rootDataSource.childDataSources);
        
        [childDataSourceProxy exchangeObjectAtIndex:0 withObjectAtIndex:1];
        expect(rootDataSource.childDataSources).to.equal(@[childDataSources[1], childDataSources[0]]);
        testParent(rootDataSource.childDataSources);
        
        [childDataSourceProxy replaceObjectAtIndex:0 withObject:CreateDataSource()];
        expect([rootDataSource.childDataSources count]).to.equal(2);
        expect([childDataSources containsObject:rootDataSource.childDataSources[0]]).to.beFalsy;
        expect([childDataSources indexOfObject:rootDataSource.childDataSources[1]]).to.equal(0);
        expect([childDataSources[0] parentDataSource]).to.beNil;
        testParent(rootDataSource.childDataSources);
    });

    MUKDataSource *rootDataSource = CreateDataSource();
    
    MUKDataSource *dataSource_0 = CreateDataSource();
    rootDataSource.childDataSources = @[dataSource_0];
    
    MUKDataSource *dataSource_0_0 = CreateDataSource();
    MUKDataSource *dataSource_0_1 = CreateDataSource();
    dataSource_0.childDataSources = @[dataSource_0_0, dataSource_0_1];
    
    rootDataSource.items = @[@"A", @"B"];
    dataSource_0.items = @[@"C", @"D"];
    dataSource_0_0.items = @[@"E", @"F"];
    dataSource_0_1.items = @[@"G", @"H"];
    
    it(@"should access items drilling down", ^{
        expect([rootDataSource itemAtIndexPath:nil]).to.beNil;
        
        NSIndexPath *indexPath = IndexPathWithIndexes(@[@0]);
        expect([rootDataSource itemAtIndexPath:indexPath]).to.equal([rootDataSource itemAtIndex:0]);
        
        indexPath = IndexPathWithIndexes(@[@100]);
        expect([rootDataSource itemAtIndexPath:indexPath]).to.beNil;
        
        indexPath = IndexPathWithIndexes(@[@0, @1]);
        expect([rootDataSource itemAtIndexPath:indexPath]).to.equal([dataSource_0 itemAtIndex:1]);
        
        indexPath = IndexPathWithIndexes(@[@0, @100]);
        expect([rootDataSource itemAtIndexPath:indexPath]).to.beNil;
        
        indexPath = IndexPathWithIndexes(@[@0, @1, @0]);
        expect([rootDataSource itemAtIndexPath:indexPath]).to.equal([dataSource_0_1 itemAtIndex:0]);
        
        indexPath = IndexPathWithIndexes(@[@0, @1, @0, @1, @1]);
        expect([rootDataSource itemAtIndexPath:indexPath]).to.beNil;
    });
    
    it(@"should count child data sources items", ^{
        expect([rootDataSource childDataSourcesItemCount]).to.equal(2);
        expect([dataSource_0 childDataSourcesItemCount]).to.equal(4);
        expect([dataSource_0_0 childDataSourcesItemCount]).to.equal(0);
    });
    
    it(@"should access child data sources", ^{
        expect([rootDataSource childDataSourceAtIndex:0]).to.equal(dataSource_0);
        expect([rootDataSource childDataSourceAtIndex:-1]).to.beNil;
        expect([rootDataSource childDataSourceAtIndex:100]).to.beNil;
        
        expect([dataSource_0 childDataSourceAtIndex:0]).to.equal(dataSource_0_0);
        expect([dataSource_0 childDataSourceAtIndex:1]).to.equal(dataSource_0_1);
        
        expect([dataSource_0_0 childDataSourceAtIndex:0]).to.beNil;
        
        // With index paths
        NSIndexPath *indexPath = IndexPathWithIndexes(@[@0]);
        expect([rootDataSource childDataSourceAtIndexPath:indexPath]).to.equal(dataSource_0);

        expect([rootDataSource childDataSourceAtIndexPath:nil]).to.beNil;
        indexPath = IndexPathWithIndexes(@[@(-1)]);
        expect([rootDataSource childDataSourceAtIndexPath:indexPath]).to.beNil;
        indexPath = IndexPathWithIndexes(@[@100]);
        expect([rootDataSource childDataSourceAtIndexPath:indexPath]).to.beNil;
        
        indexPath = IndexPathWithIndexes(@[@0, @0]);
        expect([rootDataSource childDataSourceAtIndexPath:indexPath]).to.equal(dataSource_0_0);
        indexPath = IndexPathWithIndexes(@[@0, @1]);
        expect([rootDataSource childDataSourceAtIndexPath:indexPath]).to.equal(dataSource_0_1);
        
        indexPath = IndexPathWithIndexes(@[@0, @100]);
        expect([rootDataSource childDataSourceAtIndexPath:indexPath]).to.beNil;
        indexPath = IndexPathWithIndexes(@[@0, @0, @1, @0]);
        expect([rootDataSource childDataSourceAtIndexPath:indexPath]).to.beNil;
    });
    
    it(@"should manage child data sources with public primitives", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        
        void (^testParent)(NSArray *) = ^(NSArray *dataSources) {
            for (MUKDataSource *dataSource in dataSources) {
                expect(dataSource.parentDataSource).to.equal(rootDataSource);
            }
        };
        
        // Insert
        expect(^{ [rootDataSource insertChildDataSource:CreateDataSource() atIndex:1]; }).to.raiseAny();
        
        MUKDataSource *dataSource = CreateDataSource();
        [rootDataSource insertChildDataSource:dataSource atIndex:0];
        expect(rootDataSource.childDataSources).to.equal(@[dataSource]);
        testParent(rootDataSource.childDataSources);
        
        [rootDataSource insertChildDataSource:nil atIndex:0];
        expect(rootDataSource.childDataSources).to.equal(@[dataSource]);
        testParent(rootDataSource.childDataSources);
        
        [rootDataSource insertChildDataSource:dataSource atIndex:0];
        expect([rootDataSource.childDataSources count]).to.equal(1); // No duplicates
        testParent(rootDataSource.childDataSources);
        
        MUKDataSource *anotherDataSource = CreateDataSource();
        [rootDataSource appendChildDataSource:anotherDataSource];
        expect([rootDataSource.childDataSources lastObject]).to.equal(anotherDataSource);
        testParent(rootDataSource.childDataSources);
        
        [rootDataSource appendChildDataSource:anotherDataSource];
        expect([rootDataSource.childDataSources count]).to.equal(2); // No duplicates
        testParent(rootDataSource.childDataSources);
 
        // Remove
        expect(^{ [rootDataSource removeChildDataSourceAtIndex:100]; }).to.raiseAny();
        
        [rootDataSource removeChildDataSourceAtIndex:0];
        expect(rootDataSource.childDataSources).to.equal(@[anotherDataSource]);
        expect(dataSource.parentDataSource).to.beNil;
        testParent(rootDataSource.childDataSources);
        
        [rootDataSource removeChildDataSource:dataSource];
        expect([rootDataSource.childDataSources count]).to.equal(1); // Not in array
        testParent(rootDataSource.childDataSources);
        
        [rootDataSource removeChildDataSource:nil];
        expect([rootDataSource.childDataSources count]).to.equal(1); // Nil allowed
        testParent(rootDataSource.childDataSources);
        
        [rootDataSource removeChildDataSource:anotherDataSource];
        expect([rootDataSource.childDataSources count]).to.equal(0);
        expect(anotherDataSource.parentDataSource).to.beNil;
        
        // Replace
        rootDataSource.childDataSources = @[dataSource];
        expect(^{ [rootDataSource replaceChildDataSourceAtIndex:100 withDataSource:anotherDataSource]; }).to.raiseAny();
        
        [rootDataSource replaceChildDataSourceAtIndex:0 withDataSource:anotherDataSource];
        expect(rootDataSource.childDataSources).to.equal(@[anotherDataSource]);
        expect(dataSource.parentDataSource).to.beNil;
        testParent(rootDataSource.childDataSources);
        
        // Move
        rootDataSource.childDataSources = @[dataSource, anotherDataSource];
        expect(^{ [rootDataSource moveChildDataSourceAtIndex:100 toDataSource:rootDataSource atIndex:0]; }).to.raiseAny();
        expect(^{ [rootDataSource moveChildDataSourceAtIndex:0 toDataSource:rootDataSource atIndex:100]; }).to.raiseAny();

        [rootDataSource moveChildDataSourceAtIndex:0 toDataSource:rootDataSource atIndex:1];
        expect(rootDataSource.childDataSources).to.equal(@[anotherDataSource, dataSource]);
        testParent(rootDataSource.childDataSources);
    });
    
    it(@"should move things between different data sources", ^{
        // Data sources
        MUKDataSource *rootDataSource = CreateDataSource();
        MUKDataSource *dataSource_0 = CreateDataSource();
        MUKDataSource *dataSource_1 = CreateDataSource();
        MUKDataSource *dataSource = CreateDataSource();
        
        rootDataSource.childDataSources = @[dataSource_0, dataSource_1];
        dataSource_0.childDataSources = @[dataSource];
        
        [dataSource_0 moveChildDataSourceAtIndex:0 toDataSource:dataSource_1 atIndex:0];
        expect([dataSource_0.childDataSources count]).to.equal(0);
        expect(dataSource_1.childDataSources).to.equal(@[dataSource]);
        expect(dataSource.parentDataSource).to.equal(dataSource_1);
        
        // Items
        dataSource_0.items = @[@"A", @"B", @"C"];
        [dataSource_0 moveItemAtIndex:1 toDataSource:dataSource_1 atIndex:0];
        expect(dataSource_0.items).to.equal(@[@"A", @"C"]);
        expect(dataSource_1.items).to.equal(@[@"B"]);
    });
});

#pragma mark Callbacks
describe(@"Callbacks", ^{
    it(@"should invoke callbacks for items insertion", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        MUKDataSource *dataSource = CreateDataSource();
        rootDataSource.items = childDataSource.items = dataSource.items = @[];
        [rootDataSource appendChildDataSource:childDataSource];
        [childDataSource appendChildDataSource:dataSource];
        
        id mockRootDataSource = OCMPartialMock(rootDataSource);
        id mockChildDataSource = OCMPartialMock(childDataSource);
        id mockDataSource = OCMPartialMock(dataSource);
        NSMutableArray *itemsProxy = [mockDataSource mutableArrayValueForKey:@"items"];
        
        void (^prepareExpectations)(NSIndexSet *, MUKDataSource *) = ^(NSIndexSet *insertedIndexSet, MUKDataSource *originatingDataSource)
        {
            OCMExpect([mockDataSource didInsertItemsAtIndexes:insertedIndexSet toDataSource:originatingDataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            
            OCMExpect([mockChildDataSource didInsertItemsAtIndexes:insertedIndexSet toDataSource:originatingDataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            
            OCMExpect([mockRootDataSource didInsertItemsAtIndexes:insertedIndexSet toDataSource:originatingDataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]);
        };
        
        // Insertion of multiple items
        NSIndexSet *insertedIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
        prepareExpectations(insertedIndexSet, dataSource);
        [itemsProxy insertObjects:@[@"A", @"B"] atIndexes:insertedIndexSet];
        
        // Insertion of single item
        insertedIndexSet = [NSIndexSet indexSetWithIndex:2];
        prepareExpectations(insertedIndexSet, dataSource);
        [mockDataSource insertItem:@"C" atIndex:[insertedIndexSet firstIndex]];
        
        // Invalid insertions will not cause any callback
        [mockDataSource insertItem:nil atIndex:0];
        
        expect(^{ OCMVerifyAll(mockDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockChildDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockRootDataSource); }).notTo.raiseAny();
    });
    
    it(@"should invoke callbacks for items deletion", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        MUKDataSource *dataSource = CreateDataSource();
        dataSource.items = @[@"A", @"B", @"C", @"D"];
        [rootDataSource appendChildDataSource:childDataSource];
        [childDataSource appendChildDataSource:dataSource];
        
        id mockRootDataSource = OCMPartialMock(rootDataSource);
        id mockChildDataSource = OCMPartialMock(childDataSource);
        id mockDataSource = OCMPartialMock(dataSource);
        NSMutableArray *itemsProxy = [mockDataSource mutableArrayValueForKey:@"items"];
        
        void (^prepareExpectations)(NSArray *, NSIndexSet *, MUKDataSource *) = ^(NSArray *deletedItems, NSIndexSet *deletedIndexes, MUKDataSource *originatingDataSource)
        {
            OCMExpect([mockDataSource didRemoveItems:deletedItems atIndexes:deletedIndexes fromDataSource:originatingDataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            
            OCMExpect([mockChildDataSource didRemoveItems:deletedItems atIndexes:deletedIndexes fromDataSource:originatingDataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            
            OCMExpect([mockRootDataSource didRemoveItems:deletedItems atIndexes:deletedIndexes fromDataSource:originatingDataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]);
        };
        
        // Deletion of multiple items
        NSIndexSet *deletedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
        NSArray *deletedItems = [[mockDataSource items] objectsAtIndexes:deletedIndexes];
        prepareExpectations(deletedItems, deletedIndexes, dataSource);
        [itemsProxy removeObjectsAtIndexes:deletedIndexes];
        
        // Deletion of single item
        deletedIndexes = [NSIndexSet indexSetWithIndex:1];
        deletedItems = [[mockDataSource items] objectsAtIndexes:deletedIndexes];
        prepareExpectations(deletedItems, deletedIndexes, dataSource);
        [mockDataSource removeItemAtIndex:[deletedIndexes firstIndex]];
        
        expect(^{ OCMVerifyAll(mockDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockChildDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockRootDataSource); }).notTo.raiseAny();
    });

    it(@"should invoke callbacks for items replace", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        MUKDataSource *dataSource = CreateDataSource();
        dataSource.items = @[@"A", @"B", @"C", @"D"];
        [rootDataSource appendChildDataSource:childDataSource];
        [childDataSource appendChildDataSource:dataSource];
        
        id mockRootDataSource = OCMPartialMock(rootDataSource);
        id mockChildDataSource = OCMPartialMock(childDataSource);
        id mockDataSource = OCMPartialMock(dataSource);
        NSMutableArray *itemsProxy = [mockDataSource mutableArrayValueForKey:@"items"];
        
        void (^prepareExpectations)(NSArray *, NSIndexSet *, MUKDataSource *) = ^(NSArray *oldItems, NSIndexSet *replacedIndexes, MUKDataSource *originatingDataSource)
        {
            OCMExpect([mockDataSource didReplaceItems:oldItems atIndexes:replacedIndexes inDataSource:originatingDataSource]).andForwardToRealObject();
            
            OCMExpect([mockChildDataSource didReplaceItems:oldItems atIndexes:replacedIndexes inDataSource:originatingDataSource]).andForwardToRealObject();
            
            OCMExpect([mockRootDataSource didReplaceItems:oldItems atIndexes:replacedIndexes inDataSource:originatingDataSource]);
        };
        
        // Replace multiple items
        NSIndexSet *replacedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
        NSArray *replacedItems = [[mockDataSource items] objectsAtIndexes:replacedIndexes];
        prepareExpectations(replacedItems, replacedIndexes, dataSource);
        [itemsProxy replaceObjectsAtIndexes:replacedIndexes withObjects:@[@"X", @"Y"]];
        
        // Replace single item
        replacedIndexes = [NSIndexSet indexSetWithIndex:3];
        replacedItems = [[mockDataSource items] objectsAtIndexes:replacedIndexes];
        prepareExpectations(replacedItems, replacedIndexes, dataSource);
        [mockDataSource replaceItemAtIndex:[replacedIndexes firstIndex] withItem:@"Z"];
        
        expect(^{ OCMVerifyAll(mockDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockChildDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockRootDataSource); }).notTo.raiseAny();
    });
    
    it(@"should invoke callbacks for items move", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        MUKDataSource *dataSource = CreateDataSource();
        dataSource.items = @[@"A", @"B", @"C", @"D"];
        [rootDataSource appendChildDataSource:childDataSource];
        [childDataSource appendChildDataSource:dataSource];
        
        id mockRootDataSource = OCMPartialMock(rootDataSource);
        id mockChildDataSource = OCMPartialMock(childDataSource);
        id mockDataSource = OCMPartialMock(dataSource);
        
        void (^prepareExpectations)(MUKDataSource *, NSInteger, MUKDataSource *, NSInteger) = ^(MUKDataSource *fromDataSource, NSInteger fromIndex, MUKDataSource *toDataSource, NSInteger toIndex)
        {
            OCMExpect([mockDataSource didMoveItemFromDataSource:fromDataSource atIndex:fromIndex toDataSource:toDataSource atIndex:toIndex eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            
            OCMExpect([mockChildDataSource didMoveItemFromDataSource:fromDataSource atIndex:fromIndex toDataSource:toDataSource atIndex:toIndex eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            
            OCMExpect([mockRootDataSource didMoveItemFromDataSource:fromDataSource atIndex:fromIndex toDataSource:toDataSource atIndex:toIndex eventOrigin:MUKDataSourceEventOriginProgrammatic]);
        };
        
        // Move item inside same data source
        MUKDataSource *fromDataSource = dataSource;
        MUKDataSource *toDataSource = dataSource;
        NSInteger fromIndex = 0;
        NSInteger toIndex = 1;
        prepareExpectations(fromDataSource, fromIndex, toDataSource, toIndex);
        [mockDataSource moveItemAtIndex:fromIndex toDataSource:toDataSource atIndex:toIndex];
        
        // Move item between data sources
        fromDataSource = dataSource;
        toDataSource = childDataSource;
        fromIndex = 2;
        toIndex = 0;
        prepareExpectations(fromDataSource, fromIndex, toDataSource, toIndex);
        [mockDataSource moveItemAtIndex:fromIndex toDataSource:toDataSource atIndex:toIndex];
        
        // Invalid moves does not generate callbacks
        [mockDataSource moveItemAtIndex:0 toDataSource:nil atIndex:0];
        
        expect(^{ OCMVerifyAll(mockDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockChildDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockRootDataSource); }).notTo.raiseAny();
    });
    
    it(@"should invoke callbacks for items overwriting without animation", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        MUKDataSource *dataSource = CreateDataSource();
        dataSource.items = @[@"A", @"B", @"C", @"D"];
        [rootDataSource appendChildDataSource:childDataSource];
        [childDataSource appendChildDataSource:dataSource];
        
        id mockRootDataSource = OCMPartialMock(rootDataSource);
        id mockChildDataSource = OCMPartialMock(childDataSource);
        id mockDataSource = OCMPartialMock(dataSource);
        
        void (^prepareExpectations)(NSInteger, MUKDataSource *) = ^(NSInteger idx, MUKDataSource *dataSource)
        {
            OCMExpect([mockDataSource didRefreshChildDataSourcesAtIndexes:[NSIndexSet indexSetWithIndex:idx] inDataSource:dataSource]).andForwardToRealObject();
            
            OCMExpect([mockChildDataSource didRefreshChildDataSourcesAtIndexes:[NSIndexSet indexSetWithIndex:idx] inDataSource:dataSource]).andForwardToRealObject();
            
            OCMExpect([mockRootDataSource didRefreshChildDataSourcesAtIndexes:[NSIndexSet indexSetWithIndex:idx] inDataSource:dataSource]);
        };
        
        NSArray *items = @[@"A", @"B"];
        prepareExpectations(0, dataSource.parentDataSource);
        [mockDataSource setItems:items animated:NO];
        
        // Setting same items does not generate callbacks
        [mockDataSource setItems:items animated:NO];
        
        expect(^{ OCMVerifyAll(mockDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockChildDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockRootDataSource); }).notTo.raiseAny();
    });
    
    it(@"should invoke callbacks for items overwriting with animation", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        MUKDataSource *dataSource = CreateDataSource();
        dataSource.items = @[@"A", @"B", @"C", @"D"];
        [rootDataSource appendChildDataSource:childDataSource];
        [childDataSource appendChildDataSource:dataSource];
        
        id mockRootDataSource = OCMPartialMock(rootDataSource);
        id mockChildDataSource = OCMPartialMock(childDataSource);
        id mockDataSource = OCMPartialMock(dataSource);
        
        void (^prepareExpectations)(NSInteger, MUKDataSource *) = ^(NSInteger idx, MUKDataSource *dataSource)
        {
            // A, B, C, D  ---> E, A, C
            void (^prepareInsertExpectation)(id) = ^(id mock) {
                // E in 0
                OCMExpect([mock didInsertItemsAtIndexes:[NSIndexSet indexSetWithIndex:0] toDataSource:dataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            };
            
            void (^prepareMoveExpectation)(id) = ^(id mock) {
                // A: 0 -> 1
                OCMExpect([mock didMoveItemFromDataSource:dataSource atIndex:0 toDataSource:dataSource atIndex:1 eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            };
            
            void (^prepareDeletionExpectation)(id) = ^(id mock) {
                // B, D: deleted
                NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
                [indexes addIndex:1];
                [indexes addIndex:3];
                
                OCMExpect([mock didRemoveItems:[OCMArg checkWithBlock:^BOOL(id obj) {
                    if ([obj isKindOfClass:[NSArray class]]) {
                        return [obj count] == 2 && [obj containsObject:@"B"] && [obj containsObject:@"D"];
                    }
                    
                    return NO;
                }] atIndexes:indexes fromDataSource:dataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            };
            
            OCMExpect([mockDataSource requestBatchUpdate:[OCMArg isNotNil]]).andForwardToRealObject();
            
            OCMExpect([mockDataSource didRequestBatchUpdate:[OCMArg isNotNil] fromDataSource:dataSource]).andForwardToRealObject();
            OCMExpect([mockChildDataSource didRequestBatchUpdate:[OCMArg isNotNil] fromDataSource:dataSource]).andForwardToRealObject();
            OCMExpect([mockRootDataSource didRequestBatchUpdate:[OCMArg isNotNil] fromDataSource:dataSource]).andDo(^(NSInvocation *invocation)
            {
                // Events contained inside batch are executed from here, instead
                // of delegate (which is not tested here)
                dispatch_block_t updateBlock;
                [invocation getArgument:&updateBlock atIndex:2];
                updateBlock();
            });
            
            // Inside batch I expect...
            prepareInsertExpectation(mockDataSource);
            prepareInsertExpectation(mockChildDataSource);
            prepareInsertExpectation(mockRootDataSource);
            
            prepareMoveExpectation(mockDataSource);
            prepareMoveExpectation(mockChildDataSource);
            prepareMoveExpectation(mockRootDataSource);
            
            prepareDeletionExpectation(mockDataSource);
            prepareDeletionExpectation(mockChildDataSource);
            prepareDeletionExpectation(mockRootDataSource);
        };
        
        NSArray *items = @[@"E", @"A", @"C"];
        prepareExpectations(0, dataSource);
        [mockDataSource setItems:items animated:YES];
        
        // Setting same items does not generate callbacks
        [mockDataSource setItems:items animated:YES];
        
        expect(^{ OCMVerifyAll(mockDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockChildDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockRootDataSource); }).notTo.raiseAny();
    });
    
    it(@"should invoke callbacks for child data sources insertion", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        MUKDataSource *dataSource = CreateDataSource();
        rootDataSource.childDataSources = childDataSource.childDataSources = dataSource.childDataSources = @[];
        [rootDataSource appendChildDataSource:childDataSource];
        [childDataSource appendChildDataSource:dataSource];
        
        id mockRootDataSource = OCMPartialMock(rootDataSource);
        id mockChildDataSource = OCMPartialMock(childDataSource);
        id mockDataSource = OCMPartialMock(dataSource);
        NSMutableArray *childDataSourcesProxy = [mockDataSource mutableArrayValueForKey:@"childDataSources"];
        
        void (^prepareExpectations)(NSIndexSet *, MUKDataSource *) = ^(NSIndexSet *insertedIndexSet, MUKDataSource *targetDataSource)
        {
            OCMExpect([mockDataSource didInsertChildDataSourcesAtIndexes:insertedIndexSet toDataSource:targetDataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            
            OCMExpect([mockChildDataSource didInsertChildDataSourcesAtIndexes:insertedIndexSet toDataSource:targetDataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            
            OCMExpect([mockRootDataSource didInsertChildDataSourcesAtIndexes:insertedIndexSet toDataSource:targetDataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]);
        };
        
        // Insertion of multiple child data sources
        NSIndexSet *insertedIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
        prepareExpectations(insertedIndexSet, dataSource);
        [childDataSourcesProxy insertObjects:@[CreateDataSource(), CreateDataSource()] atIndexes:insertedIndexSet];
        
        // Insertion of single child data source
        insertedIndexSet = [NSIndexSet indexSetWithIndex:2];
        prepareExpectations(insertedIndexSet, dataSource);
        [mockDataSource insertChildDataSource:CreateDataSource() atIndex:[insertedIndexSet firstIndex]];
        
        // Appending child data source
        insertedIndexSet = [NSIndexSet indexSetWithIndex:3];
        prepareExpectations(insertedIndexSet, dataSource);
        [mockDataSource appendChildDataSource:CreateDataSource()];
        
        // Invalid insertions will not cause any callback
        [mockDataSource insertChildDataSource:nil atIndex:0];
        [mockDataSource insertChildDataSource:[[mockDataSource childDataSources] lastObject] atIndex:0]; // Duplicate
        
        expect(^{ OCMVerifyAll(mockDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockChildDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockRootDataSource); }).notTo.raiseAny();
    });
    
    it(@"should invoke callbacks for items deletion", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        MUKDataSource *dataSource = CreateDataSource();
        dataSource.childDataSources = @[CreateDataSource(), CreateDataSource(), CreateDataSource(), CreateDataSource()];
        [rootDataSource appendChildDataSource:childDataSource];
        [childDataSource appendChildDataSource:dataSource];
        
        id mockRootDataSource = OCMPartialMock(rootDataSource);
        id mockChildDataSource = OCMPartialMock(childDataSource);
        id mockDataSource = OCMPartialMock(dataSource);
        NSMutableArray *childDataSourcesProxy = [mockDataSource mutableArrayValueForKey:@"childDataSources"];
        
        void (^prepareExpectations)(NSArray *, NSIndexSet *, MUKDataSource *) = ^(NSArray *deletedChildDataSources, NSIndexSet *deletedIndexes, MUKDataSource *originatingDataSource)
        {
            OCMExpect([mockDataSource didRemoveChildDataSources:deletedChildDataSources atIndexes:deletedIndexes fromDataSource:originatingDataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            
            OCMExpect([mockChildDataSource didRemoveChildDataSources:deletedChildDataSources atIndexes:deletedIndexes fromDataSource:originatingDataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            
            OCMExpect([mockRootDataSource didRemoveChildDataSources:deletedChildDataSources atIndexes:deletedIndexes fromDataSource:originatingDataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]);
        };
        
        // Deletion of multiple child data sources
        NSIndexSet *deletedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
        NSArray *deletedChildDataSources = [[mockDataSource childDataSources] objectsAtIndexes:deletedIndexes];
        prepareExpectations(deletedChildDataSources, deletedIndexes, dataSource);
        [childDataSourcesProxy removeObjectsAtIndexes:deletedIndexes];
        
        // Deletion of single child data source (by index)
        deletedIndexes = [NSIndexSet indexSetWithIndex:1];
        deletedChildDataSources = [[mockDataSource childDataSources] objectsAtIndexes:deletedIndexes];
        prepareExpectations(deletedChildDataSources, deletedIndexes, dataSource);
        [mockDataSource removeChildDataSourceAtIndex:[deletedIndexes firstIndex]];
        
        // Deletion of single child data source (by object)
        deletedIndexes = [NSIndexSet indexSetWithIndex:0];
        deletedChildDataSources = [[mockDataSource childDataSources] objectsAtIndexes:deletedIndexes];
        prepareExpectations(deletedChildDataSources, deletedIndexes, dataSource);
        [mockDataSource removeChildDataSource:[deletedChildDataSources firstObject]];
        
        // Illegal deletions does not generate callbacks
        [mockDataSource removeChildDataSource:CreateDataSource()]; // Not contained
        
        expect(^{ OCMVerifyAll(mockDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockChildDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockRootDataSource); }).notTo.raiseAny();
    });
    
    it(@"should invoke callbacks for child data source replace", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        MUKDataSource *dataSource = CreateDataSource();
        dataSource.childDataSources = @[CreateDataSource(), CreateDataSource(), CreateDataSource(), CreateDataSource()];
        [rootDataSource appendChildDataSource:childDataSource];
        [childDataSource appendChildDataSource:dataSource];
        
        id mockRootDataSource = OCMPartialMock(rootDataSource);
        id mockChildDataSource = OCMPartialMock(childDataSource);
        id mockDataSource = OCMPartialMock(dataSource);
        NSMutableArray *childDataSourcesProxy = [mockDataSource mutableArrayValueForKey:@"childDataSources"];
        
        void (^prepareExpectations)(NSArray *, NSIndexSet *, MUKDataSource *) = ^(NSArray *oldChildDataSources, NSIndexSet *replacedIndexes, MUKDataSource *originatingDataSource)
        {
            OCMExpect([mockDataSource didReplaceChildDataSources:oldChildDataSources atIndexes:replacedIndexes inDataSource:originatingDataSource]).andForwardToRealObject();
            
            OCMExpect([mockChildDataSource didReplaceChildDataSources:oldChildDataSources atIndexes:replacedIndexes inDataSource:originatingDataSource]).andForwardToRealObject();
            
            OCMExpect([mockRootDataSource didReplaceChildDataSources:oldChildDataSources atIndexes:replacedIndexes inDataSource:originatingDataSource]);
        };
        
        // Replace multiple child data sources
        NSIndexSet *replacedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
        NSArray *replacedChildDataSources = [[mockDataSource childDataSources] objectsAtIndexes:replacedIndexes];
        prepareExpectations(replacedChildDataSources, replacedIndexes, dataSource);
        [childDataSourcesProxy replaceObjectsAtIndexes:replacedIndexes withObjects:@[CreateDataSource(), CreateDataSource()]];
        
        // Replace single child data source
        replacedIndexes = [NSIndexSet indexSetWithIndex:3];
        replacedChildDataSources = [[mockDataSource childDataSources] objectsAtIndexes:replacedIndexes];
        prepareExpectations(replacedChildDataSources, replacedIndexes, dataSource);
        [mockDataSource replaceChildDataSourceAtIndex:[replacedIndexes firstIndex] withDataSource:CreateDataSource()];
        
        expect(^{ OCMVerifyAll(mockDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockChildDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockRootDataSource); }).notTo.raiseAny();
    });
    
    it(@"should invoke callbacks for child data source move", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        MUKDataSource *dataSource = CreateDataSource();
        dataSource.childDataSources = @[CreateDataSource(), CreateDataSource(), CreateDataSource(), CreateDataSource()];
        [rootDataSource appendChildDataSource:childDataSource];
        [childDataSource appendChildDataSource:dataSource];
        
        id mockRootDataSource = OCMPartialMock(rootDataSource);
        id mockChildDataSource = OCMPartialMock(childDataSource);
        id mockDataSource = OCMPartialMock(dataSource);
        
        void (^prepareExpectations)(MUKDataSource *, NSInteger, MUKDataSource *, NSInteger) = ^(MUKDataSource *fromDataSource, NSInteger fromIndex, MUKDataSource *toDataSource, NSInteger toIndex)
        {
            OCMExpect([mockDataSource didMoveChildDataSourceFromDataSource:fromDataSource atIndex:fromIndex toDataSource:toDataSource atIndex:toIndex eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            
            OCMExpect([mockChildDataSource didMoveChildDataSourceFromDataSource:fromDataSource atIndex:fromIndex toDataSource:toDataSource atIndex:toIndex eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            
            OCMExpect([mockRootDataSource didMoveChildDataSourceFromDataSource:fromDataSource atIndex:fromIndex toDataSource:toDataSource atIndex:toIndex eventOrigin:MUKDataSourceEventOriginProgrammatic]);
        };
        
        // Move child data sources inside same data source
        MUKDataSource *fromDataSource = dataSource;
        MUKDataSource *toDataSource = dataSource;
        NSInteger fromIndex = 0;
        NSInteger toIndex = 1;
        prepareExpectations(fromDataSource, fromIndex, toDataSource, toIndex);
        [mockDataSource moveChildDataSourceAtIndex:fromIndex toDataSource:toDataSource atIndex:toIndex];
        
        // Move child data sources between data sources
        fromDataSource = dataSource;
        toDataSource = childDataSource;
        fromIndex = 2;
        toIndex = 0;
        prepareExpectations(fromDataSource, fromIndex, toDataSource, toIndex);
        [mockDataSource moveChildDataSourceAtIndex:fromIndex toDataSource:toDataSource atIndex:toIndex];
        
        // Invalid moves does not generate callbacks
        [mockDataSource moveChildDataSourceAtIndex:0 toDataSource:nil atIndex:0];
        
        expect(^{ OCMVerifyAll(mockDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockChildDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockRootDataSource); }).notTo.raiseAny();
    });
    
    it(@"should invoke callbacks for child data sources overwriting without animation", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        MUKDataSource *dataSource = CreateDataSource();
        dataSource.childDataSources = @[CreateDataSource(), CreateDataSource(), CreateDataSource(), CreateDataSource()];
        [rootDataSource appendChildDataSource:childDataSource];
        [childDataSource appendChildDataSource:dataSource];
        
        id mockRootDataSource = OCMPartialMock(rootDataSource);
        id mockChildDataSource = OCMPartialMock(childDataSource);
        id mockDataSource = OCMPartialMock(dataSource);
        
        void (^prepareExpectations)(MUKDataSource *) = ^(MUKDataSource *dataSource)
        {
            OCMExpect([mockDataSource didReloadDataInDataSource:dataSource]).andForwardToRealObject();
            
            OCMExpect([mockChildDataSource didReloadDataInDataSource:dataSource]).andForwardToRealObject();
            
            OCMExpect([mockRootDataSource didReloadDataInDataSource:dataSource]);
        };
        
        NSArray *newChildDataSources = @[CreateDataSource(), CreateDataSource()];
        prepareExpectations(dataSource);
        [mockDataSource setChildDataSources:newChildDataSources animated:NO];
        
        // Setting same child data sources does not generate callbacks
        [mockDataSource setChildDataSources:newChildDataSources animated:NO];
        
        expect(^{ OCMVerifyAll(mockDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockChildDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockRootDataSource); }).notTo.raiseAny();
    });
    
    it(@"should invoke callbacks for child data sources overwriting with animation", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        MUKDataSource *dataSource = CreateDataSource();
        MUKDataSource *a = CreateDataSource();
        MUKDataSource *b = CreateDataSource();
        MUKDataSource *c = CreateDataSource();
        MUKDataSource *d = CreateDataSource();
        dataSource.childDataSources = @[a, b, c, d];
        [rootDataSource appendChildDataSource:childDataSource];
        [childDataSource appendChildDataSource:dataSource];
        
        id mockRootDataSource = OCMPartialMock(rootDataSource);
        id mockChildDataSource = OCMPartialMock(childDataSource);
        id mockDataSource = OCMPartialMock(dataSource);
        
        void (^prepareExpectations)(NSInteger, MUKDataSource *) = ^(NSInteger idx, MUKDataSource *dataSource)
        {
            // A, B, C, D  ---> E, A, C
            void (^prepareInsertExpectation)(id) = ^(id mock) {
                // E in 0
                OCMExpect([mock didInsertChildDataSourcesAtIndexes:[NSIndexSet indexSetWithIndex:0] toDataSource:dataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            };
            
            void (^prepareMoveExpectation)(id) = ^(id mock) {
                // A: 0 -> 1
                OCMExpect([mock didMoveChildDataSourceFromDataSource:dataSource atIndex:0 toDataSource:dataSource atIndex:1 eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            };
            
            void (^prepareDeletionExpectation)(id) = ^(id mock) {
                // B, D: deleted
                NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
                [indexes addIndex:1];
                [indexes addIndex:3];
                
                OCMExpect([mock didRemoveChildDataSources:[OCMArg checkWithBlock:^BOOL(id obj) {
                    if ([obj isKindOfClass:[NSArray class]]) {
                        return [obj count] == 2 && [obj containsObject:b] && [obj containsObject:d];
                    }
                    
                    return NO;
                }] atIndexes:indexes fromDataSource:dataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]).andForwardToRealObject();
            };
            
            OCMExpect([mockDataSource requestBatchUpdate:[OCMArg isNotNil]]).andForwardToRealObject();
            
            OCMExpect([mockDataSource didRequestBatchUpdate:[OCMArg isNotNil] fromDataSource:dataSource]).andForwardToRealObject();
            OCMExpect([mockChildDataSource didRequestBatchUpdate:[OCMArg isNotNil] fromDataSource:dataSource]).andForwardToRealObject();
            OCMExpect([mockRootDataSource didRequestBatchUpdate:[OCMArg isNotNil] fromDataSource:dataSource]).andDo(^(NSInvocation *invocation)
            {
                // Events contained inside batch are executed from here, instead
                // of delegate (which is not tested here)
                dispatch_block_t updateBlock;
                [invocation getArgument:&updateBlock atIndex:2];
                updateBlock();
            });
            
            // Inside batch I expect...
            prepareInsertExpectation(mockDataSource);
            prepareInsertExpectation(mockChildDataSource);
            prepareInsertExpectation(mockRootDataSource);
            
            prepareMoveExpectation(mockDataSource);
            prepareMoveExpectation(mockChildDataSource);
            prepareMoveExpectation(mockRootDataSource);
            
            prepareDeletionExpectation(mockDataSource);
            prepareDeletionExpectation(mockChildDataSource);
            prepareDeletionExpectation(mockRootDataSource);
        };
        
        NSArray *childDataSources = @[CreateDataSource() /*E*/, a, c];
        prepareExpectations(0, dataSource);
        [mockDataSource setChildDataSources:childDataSources animated:YES];
        
        // Setting same items does not generate callbacks
        [mockDataSource setChildDataSources:childDataSources animated:YES];
        
        expect(^{ OCMVerifyAll(mockDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockChildDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockRootDataSource); }).notTo.raiseAny();
    });
    
    it(@"should invoke callbacks for batch update request", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        MUKDataSource *dataSource = CreateDataSource();
        [rootDataSource appendChildDataSource:childDataSource];
        [childDataSource appendChildDataSource:dataSource];
        
        id mockRootDataSource = OCMPartialMock(rootDataSource);
        id mockChildDataSource = OCMPartialMock(childDataSource);
        id mockDataSource = OCMPartialMock(dataSource);
        
        void (^prepareExpectations)(dispatch_block_t, MUKDataSource *) = ^(dispatch_block_t updateBlock, MUKDataSource *dataSource)
        {
            OCMExpect([mockDataSource didRequestBatchUpdate:updateBlock fromDataSource:dataSource]).andForwardToRealObject();
            OCMExpect([mockChildDataSource didRequestBatchUpdate:updateBlock fromDataSource:dataSource]).andForwardToRealObject();
            OCMExpect([mockRootDataSource didRequestBatchUpdate:updateBlock fromDataSource:dataSource]).andDo(^(NSInvocation *invocation)
            {
                // Events contained inside batch are executed from here, instead
                // of delegate (which is not tested here)
                dispatch_block_t updateBlock;
                [invocation getArgument:&updateBlock atIndex:2];
                updateBlock();
            });
        };
        
        __block BOOL updateBlockCalled = NO;
        dispatch_block_t updateBlock = ^{
            updateBlockCalled = YES;
        };
        prepareExpectations(updateBlock, dataSource);
        [mockDataSource requestBatchUpdate:updateBlock];
        
        expect(updateBlock).to.beTruthy();
        expect(^{ OCMVerifyAll(mockDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockChildDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockRootDataSource); }).notTo.raiseAny();
    });
    
    it(@"should invoke callbacks for state transitions", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        MUKDataSource *dataSource = CreateDataSource();
        TKStateMachine *stateMachine = dataSource.stateMachine;
        
        id mockRootDataSource = OCMPartialMock(rootDataSource);
        id mockChildDataSource = OCMPartialMock(childDataSource);
        id mockDataSource = OCMPartialMock(dataSource);
        [mockRootDataSource appendChildDataSource:mockChildDataSource];
        [mockChildDataSource appendChildDataSource:mockDataSource];
        
        void (^prepareExpectations)(NSString *, NSString *, MUKDataSource *) = ^(NSString *sourceState, NSString *destinationState, MUKDataSource *dataSource)
        {
            for (id mock in @[mockDataSource, mockChildDataSource, mockRootDataSource])
            {
                OCMExpect([mock willTransitionToContentLoadingState:destinationState inDataSource:dataSource]).andForwardToRealObject();
                OCMExpect([mock didTransitionFromContentLoadingState:sourceState inDataSource:dataSource]).andForwardToRealObject();
            } // for
        };
        
        // Initial -> Loading
        prepareExpectations(dataSource.loadingState, MUKDataSourceContentLoadStateLoading, dataSource);
        [stateMachine fireEvent:MUKDataSourceContentLoadEventBeginLoading userInfo:nil error:nil];
        
        // Loading -> Loaded
        prepareExpectations(dataSource.loadingState, MUKDataSourceContentLoadStateLoaded, dataSource);
        [stateMachine fireEvent:MUKDataSourceContentLoadEventDisplayLoaded userInfo:nil error:nil];
        
        // Loaded -> Refreshing
        prepareExpectations(dataSource.loadingState, MUKDataSourceContentLoadStateRefreshing, dataSource);
        [stateMachine fireEvent:MUKDataSourceContentLoadEventBeginRefreshing userInfo:nil error:nil];
        
        // Refreshing -> Empty
        prepareExpectations(dataSource.loadingState, MUKDataSourceContentLoadStateEmpty, dataSource);
        [stateMachine fireEvent:MUKDataSourceContentLoadEventDisplayEmpty userInfo:nil error:nil];
        
        expect(^{ OCMVerifyAll(mockDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockChildDataSource); }).notTo.raiseAny();
        expect(^{ OCMVerifyAll(mockRootDataSource); }).notTo.raiseAny();
    });
    
    it(@"should invoke callbacks for content loading", ^{
        MUKDataSource *rootDataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        MUKDataSource *dataSource = CreateDataSource();
        
        id mockRootDataSource = OCMPartialMock(rootDataSource);
        id mockChildDataSource = OCMPartialMock(childDataSource);
        id mockDataSource = OCMPartialMock(dataSource);
        [mockRootDataSource appendChildDataSource:mockChildDataSource];
        [mockChildDataSource appendChildDataSource:mockDataSource];
        
        NSError *const error = [NSError errorWithDomain:@"Hi" code:0 userInfo:nil];
        MUKDataSourceContentLoadingResultType const resultType = MUKDataSourceContentLoadingResultTypeComplete;
        MUKDataSourceContentLoading *contentLoading = [[MUKDataSourceContentLoading alloc] init];
        id const contentLoadingMock = OCMPartialMock(contentLoading);
        __weak id weakContentLoadingMock = contentLoadingMock;
        [contentLoadingMock setJob:^{
            [weakContentLoadingMock finishWithResultType:resultType error:error update:nil];
        }];
        
        OCMStub([mockDataSource newContentLoadingForState:[OCMArg any]]).andReturn(contentLoadingMock);
        OCMStub([contentLoadingMock dataSource]).andReturn(mockDataSource);
        
        void (^prepareExpectations)(void) = ^() {
            for (id mock in @[mockDataSource, mockChildDataSource, mockRootDataSource])
            {
                OCMExpect([mock willLoadContent:contentLoadingMock]).andForwardToRealObject();
                OCMExpect([mock didLoadContent:contentLoading withResultType:resultType error:error]).andForwardToRealObject();
            } // for
        };
        
        // Load
        prepareExpectations();
        [mockDataSource setNeedsLoadContent];
        expect(^{ OCMVerifyAllWithDelay(mockDataSource, 0.1); }).notTo.raiseAny();
        expect(^{ OCMVerifyAllWithDelay(mockChildDataSource, 0.1); }).notTo.raiseAny();
        expect(^{ OCMVerifyAllWithDelay(mockRootDataSource, 0.1); }).notTo.raiseAny();
        
        // Append
        contentLoading.cancelled = NO;
        [mockDataSource setNeedsAppendContent];
        expect(^{ OCMVerifyAllWithDelay(mockDataSource, 0.1); }).notTo.raiseAny();
        expect(^{ OCMVerifyAllWithDelay(mockChildDataSource, 0.1); }).notTo.raiseAny();
        expect(^{ OCMVerifyAllWithDelay(mockRootDataSource, 0.1); }).notTo.raiseAny();
    });
});

#pragma mark Delegate
describe(@"Delegate", ^{
    it(@"should be invoked for child data sources insertion", ^{
        id delegateMock = OCMStrictProtocolMock(@protocol(MUKDataSourceDelegate));
        
        NSInteger index = 0;
        MUKDataSource *dataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        [dataSource appendChildDataSource:childDataSource];
        dataSource.delegate = delegateMock;
        
        OCMExpect([delegateMock dataSource:dataSource didInsertChildDataSourcesAtIndexes:[NSIndexSet indexSetWithIndex:index] toDataSource:childDataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]);
        
        [childDataSource insertChildDataSource:CreateDataSource() atIndex:index];
        expect(^{ OCMVerifyAll(delegateMock); }).notTo.raiseAny();
    });
    
    it(@"should be invoked for child data sources deletion", ^{
        id delegateMock = OCMStrictProtocolMock(@protocol(MUKDataSourceDelegate));
        
        NSInteger index = 0;
        MUKDataSource *dataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        [dataSource appendChildDataSource:childDataSource];
        [childDataSource appendChildDataSource:CreateDataSource()];
        dataSource.delegate = delegateMock;
        
        OCMExpect([delegateMock dataSource:dataSource didRemoveChildDataSources:childDataSource.childDataSources atIndexes:[NSIndexSet indexSetWithIndex:0] fromDataSource:childDataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]);
        
        [childDataSource removeChildDataSourceAtIndex:index];
        expect(^{ OCMVerifyAll(delegateMock); }).notTo.raiseAny();
    });
    
    it(@"should be invoked for child data sources replace", ^{
        id delegateMock = OCMStrictProtocolMock(@protocol(MUKDataSourceDelegate));
        
        NSInteger index = 0;
        MUKDataSource *dataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        [dataSource appendChildDataSource:childDataSource];
        [childDataSource appendChildDataSource:CreateDataSource()];
        dataSource.delegate = delegateMock;
        
        OCMExpect([delegateMock dataSource:dataSource didReplaceChildDataSources:childDataSource.childDataSources atIndexes:[NSIndexSet indexSetWithIndex:index] inDataSource:childDataSource]);
        
        [childDataSource replaceChildDataSourceAtIndex:index withDataSource:CreateDataSource()];
        expect(^{ OCMVerifyAll(delegateMock); }).notTo.raiseAny();
    });
    
    it(@"should be invoked for child data sources move", ^{
        id delegateMock = OCMStrictProtocolMock(@protocol(MUKDataSourceDelegate));
        
        NSInteger fromIndex = 0;
        NSInteger toIndex = 1;
        MUKDataSource *dataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        [dataSource appendChildDataSource:childDataSource];
        [childDataSource appendChildDataSource:CreateDataSource()];
        dataSource.delegate = delegateMock;
        
        OCMExpect([delegateMock dataSource:dataSource didMoveChildDataSourceFromDataSource:childDataSource atIndex:fromIndex toDataSource:dataSource atIndex:toIndex eventOrigin:MUKDataSourceEventOriginProgrammatic]);
        
        [childDataSource moveChildDataSourceAtIndex:fromIndex toDataSource:dataSource atIndex:toIndex];
        expect(^{ OCMVerifyAll(delegateMock); }).notTo.raiseAny();
    });
    
    it(@"should be invoked for child data sources refresh (items overwriting without animation)", ^{
        id delegateMock = OCMStrictProtocolMock(@protocol(MUKDataSourceDelegate));
        
        NSInteger index = 0;
        MUKDataSource *dataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        [dataSource appendChildDataSource:childDataSource];
        dataSource.delegate = delegateMock;
        
        OCMExpect([delegateMock dataSource:dataSource didRefreshChildDataSourcesAtIndexes:[NSIndexSet indexSetWithIndex:index] inDataSource:childDataSource.parentDataSource]);
        
        [childDataSource setItems:@[@"A", @"B"] animated:NO];
        expect(^{ OCMVerifyAll(delegateMock); }).notTo.raiseAny();
    });
    
    it(@"should be invoked for items insertion", ^{
        id delegateMock = OCMStrictProtocolMock(@protocol(MUKDataSourceDelegate));
        
        NSInteger index = 0;
        MUKDataSource *dataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        [dataSource appendChildDataSource:childDataSource];
        dataSource.delegate = delegateMock;
        
        OCMExpect([delegateMock dataSource:dataSource didInsertItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] toDataSource:childDataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]);
        
        [childDataSource insertItem:@"A" atIndex:index];
        expect(^{ OCMVerifyAll(delegateMock); }).notTo.raiseAny();
    });
    
    it(@"should be invoked for items deletion", ^{
        id delegateMock = OCMStrictProtocolMock(@protocol(MUKDataSourceDelegate));
        
        NSInteger index = 0;
        MUKDataSource *dataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        [dataSource appendChildDataSource:childDataSource];
        childDataSource.items = @[@"A"];
        dataSource.delegate = delegateMock;
        
        OCMExpect([delegateMock dataSource:dataSource didRemoveItems:childDataSource.items atIndexes:[NSIndexSet indexSetWithIndex:index] fromDataSource:childDataSource eventOrigin:MUKDataSourceEventOriginProgrammatic]);
        
        [childDataSource removeItemAtIndex:index];
        expect(^{ OCMVerifyAll(delegateMock); }).notTo.raiseAny();
    });
    
    it(@"should be invoked for item replace", ^{
        id delegateMock = OCMStrictProtocolMock(@protocol(MUKDataSourceDelegate));
        
        NSInteger index = 0;
        MUKDataSource *dataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        [dataSource appendChildDataSource:childDataSource];
        childDataSource.items = @[@"A"];
        dataSource.delegate = delegateMock;
        
        OCMExpect([delegateMock dataSource:dataSource didReplaceItems:childDataSource.items atIndexes:[NSIndexSet indexSetWithIndex:index] inDataSource:childDataSource]);
        
        [childDataSource replaceItemAtIndex:index withItem:@"B"];
        expect(^{ OCMVerifyAll(delegateMock); }).notTo.raiseAny();
    });
    
    it(@"should be invoked for item move", ^{
        id delegateMock = OCMStrictProtocolMock(@protocol(MUKDataSourceDelegate));
        
        NSInteger fromIndex = 0;
        NSInteger toIndex = 1;
        MUKDataSource *dataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        [dataSource appendChildDataSource:childDataSource];
        dataSource.items = @[@"A"];
        childDataSource.items = @[@"B"];
        dataSource.delegate = delegateMock;
        
        OCMExpect([delegateMock dataSource:dataSource didMoveItemFromDataSource:childDataSource atIndex:fromIndex toDataSource:dataSource atIndex:toIndex eventOrigin:MUKDataSourceEventOriginProgrammatic]);
        
        [childDataSource moveItemAtIndex:fromIndex toDataSource:dataSource atIndex:toIndex];
        expect(^{ OCMVerifyAll(delegateMock); }).notTo.raiseAny();
    });
    
    it(@"should be invoked for reload data (data sources overwrite without animation)", ^{
        id delegateMock = OCMStrictProtocolMock(@protocol(MUKDataSourceDelegate));
        
        MUKDataSource *dataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        [dataSource appendChildDataSource:childDataSource];
        dataSource.delegate = delegateMock;
        
        OCMExpect([delegateMock dataSource:dataSource didReloadDataInDataSource:childDataSource]);
        
        [childDataSource setChildDataSources:@[CreateDataSource()] animated:NO];
        expect(^{ OCMVerifyAll(delegateMock); }).notTo.raiseAny();
    });
    
    it(@"should be invoked for batch requests", ^{
        id delegateMock = OCMStrictProtocolMock(@protocol(MUKDataSourceDelegate));
        
        MUKDataSource *dataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        [dataSource appendChildDataSource:childDataSource];
        dataSource.delegate = delegateMock;
        
        dispatch_block_t updateBlock = ^{};
        OCMExpect([delegateMock dataSource:dataSource didRequestBatchUpdate:updateBlock fromDataSource:childDataSource]);
        
        [childDataSource requestBatchUpdate:updateBlock];
        expect(^{ OCMVerifyAll(delegateMock); }).notTo.raiseAny();
    });
    
    it(@"should be invoked for state transitions", ^{
        id delegateMock = OCMProtocolMock(@protocol(MUKDataSourceDelegate));
        
        MUKDataSource *dataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        [dataSource appendChildDataSource:childDataSource];
        dataSource.delegate = delegateMock;
        
        void (^prepareExpectations)(NSString *, NSString *) = ^(NSString *sourceState, NSString *destinationState) {
            OCMExpect([delegateMock dataSource:dataSource willTransitionToContentLoadingState:destinationState inDataSource:childDataSource]);
            OCMExpect([delegateMock dataSource:dataSource didTransitionFromContentLoadingState:sourceState inDataSource:childDataSource]);
        };
        
        // Initial -> Loading
        prepareExpectations(childDataSource.loadingState, MUKDataSourceContentLoadStateLoading);
        [childDataSource.stateMachine fireEvent:MUKDataSourceContentLoadEventBeginLoading userInfo:nil error:nil];

        // Loading -> Loaded
        prepareExpectations(childDataSource.loadingState, MUKDataSourceContentLoadStateLoaded);
        [childDataSource.stateMachine fireEvent:MUKDataSourceContentLoadEventDisplayLoaded userInfo:nil error:nil];

        // Loaded -> Refreshing
        prepareExpectations(childDataSource.loadingState, MUKDataSourceContentLoadStateRefreshing);
        [childDataSource.stateMachine fireEvent:MUKDataSourceContentLoadEventBeginRefreshing userInfo:nil error:nil];
        
        // Refreshing -> Empty
        prepareExpectations(childDataSource.loadingState, MUKDataSourceContentLoadStateEmpty);
        [childDataSource.stateMachine fireEvent:MUKDataSourceContentLoadEventDisplayEmpty userInfo:nil error:nil];
       
        expect(^{ OCMVerifyAll(delegateMock); }).notTo.raiseAny();
    });
    
    it(@"should be invoked for content loading", ^{
        id delegateMock = OCMProtocolMock(@protocol(MUKDataSourceDelegate));
        
        MUKDataSource *dataSource = CreateDataSource();
        MUKDataSource *childDataSource = CreateDataSource();
        id childDataSourceMock = OCMPartialMock(childDataSource);

        [dataSource appendChildDataSource:childDataSourceMock];
        dataSource.delegate = delegateMock;
        
        MUKDataSourceContentLoading *contentLoading = [[MUKDataSourceContentLoading alloc] init];
        MUKDataSourceContentLoadingResultType resultType = MUKDataSourceContentLoadingResultTypeComplete;
        NSError *error = [NSError errorWithDomain:@"Hi" code:0 userInfo:nil];
        __weak MUKDataSourceContentLoading *weakContentLoading = contentLoading;
        contentLoading.job = ^{
            [weakContentLoading finishWithResultType:resultType error:error update:nil];
        };
        
        OCMStub([childDataSourceMock newContentLoadingForState:[OCMArg any]]).andReturn(contentLoading);
        
        void (^prepareExpectations)(void) = ^{
            OCMExpect([delegateMock dataSource:dataSource willLoadContent:contentLoading]);
            OCMExpect([delegateMock dataSource:dataSource didLoadContent:contentLoading withResultType:resultType error:error]);
        };
        
        prepareExpectations();
        [childDataSourceMock setNeedsLoadContent];
        expect(^{ OCMVerifyAllWithDelay(delegateMock, 0.1); }).notTo.raiseAny();
        
        prepareExpectations();
        contentLoading.cancelled = NO;
        [childDataSourceMock setNeedsAppendContent];
        expect(^{ OCMVerifyAllWithDelay(delegateMock, 0.1); }).notTo.raiseAny();
    });
});

SpecEnd

#pragma mark - Content Loading
SpecBegin(ContentLoading)

#pragma mark State
describe(@"State", ^{
    it(@"should start at initial state", ^{
        MUKDataSource *dataSource = CreateDataSource();
        expect(dataSource.loadingState).to.equal(MUKDataSourceContentLoadStateInitial);
    });
});
         
describe(@"Content loading", ^{
    it(@"should delay content loading", ^{
        id dataSourceMock = OCMPartialMock(CreateDataSource());
        OCMExpect([dataSourceMock loadContent]);
        [dataSourceMock setNeedsLoadContent];
        expect(^{ OCMVerifyAllWithDelay(dataSourceMock, 0.1); }).notTo.raiseAny();
        
        OCMExpect([dataSourceMock appendContent]);
        [dataSourceMock setNeedsAppendContent];
        expect(^{ OCMVerifyAllWithDelay(dataSourceMock, 0.1); }).notTo.raiseAny();
    });
    
    it(@"should create content loading on the fly", ^{
        id dataSourceMock = OCMPartialMock(CreateDataSource());
        NSString *const firstLoadingState = MUKDataSourceContentLoadStateLoading;
        OCMExpect([dataSourceMock newContentLoadingForState:firstLoadingState]);
        
        [dataSourceMock setNeedsLoadContent];
        expect(^{ OCMVerifyAllWithDelay(dataSourceMock, 0.1); }).notTo.raiseAny();
    });
    
    it(@"should update its data source", ^{
        MUKDataSource *dataSource = CreateDataSource();
        id dataSourceMock = OCMPartialMock(dataSource);
        
        MUKDataSourceContentLoadingResultType resultType = MUKDataSourceContentLoadingResultTypeComplete;
        MUKDataSourceContentLoading *contentLoading = [[MUKDataSourceContentLoading alloc] init];
        __weak MUKDataSourceContentLoading *weakContentLoading = contentLoading;
        __block BOOL jobBlockCalled = NO;
        __block BOOL updateBlockCalled = NO;
        dispatch_block_t updateBlock = ^{
            updateBlockCalled = YES;
        };
        contentLoading.job = ^{
            jobBlockCalled = YES;
            [weakContentLoading finishWithResultType:resultType error:nil update:updateBlock];
        };
        OCMStub([dataSourceMock newContentLoadingForState:[OCMArg any]]).andReturn(contentLoading);
        
        OCMExpect([dataSource didFinishContentLoading:contentLoading withResultType:resultType error:nil update:updateBlock]);
        [dataSourceMock setNeedsLoadContent];
        
        expect(jobBlockCalled).will.beTruthy();
        expect(updateBlockCalled).will.beTruthy();
        expect(^{ OCMVerifyAllWithDelay(dataSourceMock, 0.1); }).notTo.raiseAny();
    });
    
    it(@"should coalesce consecutive content loadings", ^{
        MUKDataSource *dataSource = CreateDataSource();
        id dataSourceMock = OCMPartialMock(dataSource);
        
        OCMExpect([dataSourceMock loadContent]);
        
        [dataSourceMock setNeedsLoadContent];
        [dataSourceMock setNeedsLoadContent];
        
        expect(^{ OCMVerifyAllWithDelay(dataSourceMock, 0.1); }).toNot.raiseAny();
    });
    
    describe(@"should cancel previous content loading", ^{
        MUKDataSourceContentLoading *contentLoading = [[MUKDataSourceContentLoading alloc] init];
        expect(contentLoading.isCancelled).to.beFalsy();
        
        [contentLoading cancel];
        expect(contentLoading.isCancelled).to.beTruthy();
        
        NSArray *contentLoadings = @[[[MUKDataSourceContentLoading alloc] init], [[MUKDataSourceContentLoading alloc] init]];
        NSInteger contentLoadingIndex = 0;
        MUKDataSource *dataSource = CreateDataSource();
        id dataSourceMock = OCMPartialMock(dataSource);
        OCMStub([dataSourceMock newContentLoadingForState:[OCMArg any]]).andReturn(contentLoadings[contentLoadingIndex++]);
        
        [dataSourceMock setNeedsLoadContent];
        
        it(@"", ^AsyncBlock {
            [dataSourceMock setNeedsLoadContent];
            
            expect([contentLoadings[0] isCancelled]).will.beTruthy();
            expect([contentLoadings[1] isCancelled]).will.beFalsy();
            expect(contentLoadingIndex).will.equal([contentLoadings count]-1);
            
            done();
        });
    });
});

SpecEnd

#pragma mark - Table View
SpecBegin(TableView)

#pragma mark Conversions
describe(@"Conversions", ^{
    MUKDataSource *dataSource = CreateDataSource();
    MUKDataSource *dataSource_0 = CreateDataSource();
    MUKDataSource *dataSource_1 = CreateDataSource();
    dataSource.childDataSources = @[dataSource_0, dataSource_1];
    dataSource.items = @[@"A"];
    dataSource_0.items = @[@"B", @"C"];
    dataSource_1.items = @[@"D"];
    
    it(@"should map table sections to child data source indexes", ^{
        expect([dataSource childDataSourceIndexFromTableViewSection:0 checkingBounds:YES]).to.equal(0);
        expect([dataSource childDataSourceIndexFromTableViewSection:1 checkingBounds:YES]).to.equal(1);
        expect([dataSource childDataSourceIndexFromTableViewSection:2 checkingBounds:YES]).to.equal(NSNotFound);
        expect([dataSource childDataSourceIndexFromTableViewSection:-1 checkingBounds:YES]).to.equal(NSNotFound);
        
        expect([dataSource childDataSourceIndexFromTableViewSection:0 checkingBounds:NO]).to.equal(0);
        expect([dataSource childDataSourceIndexFromTableViewSection:1 checkingBounds:NO]).to.equal(1);
        expect([dataSource childDataSourceIndexFromTableViewSection:2 checkingBounds:NO]).to.equal(2);
        expect([dataSource childDataSourceIndexFromTableViewSection:-1 checkingBounds:NO]).to.equal(-1);
    });
    
    it(@"should map table rows to item indexes", ^{
        expect([dataSource_0 itemIndexFromTableViewRow:0 checkingBounds:YES]).to.equal(0);
        expect([dataSource_0 itemIndexFromTableViewRow:1 checkingBounds:YES]).to.equal(1);
        expect([dataSource_0 itemIndexFromTableViewRow:2 checkingBounds:YES]).to.equal(NSNotFound);
        expect([dataSource_0 itemIndexFromTableViewRow:-1 checkingBounds:YES]).to.equal(NSNotFound);
        
        expect([dataSource_0 itemIndexFromTableViewRow:0 checkingBounds:NO]).to.equal(0);
        expect([dataSource_0 itemIndexFromTableViewRow:1 checkingBounds:NO]).to.equal(1);
        expect([dataSource_0 itemIndexFromTableViewRow:2 checkingBounds:NO]).to.equal(2);
        expect([dataSource_0 itemIndexFromTableViewRow:-1 checkingBounds:NO]).to.equal(-1);
    });
    
    it(@"should map table index paths to item index paths", ^{
        NSIndexPath *indexPath, *expectedIndexPath;
        indexPath = expectedIndexPath = IndexPathWithIndexes(@[@0, @0]);
        expect([dataSource itemIndexPathFromTableViewIndexPath:indexPath checkingBounds:YES]).to.equal(expectedIndexPath);
        indexPath = expectedIndexPath = IndexPathWithIndexes(@[@0, @1]);
        expect([dataSource itemIndexPathFromTableViewIndexPath:indexPath checkingBounds:YES]).to.equal(expectedIndexPath);
        indexPath = expectedIndexPath = IndexPathWithIndexes(@[@1, @0]);
        expect([dataSource itemIndexPathFromTableViewIndexPath:indexPath checkingBounds:YES]).to.equal(expectedIndexPath);
        indexPath = expectedIndexPath = IndexPathWithIndexes(@[@0, @100]);
        expect([dataSource itemIndexPathFromTableViewIndexPath:indexPath checkingBounds:YES]).to.beNil;
        indexPath = IndexPathWithIndexes(@[@100, @0]);
        expect([dataSource itemIndexPathFromTableViewIndexPath:indexPath checkingBounds:YES]).to.beNil;
        indexPath = IndexPathWithIndexes(@[@100, @100]);
        expect([dataSource itemIndexPathFromTableViewIndexPath:indexPath checkingBounds:YES]).to.beNil;
        
        indexPath = expectedIndexPath = IndexPathWithIndexes(@[@0, @0]);
        expect([dataSource itemIndexPathFromTableViewIndexPath:indexPath checkingBounds:NO]).to.equal(expectedIndexPath);
        indexPath = expectedIndexPath = IndexPathWithIndexes(@[@0, @1]);
        expect([dataSource itemIndexPathFromTableViewIndexPath:indexPath checkingBounds:NO]).to.equal(expectedIndexPath);
        indexPath = expectedIndexPath = IndexPathWithIndexes(@[@1, @0]);
        expect([dataSource itemIndexPathFromTableViewIndexPath:indexPath checkingBounds:NO]).to.equal(expectedIndexPath);
        indexPath = expectedIndexPath = IndexPathWithIndexes(@[@0, @100]);
        expect([dataSource itemIndexPathFromTableViewIndexPath:indexPath checkingBounds:NO]).to.equal(expectedIndexPath);
        indexPath = expectedIndexPath = IndexPathWithIndexes(@[@100, @0]);
        expect([dataSource itemIndexPathFromTableViewIndexPath:indexPath checkingBounds:NO]).to.equal(expectedIndexPath);
        indexPath = expectedIndexPath = IndexPathWithIndexes(@[@100, @100]);
        expect([dataSource itemIndexPathFromTableViewIndexPath:indexPath checkingBounds:NO]).to.equal(expectedIndexPath);
    });
    
    it(@"should map child data source indexes to table sections", ^{
        expect([dataSource tableViewSectionFromChildDataSourceIndex:0 checkingBounds:YES]).to.equal(0);
        expect([dataSource tableViewSectionFromChildDataSourceIndex:1 checkingBounds:YES]).to.equal(1);
        expect([dataSource tableViewSectionFromChildDataSourceIndex:2 checkingBounds:YES]).to.equal(NSNotFound);
        expect([dataSource tableViewSectionFromChildDataSourceIndex:-1 checkingBounds:YES]).to.equal(NSNotFound);
        
        expect([dataSource tableViewSectionFromChildDataSourceIndex:0 checkingBounds:NO]).to.equal(0);
        expect([dataSource tableViewSectionFromChildDataSourceIndex:1 checkingBounds:NO]).to.equal(1);
        expect([dataSource tableViewSectionFromChildDataSourceIndex:2 checkingBounds:NO]).to.equal(2);
        expect([dataSource tableViewSectionFromChildDataSourceIndex:-1 checkingBounds:NO]).to.equal(-1);
        
        NSIndexSet *indexes, *expectedIndexes;
        indexes = expectedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
        expect([dataSource tableViewSectionsFromChildDataSourceIndexes:indexes checkingBounds:YES]).to.equal(expectedIndexes);

        indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 100)];
        expectedIndexes = [NSIndexSet indexSetWithIndex:1];
        expect([dataSource tableViewSectionsFromChildDataSourceIndexes:indexes checkingBounds:YES]).to.equal(expectedIndexes);
        
        indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 100)];
        expect([dataSource tableViewSectionsFromChildDataSourceIndexes:indexes checkingBounds:YES]).to.beNil;
        
        indexes = expectedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
        expect([dataSource tableViewSectionsFromChildDataSourceIndexes:indexes checkingBounds:NO]).to.equal(expectedIndexes);
        
        indexes = expectedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 100)];
        expect([dataSource tableViewSectionsFromChildDataSourceIndexes:indexes checkingBounds:NO]).to.equal(expectedIndexes);
        
        indexes = expectedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 100)];
        expect([dataSource tableViewSectionsFromChildDataSourceIndexes:indexes checkingBounds:NO]).to.beNil;
    });
    
    it(@"should map item indexes to table rows", ^{
        expect([dataSource_0 tableViewRowFromItemIndex:0 checkingBounds:YES]).to.equal(0);
        expect([dataSource_0 tableViewRowFromItemIndex:1 checkingBounds:YES]).to.equal(1);
        expect([dataSource_0 tableViewRowFromItemIndex:2 checkingBounds:YES]).to.equal(NSNotFound);
        expect([dataSource_0 tableViewRowFromItemIndex:-1 checkingBounds:YES]).to.equal(NSNotFound);
        
        expect([dataSource_0 tableViewRowFromItemIndex:0 checkingBounds:NO]).to.equal(0);
        expect([dataSource_0 tableViewRowFromItemIndex:1 checkingBounds:NO]).to.equal(1);
        expect([dataSource_0 tableViewRowFromItemIndex:2 checkingBounds:NO]).to.equal(2);
        expect([dataSource_0 tableViewRowFromItemIndex:-1 checkingBounds:NO]).to.equal(-1);
    });
    
    it(@"should map item index paths to table index paths", ^{
        NSIndexPath *indexPath, *expectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        expect([dataSource tableViewIndexPathFromItemIndexPath:indexPath checkingBounds:YES]).to.equal(expectedIndexPath);
        indexPath = expectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        expect([dataSource tableViewIndexPathFromItemIndexPath:indexPath checkingBounds:YES]).to.equal(expectedIndexPath);
        indexPath = expectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        expect([dataSource tableViewIndexPathFromItemIndexPath:indexPath checkingBounds:YES]).to.equal(expectedIndexPath);
        indexPath = expectedIndexPath = [NSIndexPath indexPathForRow:100 inSection:0];
        expect([dataSource tableViewIndexPathFromItemIndexPath:indexPath checkingBounds:YES]).to.beNil;
        indexPath = [NSIndexPath indexPathForRow:0 inSection:100];
        expect([dataSource tableViewIndexPathFromItemIndexPath:indexPath checkingBounds:YES]).to.beNil;
        indexPath = [NSIndexPath indexPathForRow:100 inSection:100];
        expect([dataSource tableViewIndexPathFromItemIndexPath:indexPath checkingBounds:YES]).to.beNil;
        
        indexPath = expectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        expect([dataSource tableViewIndexPathFromItemIndexPath:indexPath checkingBounds:NO]).to.equal(expectedIndexPath);
        indexPath = expectedIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        expect([dataSource tableViewIndexPathFromItemIndexPath:indexPath checkingBounds:NO]).to.equal(expectedIndexPath);
        indexPath = expectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        expect([dataSource tableViewIndexPathFromItemIndexPath:indexPath checkingBounds:NO]).to.equal(expectedIndexPath);
        indexPath = expectedIndexPath = [NSIndexPath indexPathForRow:100 inSection:0];
        expect([dataSource tableViewIndexPathFromItemIndexPath:indexPath checkingBounds:NO]).to.equal(expectedIndexPath);
        indexPath = expectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:100];
        expect([dataSource tableViewIndexPathFromItemIndexPath:indexPath checkingBounds:NO]).to.equal(expectedIndexPath);
        indexPath = expectedIndexPath = [NSIndexPath indexPathForRow:100 inSection:100];
        expect([dataSource tableViewIndexPathFromItemIndexPath:indexPath checkingBounds:NO]).to.equal(expectedIndexPath);
    });
    
    it(@"should map item index paths to table index paths using implicit section", ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        expect([dataSource_0 tableViewIndexPathFromItemIndex:1 checkingBounds:YES]).to.equal(indexPath);
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        expect([dataSource_1 tableViewIndexPathFromItemIndex:0 checkingBounds:YES]).to.equal(indexPath);
        expect([dataSource_0 tableViewIndexPathFromItemIndex:100 checkingBounds:YES]).to.beNil;
        expect([dataSource tableViewIndexPathFromItemIndex:0 checkingBounds:YES]).to.beNil;
        
        indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        expect([dataSource_0 tableViewIndexPathFromItemIndex:1 checkingBounds:NO]).to.equal(indexPath);
        indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        expect([dataSource_1 tableViewIndexPathFromItemIndex:0 checkingBounds:NO]).to.equal(indexPath);
        indexPath = [NSIndexPath indexPathForRow:100 inSection:0];
        expect([dataSource_0 tableViewIndexPathFromItemIndex:100 checkingBounds:NO]).to.equal(indexPath);
        expect([dataSource tableViewIndexPathFromItemIndex:0 checkingBounds:NO]).to.beNil;
        
        // In groups
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
        NSArray *indexPaths = @[[NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:1 inSection:0]];
        expect([dataSource_0 tableViewIndexPathsFromItemIndexes:indexes checkingBounds:YES]).to.equal(indexPaths);
        
        indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
        indexPaths = @[[NSIndexPath indexPathForRow:0 inSection:1]];
        expect([dataSource_1 tableViewIndexPathsFromItemIndexes:indexes checkingBounds:YES]).to.equal(indexPaths);
        
        indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 2)];
        expect([dataSource_0 tableViewIndexPathsFromItemIndexes:indexes checkingBounds:YES]).to.beNil;
        
        indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
        expect([dataSource tableViewIndexPathsFromItemIndexes:indexes checkingBounds:YES]).to.beNil;
        
        indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
        indexPaths = @[[NSIndexPath indexPathForRow:0 inSection:0], [NSIndexPath indexPathForRow:1 inSection:0]];
        expect([dataSource_0 tableViewIndexPathsFromItemIndexes:indexes checkingBounds:NO]).to.equal(indexPaths);
        
        indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
        indexPaths = @[[NSIndexPath indexPathForRow:1 inSection:1], [NSIndexPath indexPathForRow:2 inSection:1]];
        expect([dataSource_1 tableViewIndexPathsFromItemIndexes:indexes checkingBounds:NO]).to.equal(indexPaths);
        
        indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 1)];
        indexPath = [NSIndexPath indexPathForRow:100 inSection:0];
        expect([dataSource_0 tableViewIndexPathsFromItemIndexes:indexes checkingBounds:NO]).to.beNil;
        
        indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 1)];
        expect([dataSource tableViewIndexPathsFromItemIndexes:indexes checkingBounds:NO]).to.beNil;
    });

});

#pragma mark Structure
describe(@"Structure", ^{
    it(@"should create a section per child data source", ^{
        MUKDataSource *dataSource = CreateDataSource();
        dataSource.childDataSources = @[CreateDataSource(), CreateDataSource(), CreateDataSource()];
        expect([dataSource numberOfSectionsInTableView:nil]).to.equal([dataSource.childDataSources count]);
    });
    
    it(@"should create a row per item", ^{
        MUKDataSource *dataSource = CreateDataSource();
        dataSource.childDataSources = @[CreateDataSource(), CreateDataSource(), CreateDataSource()];
        [dataSource childDataSourceAtIndex:0].items = @[@"A", @"B"];
        [dataSource childDataSourceAtIndex:1].items = @[@"C", @"D", @"E"];
        
        expect([dataSource tableView:nil numberOfRowsInSection:0]).to.equal([[dataSource childDataSourceAtIndex:0].items count]);
        expect([dataSource tableView:nil numberOfRowsInSection:1]).to.equal([[dataSource childDataSourceAtIndex:1].items count]);
        expect([dataSource tableView:nil numberOfRowsInSection:2]).to.equal([[dataSource childDataSourceAtIndex:2].items count]);
    });
    
    it(@"should provide a default header title", ^{
        MUKDataSource *dataSource = CreateDataSource();
        dataSource.childDataSources = @[CreateDataSource(), CreateDataSource()];
        [dataSource childDataSourceAtIndex:0].title = @"A";
        [dataSource childDataSourceAtIndex:1].title = @"B";
        
        expect([dataSource tableView:nil titleForHeaderInSection:0]).to.equal([dataSource childDataSourceAtIndex:0].title);
        expect([dataSource tableView:nil titleForHeaderInSection:1]).to.equal([dataSource childDataSourceAtIndex:1].title);
    });
    
    it(@"should be passive for other data", ^{
        MUKDataSource *dataSource = CreateDataSource();
        dataSource.childDataSources = @[CreateDataSource(), CreateDataSource()];
        [dataSource childDataSourceAtIndex:0].items = @[@"A", @"B"];
        [dataSource childDataSourceAtIndex:1].items = @[@"C", @"D", @"E"];
        
        expect([dataSource dequeueOrCreateCellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inTableView:nil]).to.beNil;
        expect([dataSource titleForFooterInSection:0 tableView:nil]).to.beNil;
        expect([dataSource canEditRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inTableView:nil]).to.beFalsy;
        expect([dataSource canMoveRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inTableView:nil]).to.beFalsy;
        expect([dataSource newItemToInsertByCommittingRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] inTableView:nil]).to.beNil;
    });
    
    it(@"should get table data from data source", ^{
        id dataSourceMock = OCMPartialMock(CreateDataSource());
        [dataSourceMock setChildDataSources:@[OCMPartialMock(CreateDataSource()), OCMPartialMock(CreateDataSource())]];
        
        [dataSourceMock childDataSourceAtIndex:0].items = @[@"A", @"B"];
        [dataSourceMock childDataSourceAtIndex:1].items = @[@"C"];
   
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 800.0f) style:UITableViewStylePlain];
        tableView.dataSource = dataSourceMock;
        
        // Setup expectations
        for (NSInteger section = 0; section < [[dataSourceMock childDataSources] count]; section++)
        {
            id sectionDataSourceMock = [dataSourceMock childDataSourceAtIndex:section];
            OCMExpect([sectionDataSourceMock numberOfRowsForSection:section inTableView:tableView]).andForwardToRealObject();
            OCMExpect([sectionDataSourceMock titleForHeaderInSection:section tableView:tableView]).andForwardToRealObject();
            OCMExpect([sectionDataSourceMock titleForFooterInSection:section tableView:tableView]).andForwardToRealObject();
            
            for (NSInteger row = 0; row < [[sectionDataSourceMock items] count]; row++)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                OCMExpect([sectionDataSourceMock dequeueOrCreateCellForRowAtIndexPath:indexPath inTableView:tableView]).andReturn(cell);
                OCMExpect([sectionDataSourceMock configureCell:cell forRowAtIndexPath:indexPath inTableView:tableView]);
                
                OCMExpect([sectionDataSourceMock canEditRowAtIndexPath:indexPath inTableView:tableView]);
            } // for row
        } // for section
        
        // Fire composition
        [tableView reloadData];
        
        for (NSInteger section = 0; section < [[dataSourceMock childDataSources] count]; section++)
        {
            id sectionDataSourceMock = [dataSourceMock childDataSourceAtIndex:section];

            for (NSInteger row = 0; row < [[sectionDataSourceMock items] count]; row++)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
                [tableView cellForRowAtIndexPath:indexPath];
            } // for row
        } // for section
        
        tableView.editing = YES;
        
        expect(^{ OCMVerifyAll(dataSourceMock); }).notTo.raiseAny();
        expect(^{
            for (id mock in [dataSourceMock childDataSources]) {
                OCMVerifyAll(mock);
            }
        }).notTo.raiseAny();
    });
});

SpecEnd
