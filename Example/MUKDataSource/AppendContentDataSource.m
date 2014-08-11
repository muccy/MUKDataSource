#import "AppendContentDataSource.h"

@implementation AppendContentDataSource

- (void)configureView:(UIView *)view {
    [super configureView:view];
    
    if ([view isKindOfClass:[MUKDataSourceAppendContentView class]]) {
        MUKDataSourceAppendContentView *appendContentView = (MUKDataSourceAppendContentView *)view;
        appendContentView.textLabel.textColor = [[UIApplication sharedApplication] keyWindow].rootViewController.view.tintColor;
    }
}

@end
