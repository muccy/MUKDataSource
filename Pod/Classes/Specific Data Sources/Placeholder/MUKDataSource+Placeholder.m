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

@end
