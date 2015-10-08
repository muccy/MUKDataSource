#import "MUKDataSourceTableUpdateAnimation.h"

@implementation MUKDataSourceTableUpdateAnimation

- (instancetype)initWithSectionsInsertionAnimation:(UITableViewRowAnimation)sectionsInsertionAnimation sectionsDeletionAnimation:(UITableViewRowAnimation)sectionsDeletionAnimation sectionsReloadAnimation:(UITableViewRowAnimation)sectionsReloadAnimation rowsInsertionAnimation:(UITableViewRowAnimation)rowsInsertionAnimation rowsDeletionAnimation:(UITableViewRowAnimation)rowsDeletionAnimation rowsReloadAnimation:(UITableViewRowAnimation)rowsReloadAnimation
{
    self = [super init];
    if (self) {
        _sectionsInsertionAnimation = sectionsInsertionAnimation;
        _sectionsDeletionAnimation = sectionsDeletionAnimation;
        _sectionsReloadAnimation = sectionsReloadAnimation;
        _rowsInsertionAnimation = rowsInsertionAnimation;
        _rowsDeletionAnimation = rowsDeletionAnimation;
        _rowsReloadAnimation = rowsReloadAnimation;
    }
    
    return self;
}

+ (instancetype)automaticAnimation {
    return [[[self class] alloc] initWithSectionsInsertionAnimation:UITableViewRowAnimationAutomatic sectionsDeletionAnimation:UITableViewRowAnimationAutomatic sectionsReloadAnimation:UITableViewRowAnimationAutomatic rowsInsertionAnimation:UITableViewRowAnimationAutomatic rowsDeletionAnimation:UITableViewRowAnimationAutomatic rowsReloadAnimation:UITableViewRowAnimationAutomatic];
}

+ (instancetype)defaultAnimation {
    return [[[self class] alloc] initWithSectionsInsertionAnimation:UITableViewRowAnimationNone sectionsDeletionAnimation:UITableViewRowAnimationNone sectionsReloadAnimation:UITableViewRowAnimationNone rowsInsertionAnimation:UITableViewRowAnimationNone rowsDeletionAnimation:UITableViewRowAnimationNone rowsReloadAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Overrides

- (instancetype)init {
    return [self initWithSectionsInsertionAnimation:UITableViewRowAnimationAutomatic sectionsDeletionAnimation:UITableViewRowAnimationAutomatic sectionsReloadAnimation:UITableViewRowAnimationAutomatic rowsInsertionAnimation:UITableViewRowAnimationAutomatic rowsDeletionAnimation:UITableViewRowAnimationAutomatic rowsReloadAnimation:UITableViewRowAnimationAutomatic];
}

@end
