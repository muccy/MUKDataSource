#import "MUKDataSource+Placeholder.h"
#import "MUKPlaceholderDataSource.h"

@implementation MUKDataSource (Placeholder)
@dynamic displaysPlaceholderDataSource;

- (BOOL)isDisplayingPlaceholderDataSource {
    for (MUKDataSource *childDataSource in self.childDataSources) {
        if ([childDataSource isKindOfClass:[MUKPlaceholderDataSource class]]) {
            MUKPlaceholderDataSource *placeholderDataSource = (MUKPlaceholderDataSource *)childDataSource;
            if (!placeholderDataSource.isHidden) {
                return YES;
                break;
            }
        }
    } // for
    
    return NO;
}

#pragma mark - Dynamic properties KVO compliance

+ (NSSet *)keyPathsForValuesAffectingDisplaysPlaceholderDataSource {
    // MUKPlaceholderDataSource's -setHidden:animated: is overridden to notify
    // changes to hidden property, too.
    
    return [NSSet setWithObject:NSStringFromSelector(@selector(childDataSources))];
}

@end
