#import "MUKSingleViewDataSource.h"
#import "MUKDataSource+TableView.h"

static NSString *const kItem = @"MUKSingleViewDataSourceItem";

@interface MUKSingleViewDataSource ()
@property (nonatomic) BOOL needsUpdateView;
@end

@implementation MUKSingleViewDataSource
@dynamic hidden;

- (id)init {
    self = [super init];
    if (self) {
        self.items = @[ kItem ];
    }
    
    return self;
}

#pragma mark - Accessors

- (BOOL)isHidden {
    return ![self.items containsObject:kItem];
}

- (void)setHidden:(BOOL)hidden {
    [self setHidden:hidden animated:NO];
}

#pragma mark - Methods

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated {
    if (hidden) {
        self.needsUpdateView = NO;
        [self setItems:@[] animated:animated];
    }
    else {
        NSArray *const newItems = @[ kItem ];
        BOOL different = ![self.items isEqualToArray:newItems];
        if (different) {
            // It will produce an event: don't refresh again
            self.needsUpdateView = NO;
        }
        
        [self setItems:newItems animated:animated];
    }
}

- (Class)viewClass {
    return nil;
}

- (void)configureView:(UIView *)view {
    //
}

- (void)setNeedsUpdateView {
    self.needsUpdateView = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateViewIfNeeded) object:nil];
    [self performSelector:@selector(updateViewIfNeeded) withObject:nil afterDelay:0.0];
}

#pragma mark - Overrides

- (UITableViewCell *)dequeueOrCreateCellForRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    NSString *const cellIdentifier = [@"MUKSingleViewDataSourceCell-" stringByAppendingString:NSStringFromClass([self viewClass])];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)tableIndexPath inTableView:(UITableView *)tableView
{
    [super configureCell:cell forRowAtIndexPath:tableIndexPath inTableView:tableView];
    
    // Find existing view
    UIView *view = nil;
    for (UIView *subview in cell.contentView.subviews) {
        if ([subview isKindOfClass:[self viewClass]]) {
            view = subview;
            break;
        }
    } // for
    
    // Create if needed
    if (!view) {
        view = [[[self viewClass] alloc] initWithFrame:cell.contentView.bounds];
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:view];
    }
    
    // Configure it
    [self configureView:view];
}

#pragma mark - Private

- (void)updateViewIfNeeded {
    if (self.needsUpdateView) {
        self.needsUpdateView = NO;
        
        if (!self.isHidden) {
            // Notify data source refreshed
            if (self.parentDataSource) {
                NSInteger const idx = [self.parentDataSource.childDataSources indexOfObject:self];
                if (idx != NSNotFound) {
                    [self didRefreshChildDataSourceAtIndex:idx inDataSource:self.parentDataSource];
                }
            }
            else {
                [self didReloadDataInDataSource:self];
            }
        }
    }
}

@end
