#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Describes table view update animation
 */
@interface MUKDataSourceTableUpdateAnimation : NSObject
/**
 Animation to use inserting sections
 */
@property (nonatomic, readonly) UITableViewRowAnimation sectionsInsertionAnimation;
/**
 Animation to use deleting sections
 */
@property (nonatomic, readonly) UITableViewRowAnimation sectionsDeletionAnimation;
/**
 Animation to use reloading sections
 */
@property (nonatomic, readonly) UITableViewRowAnimation sectionsReloadAnimation;
/**
 Animation to use inserting rows
 */
@property (nonatomic, readonly) UITableViewRowAnimation rowsInsertionAnimation;
/**
 Animation to use deleting rows
 */
@property (nonatomic, readonly) UITableViewRowAnimation rowsDeletionAnimation;
/**
 Animation to use reloading rows
 */
@property (nonatomic, readonly) UITableViewRowAnimation rowsReloadAnimation;
/**
 Designated initializer
 */
- (instancetype)initWithSectionsInsertionAnimation:(UITableViewRowAnimation)sectionsInsertionAnimation sectionsDeletionAnimation:(UITableViewRowAnimation)sectionsDeletionAnimation sectionsReloadAnimation:(UITableViewRowAnimation)sectionsReloadAnimation rowsInsertionAnimation:(UITableViewRowAnimation)rowsInsertionAnimation rowsDeletionAnimation:(UITableViewRowAnimation)rowsDeletionAnimation rowsReloadAnimation:(UITableViewRowAnimation)rowsReloadAnimation NS_DESIGNATED_INITIALIZER;
/**
 @returns Animation with all fields filled with UITableViewRowAnimationAutomatic
 */
+ (instancetype)automaticAnimation;
/**
 @returns Animation with all fields filled with UITableViewRowAnimationNone
 */
+ (instancetype)defaultAnimation;
@end

NS_ASSUME_NONNULL_END
