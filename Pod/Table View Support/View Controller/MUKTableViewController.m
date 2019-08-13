#import "MUKTableViewController.h"
#import <MUKSignal/MUKSignal.h>
#import "MUKDataSourceContentPlaceholderView.h"

@interface MUKTableViewControllerReserved : NSObject
@property (nonatomic, weak, readonly) MUKTableViewController *owner;
@property (nonatomic, weak) UIView *contentPlaceholderView;
@property (nonatomic) UITableViewCellSeparatorStyle separatorStyleBeforeContentPlaceholderView;
@property (nonatomic) BOOL suppressesSeparators;
@property (nonatomic, nonnull, readonly) MUKSignalObservation<MUKSignal<MUKDataSourceContentChange *> *> *contentObservation;
@end

@implementation MUKTableViewControllerReserved

- (instancetype)initWithOwner:(MUKTableViewController *)owner {
    self = [super init];
    if (self) {
        _owner = owner;
    }
    
    return self;
}

- (void)setupContentObservation {
    MUKDataSource *const dataSource = self.owner.dataSource;
    
    if (dataSource) {
        BOOL const observationWasRunning = self.contentObservation && ![self.contentObservation.signal isSuspended:self.contentObservation.token];

        __weak __typeof__(self) weakSelf = self;
        _contentObservation = [MUKSignalObservation observationWithSignal:dataSource.contentChangedSignal token:[dataSource.contentChangedSignal subscribe:^(MUKDataSourceContentChange * _Nonnull change)
        {
            __strong __typeof__(weakSelf) strongSelf = weakSelf;
            
            if ([change.content isKindOfClass:[MUKDataSourceContentPlaceholder class]])
            {
                [strongSelf didSetContentPlaceholder:change.content];
            }
            else {
                [strongSelf didSetContentPlaceholder:nil];
            }
        }]];
        
        if (!observationWasRunning) {
            [self.contentObservation suspend];
        }
    }
    else {
        _contentObservation = nil;
    }
}

/*
 This method is always called when view is onscreen because observation is
 suspended in -viewDidDisappear:
 */
- (void)didSetContentPlaceholder:(nullable MUKDataSourceContentPlaceholder *)placeholder
{
    // Ensure a strong reference to owning view controller
    if (!self.owner) {
        return;
    }
    
    MUKTableViewController *const viewController = self.owner;
    
    if (placeholder) {
        // Insert placeholder view
        UIView *const contentPlaceholderView = [viewController viewForContentPlaceholder:placeholder];
        
        BOOL needsAnimation;
        if (self.contentPlaceholderView) {
            // A placeholder view is already displayed
            [self.contentPlaceholderView removeFromSuperview];
            needsAnimation = NO;
        }
        else {
            // No placeholder view displayed
            
            // Catch separator style before to suppress them
            if (!self.suppressesSeparators) {
                self.separatorStyleBeforeContentPlaceholderView = viewController.tableView.separatorStyle;
            }
            
            needsAnimation = YES;
        }
        
        contentPlaceholderView.alpha = needsAnimation ? 0.0f : 1.0f;
        contentPlaceholderView.backgroundColor = [UIColor clearColor];
        contentPlaceholderView.frame = viewController.tableView.bounds;
        
        [viewController.tableView addSubview:contentPlaceholderView];
        self.contentPlaceholderView = contentPlaceholderView;
        
        self.suppressesSeparators = YES;
        viewController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        if (needsAnimation) {
            [UIView animateWithDuration:0.25 animations:^{
                contentPlaceholderView.alpha = 1.0f;
            }];
        }
    }
    else if (self.contentPlaceholderView) {
        // Remove placeholder view
        UIView *const contentPlaceholderView = self.contentPlaceholderView;
        
        // Re-enable separators
        UITableViewCellSeparatorStyle const separatorStyleBeforeContentPlaceholderView = self.separatorStyleBeforeContentPlaceholderView;
        self.suppressesSeparators = NO;
        
        [UIView animateWithDuration:0.25 animations:^{
            contentPlaceholderView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [contentPlaceholderView removeFromSuperview];
            
            // Doublecheck separators could be enabled
            if (!self.suppressesSeparators) {
                viewController.tableView.separatorStyle = separatorStyleBeforeContentPlaceholderView;
            }
        }];
    }
}

@end

@interface MUKTableViewController ()
@property (nonatomic, readonly, nonnull) MUKTableViewControllerReserved *reserved;
@end

@implementation MUKTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        CommonInit(self);
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 13, *)) {
        UIColor *backgroundColor;
        switch (self.tableView.style) {
            case UITableViewStyleGrouped:
            case UITableViewStyleInsetGrouped:
                backgroundColor = UIColor.systemGroupedBackgroundColor;
                break;
                
            default:
                backgroundColor = UIColor.systemBackgroundColor;
                break;
        }
        self.view.backgroundColor = backgroundColor;
    }
    else {
        // leave old behaviour untouched
    }
    
    if (self.dataSource) {
        [self.dataSource registerReusableViewsForTableView:self.tableView];
        self.tableView.dataSource = self.dataSource;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.reserved.contentObservation resume];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.reserved.contentObservation suspend];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.reserved.contentPlaceholderView) {
        [self.tableView bringSubviewToFront:self.reserved.contentPlaceholderView];
        
        if (!self.tableView.isTracking && !self.tableView.isDragging && !self.tableView.isDecelerating)
        {
            self.reserved.contentPlaceholderView.frame = self.tableView.bounds;
        }
    }
}

#pragma mark - Accessors

- (void)setDataSource:(MUKDataSource *)newDataSource {
    if (newDataSource != _dataSource) {
        _dataSource = newDataSource;
        [self.reserved setupContentObservation];
        
        if ([self isViewLoaded]) {
            [newDataSource registerReusableViewsForTableView:self.tableView];
            self.tableView.dataSource = newDataSource;
        }
    }
}

#pragma mark - Content Placeholder

- (UIView *)viewForContentPlaceholder:(MUKDataSourceContentPlaceholder *)placeholder
{
    MUKDataSourceContentPlaceholderView *const view = [[MUKDataSourceContentPlaceholderView alloc] initWithFrame:self.tableView.bounds];
    view.titleLabel.text = placeholder.title;
    view.textLabel.text = placeholder.subtitle;
    view.imageView.image = placeholder.image;
    
    return view;
}

#pragma mark - Private

static void CommonInit(MUKTableViewController * _Nonnull me) {
    me->_reserved = [[MUKTableViewControllerReserved alloc] initWithOwner:me];
}

@end
