//
//  RJUserRecommendViewController.h
//  ssrj
//
//  Created by mac on 17/2/20.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STCollectionView.h"

@class RJUserCenteRootViewController;

@interface RJUserRecommendViewController : UICollectionViewController
@property (assign, nonatomic) RJUserCenteRootViewController * fatherViewController;
@property (strong, nonatomic) NSNumber * userId;

@end
