//
//  MUKCollectionViewController.h
//  
//
//  Created by Marco on 17/06/15.
//
//

#import <UIKit/UIKit.h>
#import <MUKDataSource/MUKDataSource.h>

@interface MUKCollectionViewController : UICollectionViewController
@property (nonatomic) MUKDataSource *dataSource;
@end
