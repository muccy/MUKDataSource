#import <MUKDataSource/MUKDataSource.h>

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

SpecBegin(Main)

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

SpecEnd
