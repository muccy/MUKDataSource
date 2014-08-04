#import <MUKDataSource/MUKDataSource.h>

static inline MUKDataSource *CreateDataSource(void) {
    return [[MUKDataSource alloc] init];
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
        XCTAssertThrows(([itemsProxy addObjectsFromArray:@[@"A", @"B"]]), @"items key points to nil");
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
    
    it(@"should find item index", ^{
        dataSource.items = @[@"A", @"B"];
        expect([dataSource indexOfItem:@"A"]).to.equal(0);
        expect([dataSource indexOfItem:@"B"]).to.equal(1);
        expect([dataSource indexOfItem:@"©"]).to.equal(NSNotFound);
        expect([dataSource indexOfItem:nil]).to.equal(NSNotFound);
    });
    
    it(@"should manage items with public primitives", ^{
        dataSource.items = nil;
        
        XCTAssertThrows([dataSource insertItem:nil atIndex:0], @"Nil values not allowed");
        XCTAssertThrows([dataSource insertItem:@"A" atIndex:1], @"Out out bounds");
        [dataSource insertItem:@"B" atIndex:0];
        expect(dataSource.items).to.equal(@[@"B"]);
        [dataSource insertItem:@"C" atIndex:1];
        expect(dataSource.items).to.equal(@[@"B", @"C"]);
        [dataSource insertItem:@"A" atIndex:0];
        expect(dataSource.items).to.equal(@[@"A", @"B", @"C"]);
        
        XCTAssertThrows([dataSource removeItemAtIndex:10], @"Out of bounds");
        [dataSource removeItemAtIndex:1];
        expect(dataSource.items).to.equal(@[@"A", @"C"]);
        
        XCTAssertThrows([dataSource replaceItemAtIndex:0 withItem:nil], @"Nil values not allowed");
        XCTAssertThrows([dataSource replaceItemAtIndex:10 withItem:@"X"], @"Out of bounds");
        [dataSource replaceItemAtIndex:1 withItem:@"B"];
        expect(dataSource.items).to.equal(@[@"A", @"B"]);
        
        [dataSource insertItem:@"C" atIndex:2];
        XCTAssertThrows([dataSource moveItemAtIndex:10 toDataSource:dataSource atIndex:0], @"Out of bounds");
        XCTAssertThrows([dataSource moveItemAtIndex:2 toDataSource:dataSource atIndex:-1], @"Out of bounds");
        [dataSource moveItemAtIndex:2 toDataSource:dataSource atIndex:0];
        expect(dataSource.items).to.equal(@[@"C", @"A", @"B"]);
    });
});

SpecEnd
